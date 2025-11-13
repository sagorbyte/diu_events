import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/providers/event_provider.dart';
import '../../shared/models/event.dart';
import '../../../core/services/imgbb_image_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _eventNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  // Date and time variables
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _registrationDeadline;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  TimeOfDay? _registrationDeadlineTime;

  // Dropdown values
  String? _eventType; // In Person or Virtual
  int? _maxParticipants; // Maximum number of participants allowed

  // Image
  String _imageUrl = '';
  XFile? _selectedImage;
  final ImgBBImageService _imageUploadService = ImgBBImageService();

  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header Section
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3F3D9C), Color(0xFF5B4FBF)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Back Button
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    // Title
                    Expanded(
                      child: Text(
                        'Create Event',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Upload Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 220, // Match requirement height
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                _buildImageWidget(),
                                // Upload Button Overlay
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _showImageSourceActionSheet,
                                      child:
                                          _imageUrl.isEmpty &&
                                              _selectedImage == null
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_photo_alternate,
                                                    size: 48,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Tap to add event image — 440×220 px, max 1MB',
                                                    style:
                                                        GoogleFonts.hindSiliguri(
                                                          fontSize: 14,
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                    ),
                                  ),
                                ),
                                // Remove Button
                                if (_imageUrl.isNotEmpty ||
                                    _selectedImage != null)
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _imageUrl = '';
                                          _selectedImage = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Event Name
                    _buildTextField(
                      controller: _eventNameController,
                      label: 'Event Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Event name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date and Time Row
                    Row(
                      children: [
                        // Start Date
                        Expanded(
                          child: _buildDateField(
                            label: 'Start Date',
                            date: _startDate,
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Start Time
                        Expanded(
                          child: _buildTimeField(
                            label: 'Start Time',
                            time: _startTime,
                            onTap: () => _selectTime(context, true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // End Date and Time Row
                    Row(
                      children: [
                        // End Date
                        Expanded(
                          child: _buildDateField(
                            label: 'End Date',
                            date: _endDate,
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // End Time
                        Expanded(
                          child: _buildTimeField(
                            label: 'End Time',
                            time: _endTime,
                            onTap: () => _selectTime(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Registration Deadline
                    _buildDateField(
                      label: 'Registration Deadline (Optional)',
                      date: _registrationDeadline,
                      time: _registrationDeadlineTime,
                      onTap: () => _selectRegistrationDeadline(context),
                      helpText:
                          'Last date and time when users can register or cancel registrations',
                    ),
                    const SizedBox(height: 16),

                    // Event Type Dropdown
                    _buildDropdownField(
                      label: 'In Person or Virtual?',
                      value: _eventType,
                      items: ['In Person', 'Virtual'],
                      onChanged: (value) {
                        setState(() {
                          _eventType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location
                    _buildTextField(
                      controller: _locationController,
                      label: 'Location',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Maximum Participants
                    _buildTextField(
                      controller: _maxParticipantsController,
                      label: 'Maximum Participants (leave empty for unlimited)',
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            _maxParticipants = null; // Unlimited
                          } else {
                            final parsed = int.tryParse(value);
                            if (parsed != null && parsed > 0) {
                              _maxParticipants = parsed;
                            }
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Create Event Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Consumer<EventProvider>(
          builder: (context, eventProvider, child) {
            return SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: eventProvider.isLoading ? null : _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F3D9C),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(
                    0xFF3F3D9C,
                  ).withOpacity(0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: eventProvider.isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Text(
                        'Create Event',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.hindSiliguri(
          color: Colors.grey.shade600,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3F3D9C), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: GoogleFonts.hindSiliguri(
        fontSize: 16,
        color: Colors.grey.shade900,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    TimeOfDay? time,
    required VoidCallback onTap,
    String? helpText,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? time != null
                              ? '${DateFormat('d MMMM yyyy').format(date)} at ${time.format(context)}'
                              : DateFormat('d MMMM yyyy').format(date)
                        : 'Select date',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      color: date != null
                          ? Colors.grey.shade900
                          : Colors.grey.shade500,
                    ),
                  ),
                  if (helpText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      helpText,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time != null ? time.format(context) : 'Select time',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      color: time != null
                          ? Colors.grey.shade900
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.hindSiliguri(
          color: Colors.grey.shade600,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3F3D9C), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: GoogleFonts.hindSiliguri(
        fontSize: 16,
        color: Colors.grey.shade900,
      ),
      dropdownColor: Colors.white,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              color: Colors.grey.shade900,
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3F3D9C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before start date, reset it
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3F3D9C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _selectRegistrationDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: _endDate ?? DateTime.now().add(const Duration(days: 365)),
      helpText: 'SELECT REGISTRATION DEADLINE DATE',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3F3D9C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _registrationDeadline = picked;
      });

      // After selecting date, open time picker
      await _selectRegistrationDeadlineTime(context);
    }
  }

  Future<void> _selectRegistrationDeadlineTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _registrationDeadlineTime ?? TimeOfDay.now(),
      helpText: 'SELECT REGISTRATION DEADLINE TIME',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3F3D9C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _registrationDeadlineTime = picked;
      });
    }
  }

  void _showImageSourceActionSheet() async {
    try {
      // Show image source selection dialog
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Select Image Source',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('Gallery', style: GoogleFonts.hindSiliguri()),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('Camera', style: GoogleFonts.hindSiliguri()),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (source != null) {
        setState(() {});

        // Pick and validate image with DIU Events requirements
        final XFile? image = await _imageUploadService.pickAndValidateImage(
          source: source,
        );

        if (image != null) {
          setState(() {
            _selectedImage = image;
            _imageUrl = image.path; // For preview purposes
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image validated! 440×220px image selected successfully.',
                style: GoogleFonts.hindSiliguri(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Image Validation Failed',
                style: GoogleFonts.hindSiliguri(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                e.toString().replaceFirst(
                  'Exception: Failed to validate image: Exception: ',
                  '',
                ),
                style: GoogleFonts.hindSiliguri(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '💡 Use Canva, GIMP, or online resizers to create 440×220px images',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {});
    }
  }

  Widget _buildImageWidget() {
    if (_selectedImage != null) {
      // For web, use Image.memory to display the selected image
      return FutureBuilder<Uint8List>(
        future: _selectedImage!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            );
          } else if (snapshot.hasError) {
            return Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey.shade300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image, color: Colors.grey, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Image Selected',
                    style: GoogleFonts.hindSiliguri(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _selectedImage!.name,
                    style: GoogleFonts.hindSiliguri(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          } else {
            return Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey.shade300,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
        },
      );
    } else if (_imageUrl.isNotEmpty) {
      // Display network image URL
      return Image.network(
        _imageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(Icons.error, color: Colors.grey, size: 48),
            ),
          );
        },
      );
    } else {
      // No image selected
      return Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.image, color: Colors.grey, size: 48),
        ),
      );
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate required fields
    if (_startDate == null) {
      _showErrorSnackBar('Please select a start date');
      return;
    }
    if (_endDate == null) {
      _showErrorSnackBar('Please select an end date');
      return;
    }
    if (_startTime == null) {
      _showErrorSnackBar('Please select a start time');
      return;
    }
    if (_endTime == null) {
      _showErrorSnackBar('Please select an end time');
      return;
    }
    if (_eventType == null) {
      _showErrorSnackBar('Please select event type');
      return;
    }

    // Validate dates
    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      _showErrorSnackBar('End date/time must be after start date/time');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    if (authProvider.user == null) {
      _showErrorSnackBar('User not authenticated');
      return;
    }

    // Create the event
    final event = Event(
      id: '', // Will be generated by Firestore
      title: _eventNameController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      startDate: startDateTime,
      endDate: endDateTime,
      startTime: _startTime!.format(context),
      endTime: _endTime!.format(context),
      organizerName: authProvider.user!.name,
      organizerId: authProvider.user!.uid,
      imageUrl: _imageUrl,
      tags: [], // TODO: Add tags support
      maxParticipants: _maxParticipants ?? 0, // 0 = unlimited, >0 = limited
      registeredParticipants: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      registrationDeadline: _registrationDeadline,
      registrationDeadlineTime: _registrationDeadlineTime != null
          ? _registrationDeadlineTime!.format(context)
          : '',
      eventDetails: {
        'eventType': _eventType!,
        'maxParticipants': _maxParticipants ?? 0,
      },
    );

    final success = await eventProvider.createEventWithImage(
      event,
      imageFile: _selectedImage,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Event created successfully!',
              style: GoogleFonts.hindSiliguri(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } else {
      _showErrorSnackBar(
        eventProvider.errorMessage ?? 'Failed to create event',
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.hindSiliguri(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
