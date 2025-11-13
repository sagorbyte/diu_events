class AppUser {
  final String uid;
  final String email;
  final String name;
  final String role; // 'student', 'admin', or 'superadmin'
  final String profilePicture;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final DateTime? lastSeenUpdateTime;
  
  // Student-specific fields
  final String studentId;
  final String department;
  final String phone;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.profilePicture = '',
    this.createdAt,
    this.lastLogin,
    this.lastSeenUpdateTime,
    this.studentId = '',
    this.department = '',
    this.phone = '',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'student',
      profilePicture: json['profilePicture'] ?? '',
      createdAt: json['createdAt']?.toDate(),
      lastLogin: json['lastLogin']?.toDate(),
      lastSeenUpdateTime: json['lastSeenUpdateTime']?.toDate(),
      studentId: json['studentId'] ?? '',
      department: json['department'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'profilePicture': profilePicture,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'lastSeenUpdateTime': lastSeenUpdateTime,
      'studentId': studentId,
      'department': department,
      'phone': phone,
    };
  }

  bool get isSuperAdmin => role == 'superadmin';
  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isStudent => role == 'student';

  // Check if profile is complete for students
  bool get isProfileComplete {
    if (isStudent) {
      final isComplete = name.isNotEmpty && 
             email.isNotEmpty && 
             studentId.isNotEmpty && 
             department.isNotEmpty && 
             phone.isNotEmpty;
      print('Profile complete check: $isComplete (studentId=$studentId, department=$department, phone=$phone)');
      return isComplete;
    }
    // For admins, only check basic fields
    return name.isNotEmpty && email.isNotEmpty;
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? lastLogin,
    DateTime? lastSeenUpdateTime,
    String? studentId,
    String? department,
    String? phone,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      lastSeenUpdateTime: lastSeenUpdateTime ?? this.lastSeenUpdateTime,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      phone: phone ?? this.phone,
    );
  }
}
