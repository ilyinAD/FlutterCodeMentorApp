import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int userId;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;
  final DateTime? createdAt;

  const UserModel({
    required this.userId,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
        'role': role,
        'first_name': firstName,
        'last_name': lastName,
        'created_at': createdAt?.toIso8601String(),
      };

  String get fullName =>
      [firstName, lastName].where((s) => s != null).join(' ');

  @override
  List<Object?> get props =>
      [userId, email, role, firstName, lastName, createdAt];
}
