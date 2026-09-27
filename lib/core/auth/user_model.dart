import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'student' or 'admin'
  final String? phone;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'student',
    this.phone,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? (data['email'] as String? ?? 'User').split('@').first,
      role: data['role'] ?? 'student',
      phone: data['phone'],
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? (data['email'] as String? ?? 'User').split('@').first,
      role: data['role'] ?? 'student',
      phone: data['phone'],
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? displayName,
    String? role,
    String? phone,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }
}
