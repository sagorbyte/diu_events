class UserNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'registration_cancelled', 'event_update', etc.
  final String? eventId;
  final String? eventTitle;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const UserNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.eventId,
    this.eventTitle,
    required this.isRead,
    required this.createdAt,
    this.metadata,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    // Parse createdAt flexibly (String, int, Timestamp)
    final createdAtRaw = json['createdAt'];
    DateTime createdAt;
    if (createdAtRaw == null) {
      createdAt = DateTime.now();
    } else if (createdAtRaw is String) {
      try {
        createdAt = DateTime.parse(createdAtRaw);
      } catch (_) {
        createdAt = DateTime.now();
      }
    } else if (createdAtRaw is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtRaw);
    } else {
      try {
        // Firestore Timestamp has toDate()
        createdAt = (createdAtRaw as dynamic).toDate();
      } catch (_) {
        createdAt = DateTime.now();
      }
    }

    return UserNotification(
      id: (json['id'] ?? '') as String,
      userId: (json['userId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      message: (json['message'] ?? '') as String,
      type: (json['type'] ?? '') as String,
      eventId: json['eventId'] as String?,
      eventTitle: json['eventTitle'] as String?,
      isRead: json['isRead'] ?? false,
      createdAt: createdAt,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  UserNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? eventId,
    String? eventTitle,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserNotification(id: $id, userId: $userId, title: $title, type: $type, isRead: $isRead)';
  }
}
