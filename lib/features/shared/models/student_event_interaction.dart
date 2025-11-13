import 'package:cloud_firestore/cloud_firestore.dart';

enum InteractionType {
  registered,
  following,
  completed,
  cancelled,
}

class StudentEventInteraction {
  final String id;
  final String studentId;
  final String eventId;
  final InteractionType type;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final Map<String, dynamic> metadata; // Additional data like registration details, follow reason, etc.

  StudentEventInteraction({
    required this.id,
    required this.studentId,
    required this.eventId,
    required this.type,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.metadata = const {},
  });

  factory StudentEventInteraction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentEventInteraction(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      eventId: data['eventId'] ?? '',
      type: InteractionType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => InteractionType.following,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'eventId': eventId,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  StudentEventInteraction copyWith({
    String? id,
    String? studentId,
    String? eventId,
    InteractionType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return StudentEventInteraction(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      eventId: eventId ?? this.eventId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  bool get isRegistration => type == InteractionType.registered;
  bool get isFollowing => type == InteractionType.following;
  bool get isCompleted => type == InteractionType.completed;
  bool get isCancelled => type == InteractionType.cancelled;

  @override
  String toString() {
    return 'StudentEventInteraction(id: $id, studentId: $studentId, eventId: $eventId, type: $type, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentEventInteraction &&
        other.id == id &&
        other.studentId == studentId &&
        other.eventId == eventId &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studentId.hashCode ^
        eventId.hashCode ^
        type.hashCode;
  }
}
