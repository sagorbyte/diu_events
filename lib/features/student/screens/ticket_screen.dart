import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../shared/services/ticket_service.dart';
import '../../shared/models/ticket.dart';
import '../../shared/providers/event_provider.dart';
import '../../shared/models/event.dart';

class TicketScreen extends StatefulWidget {
  final String userId;
  final String eventId;

  const TicketScreen({super.key, required this.userId, required this.eventId});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final TicketService _ticketService = TicketService();
  Ticket? _ticket;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    setState(() => _isLoading = true);
    try {
      final t = await _ticketService.getTicketByUserAndEvent(widget.userId, widget.eventId);
      if (mounted) {
        setState(() {
          _ticket = t;
          _isLoading = false;
        });
      }
    } catch (e) {
      // if something unexpected happens, stop loading and show no ticket
      if (mounted) {
        setState(() {
          _ticket = null;
          _isLoading = false;
        });
      }
      print('TicketScreen._loadTicket error: $e');
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return month >= 1 && month <= 12 ? months[month] : '';
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
  final Event event = eventProvider.events.firstWhere(
      (e) => e.id == widget.eventId,
      orElse: () => Event(
        id: '',
        title: '',
        description: '',
        location: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        startTime: '',
        endTime: '',
        organizerName: '',
        organizerId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _ticket == null
                ? Center(
                    child: Text(
                      'No ticket found for this event',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  )
                : Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Blue event banner (clean image, no overlays)
                            Container(
                              width: 320,
                              height: 160,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1A4FA0), Color(0xFF2E5BB8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                image: event.id.isNotEmpty && event.imageUrl.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(event.imageUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            ),

                            // White event info card (no spacing)
                            Container(
                              width: 320,
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          event.location,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${event.startDate.day} ${_getMonthName(event.startDate.month)} ${event.startDate.year}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        event.startTime,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.group, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        event.organizerName,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Barcode card (no spacing)
                            Container(
                              width: 320,
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                              ),
                              child: Column(
                                children: [
                                  // Barcode
                                  BarcodeWidget(
                                    data: _ticket!.id,
                                    barcode: Barcode.code128(),
                                    width: double.infinity,
                                    height: 80,
                                    drawText: false,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(height: 16),
                                  // Ticket ID
                                  Text(
                                    _ticket!.id,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Back button top-left
                      Positioned(
                        top: 12,
                        left: 12,
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
