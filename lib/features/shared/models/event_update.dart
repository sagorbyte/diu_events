import 'package:cloud_firestore/cloud_firestore.dart';

class EventUpdate {
  final String id;
  final String eventId;
  final String message;
  final String organizerId;
  final DateTime createdAt;
  final bool isActive;

  EventUpdate({
    required this.id,
    required this.eventId,
    required this.message,
    required this.organizerId,
    required this.createdAt,
    this.isActive = true,
  });

  factory EventUpdate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventUpdate(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      message: data['message'] ?? '',
      organizerId: data['organizerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'message': message,
      'organizerId': organizerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  EventUpdate copyWith({
    String? id,
    String? eventId,
    String? message,
    String? organizerId,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return EventUpdate(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      message: message ?? this.message,
      organizerId: organizerId ?? this.organizerId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper methods
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
