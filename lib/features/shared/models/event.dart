import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime;
  final String endTime;
  final String organizerName; // Department, Institute, or Body name
  final String organizerId; // Admin UID who created the event
  final String imageUrl;
  final List<String> tags;
  final int maxParticipants;
  final List<String> registeredParticipants;
  final List<String> interestedUsers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final DateTime? registrationDeadline; // Registration deadline date
  final String registrationDeadlineTime; // Registration deadline time
  final Map<String, dynamic> eventDetails; // Additional event-specific fields
  final String certificateFolderUrl; // URL to folder containing certificates

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.organizerName,
    required this.organizerId,
    this.imageUrl = '',
    this.tags = const [],
    this.maxParticipants = 0,
    this.registeredParticipants = const [],
    this.interestedUsers = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.registrationDeadline,
    this.registrationDeadlineTime = '',
    this.eventDetails = const {},
    this.certificateFolderUrl = '',
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      organizerName: data['organizerName'] ?? '',
      organizerId: data['organizerId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      maxParticipants: data['maxParticipants'] ?? 0,
      registeredParticipants: List<String>.from(
        data['registeredParticipants'] ?? [],
      ),
      interestedUsers: List<String>.from(data['interestedUsers'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      registrationDeadline: data['registrationDeadline'] != null
          ? (data['registrationDeadline'] as Timestamp).toDate()
          : null,
      registrationDeadlineTime: data['registrationDeadlineTime'] ?? '',
      isActive: data['isActive'] ?? true,
      eventDetails: Map<String, dynamic>.from(data['eventDetails'] ?? {}),
      certificateFolderUrl: data['certificateFolderUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = {
      'title': title,
      'description': description,
      'location': location,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'startTime': startTime,
      'endTime': endTime,
      'organizerName': organizerName,
      'organizerId': organizerId,
      'imageUrl': imageUrl,
      'tags': tags,
      'maxParticipants': maxParticipants,
      'registeredParticipants': registeredParticipants,
      'interestedUsers': interestedUsers,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'eventDetails': eventDetails,
      'certificateFolderUrl': certificateFolderUrl,
    };

    if (registrationDeadline != null) {
      map['registrationDeadline'] = Timestamp.fromDate(registrationDeadline!);
    }

    if (registrationDeadlineTime.isNotEmpty) {
      map['registrationDeadlineTime'] = registrationDeadlineTime;
    }

    return map;
  }

  // Helper methods
  bool get isPastEvent => endDate.isBefore(DateTime.now());
  bool get isUpcomingEvent => startDate.isAfter(DateTime.now());
  bool get isOngoingEvent =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  bool get hasAvailableSpots =>
      maxParticipants == 0 || registeredParticipants.length < maxParticipants;

  bool get isRegistrationOpen {
    if (registrationDeadline == null) return true;

    DateTime now = DateTime.now();

    // If the deadline day is today, check the time
    if (registrationDeadline!.year == now.year &&
        registrationDeadline!.month == now.month &&
        registrationDeadline!.day == now.day) {
      // If no specific time is set, use end of day
      if (registrationDeadlineTime.isEmpty) {
        return true; // Allow registration for today until end of day
      }

      // Parse deadline time
      try {
        final timeParts = registrationDeadlineTime.split(':');
        if (timeParts.length >= 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          // Compare with current time
          return now.hour < hour || (now.hour == hour && now.minute < minute);
        }
      } catch (e) {
        // If time parsing fails, fall back to date comparison
      }
    }

    // If not same day, check if deadline is in future
    return registrationDeadline!.isAfter(now);
  }

  int get availableSpots => maxParticipants == 0
      ? -1
      : maxParticipants - registeredParticipants.length;

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    String? organizerName,
    String? organizerId,
    String? imageUrl,
    List<String>? tags,
    int? maxParticipants,
    List<String>? registeredParticipants,
    List<String>? interestedUsers,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    DateTime? registrationDeadline,
    String? registrationDeadlineTime,
    Map<String, dynamic>? eventDetails,
    String? certificateFolderUrl,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      organizerName: organizerName ?? this.organizerName,
      organizerId: organizerId ?? this.organizerId,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      registeredParticipants:
          registeredParticipants ?? this.registeredParticipants,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      registrationDeadlineTime:
          registrationDeadlineTime ?? this.registrationDeadlineTime,
      interestedUsers: interestedUsers ?? this.interestedUsers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      eventDetails: eventDetails ?? this.eventDetails,
      certificateFolderUrl: certificateFolderUrl ?? this.certificateFolderUrl,
    );
  }

  // Format registration deadline for display
  String getRegistrationDeadlineText() {
    if (registrationDeadline == null) {
      return '';
    }

    final now = DateTime.now();
    final deadline = registrationDeadline!;
    final deadlineTime = registrationDeadlineTime.isNotEmpty
        ? registrationDeadlineTime
        : '11:59 PM';

    // Format the date
    String dateFormat;
    if (deadline.year == now.year) {
      // Same year, show month and day
      if (deadline.month == now.month && deadline.day == now.day) {
        dateFormat = 'Today';
      } else if (deadline.month == now.month && deadline.day == now.day + 1) {
        dateFormat = 'Tomorrow';
      } else {
        final months = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        dateFormat = '${deadline.day} ${months[deadline.month]}';
      }
    } else {
      // Different year, show full date
      final months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      dateFormat = '${deadline.day} ${months[deadline.month]} ${deadline.year}';
    }

    return 'Registration opens till $dateFormat at $deadlineTime';
  }
}
