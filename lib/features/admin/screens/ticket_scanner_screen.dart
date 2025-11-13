import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
// no provider imports required for this screen; services are used directly
import '../../shared/services/ticket_service.dart';
import '../../shared/services/student_event_interaction_service.dart';
import '../../shared/models/student_event_interaction.dart';
import '../../shared/providers/event_provider.dart';
import '../../shared/models/event.dart';

class TicketScannerScreen extends StatefulWidget {
  final String eventId;
  const TicketScannerScreen({super.key, required this.eventId});

  @override
  State<TicketScannerScreen> createState() => _TicketScannerScreenState();
}

class _TicketScannerScreenState extends State<TicketScannerScreen> {
  String _status = '';
  Color _statusColor = Colors.grey;
  bool _processing = false;
  String _lastScanned = '';
  String _scannedStudentName = '';
  String _scannedStudentId = '';
  String _scannedTicketDocId = '';
  String _scannedTicketEventTitle = '';
  Event? _event;
  bool _isLoadingEvent = true;
  final MobileScannerController _cameraController = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
  );

  final TicketService _ticketService = TicketService();
  final StudentEventInteractionService _interactionService =
      StudentEventInteractionService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEvent();
    });
  }

  Future<void> _fetchEvent() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final event = await eventProvider.getEventById(widget.eventId);
      if (mounted) {
        setState(() {
          _event = event;
          _isLoadingEvent = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingEvent = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load event details: $e')),
        );
      }
    }
  }

  DateTime _parseEventStartDateTime(Event event) {
    try {
      final parts = event.startTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1].split(' ')[0]);

      // Handle AM/PM
      if (event.startTime.toLowerCase().contains('pm') && hour != 12) {
        hour += 12;
      } else if (event.startTime.toLowerCase().contains('am') && hour == 12) {
        hour = 0;
      }

      return DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
        hour,
        minute,
      );
    } catch (e) {
      // Fallback to just the date if time parsing fails
      return event.startDate;
    }
  }

  // Helper to reuse scanning logic with a raw string (used for manual verify)
  Future<void> _processScannedString(String raw) async {
    if (raw.isEmpty) return;
    if (_processing) return;

      setState(() {
      _processing = true;
      _status = 'Checking...';
      _statusColor = Colors.blueAccent;
    });

    try {
      // Reuse the same core logic as in _handleBarcode by delegating to it via a minimal shim
      // Create a fake Barcode-like object by using the actual Barcode constructor is not possible
      // so duplicate the core handling here to avoid type issues.
      final ticketId = raw.trim();

      // Always show the scanned raw value
      setState(() {
        _lastScanned = ticketId;
        _status = 'Scanned: $ticketId';
        _statusColor = Colors.white;
        _scannedStudentName = '';
        _scannedStudentId = '';
        _scannedTicketDocId = '';
        _scannedTicketEventTitle = '';
      });

      // Try to fetch ticket by id
      var firestoreTicket = await _ticketService.getTicketById(ticketId);

      // Fallback to robust lookup if direct doc lookup failed
      if (firestoreTicket == null) {
        firestoreTicket = await _ticketService.lookupTicketByAnyField(ticketId);
      }

      // Check if event has started before allowing ticket scanning
      if (_event != null) {
        final eventStartDateTime = _parseEventStartDateTime(_event!);
        final now = DateTime.now();
        final isEventStarted = now.isAfter(eventStartDateTime) || now.isAtSameMomentAs(eventStartDateTime);

        if (!isEventStarted) {
          setState(() {
            _status = 'Scanning starts at ${_event!.startTime}';
            _statusColor = Colors.orangeAccent;
          });
          return;
        }
      }

      if (firestoreTicket == null) {
        // Invalid ticket
        setState(() {
          _status = 'Unable to Verify';
          _statusColor = Colors.redAccent;
        });
      } else if (firestoreTicket.eventId != widget.eventId) {
        // Ticket not for this event
        setState(() {
          _status = 'Unable to Verify';
          _statusColor = Colors.red;
        });
      } else {
        // Check if already verified (interaction completed metadata)
        final interaction = await _interactionService.getInteraction(
          firestoreTicket.userId,
          firestoreTicket.eventId,
          InteractionType.completed,
        );

        // capture ticket info for display
        _scannedTicketDocId = firestoreTicket.id;
        _scannedTicketEventTitle = firestoreTicket.eventTitle;

        // fetch user info for display
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(firestoreTicket.userId)
              .get();
          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>;
            _scannedStudentName = (data['name'] ?? '').toString();
            _scannedStudentId = (data['studentId'] ?? '').toString();
          }
        } catch (_) {
          // ignore user fetch errors
        }

        if (interaction != null && interaction.isActive) {
          setState(() {
              _status = 'Already Verified';
              _statusColor = Colors.orangeAccent;
            });
        } else {
          // Mark completed (attended)
          await _interactionService.markEventCompleted(
            firestoreTicket.userId,
            firestoreTicket.eventId,
            metadata: {'ticketId': firestoreTicket.id},
          );

          setState(() {
            _status = 'Verified';
            _statusColor = Colors.greenAccent;
          });
        }
      }
    } catch (e) {
      setState(() {
        _status = 'Unable to Verify';
        _statusColor = Colors.red;
      });
    } finally {
      // allow scanning again after short delay so UI updates are visible
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _processing = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Ticket'),
        backgroundColor: const Color(0xFF3F3D9C),
        elevation: 2,
        // ensure title, back button and action icons are white for contrast
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        actions: [
          IconButton(
            tooltip: 'Flip camera',
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => _cameraController.switchCamera(),
          ),
          IconButton(
            tooltip: 'Toggle torch',
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _cameraController.toggleTorch(),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: _isLoadingEvent
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F3D9C)),
                ),
              )
            : LayoutBuilder(builder: (context, constraints) {
          final panelHeight = min(220.0, constraints.maxHeight * 0.28);

          return Column(
            children: [
              // Camera area
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _cameraController,
                      fit: BoxFit.cover,
                      onDetect: (capture) {
                        // quick guard to avoid overlapping processing calls
                        if (_processing) return;
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          // Prefer raw string processing to avoid constructing fake Barcode
                          final raw = barcodes.first.rawValue;
                          if (raw != null && raw.isNotEmpty) _processScannedString(raw);
                        }
                      },
                    ),

                    // Center scanning frame
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.72,
                        heightFactor: 0.28,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.85),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Top hint
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Center(
                          child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _processing ? 'Processing...' : 'Point the camera at the barcode',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom info panel
              Container(
                width: double.infinity,
                height: panelHeight,
                decoration: BoxDecoration(
                  // Use near black for strong contrast with white text
                  color: const Color(0xFF121212),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _status.isNotEmpty ? _status : 'No scan yet',
                              style: TextStyle(
                                color: _statusColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Last: ${_lastScanned.isNotEmpty ? _lastScanned : '-'}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            if (_scannedStudentName.isNotEmpty || _scannedStudentId.isNotEmpty) ...[
                              Text(
                                'Name: ${_scannedStudentName.isNotEmpty ? _scannedStudentName : '-'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Student ID: ${_scannedStudentId.isNotEmpty ? _scannedStudentId : '-'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (_scannedTicketDocId.isNotEmpty || _scannedTicketEventTitle.isNotEmpty) ...[
                              Text(
                                'Ticket: ${_scannedTicketDocId.isNotEmpty ? _scannedTicketDocId : '-'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Event: ${_scannedTicketEventTitle.isNotEmpty ? _scannedTicketEventTitle : '-'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              _processing ? 'Processing ticket...' : 'Ready to scan',
                              style: const TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Done / manual verify column
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white12,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Done', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: () async {
                            // Manual lookup dialog
                            final code = await showDialog<String>(
                              context: context,
                              builder: (ctx) {
                                String value = '';
                                return AlertDialog(
                                  title: const Text('Manual verify'),
                                  content: TextField(
                                    autofocus: true,
                                    decoration: const InputDecoration(hintText: 'Enter ticket code or id'),
                                    onChanged: (v) => value = v,
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(value), child: const Text('Verify')),
                                  ],
                                );
                              },
                            );
                            if (code != null && code.trim().isNotEmpty) {
                              // process manual code the same way the scanner does
                              await _processScannedString(code.trim());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F3D9C),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Manual Verify', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
