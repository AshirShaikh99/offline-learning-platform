import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

/// User entity representing a user in the application
class User extends Equatable {
  final String id;
  final String username;
  final String password; // In a real app, this would be hashed
  final String role;
  final String? className; // Only applicable for students
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    this.className,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if user is admin
  bool get isAdmin => role == AppConstants.roleAdmin;

  /// Check if user is student
  bool get isStudent => role == AppConstants.roleStudent;

  /// Create a copy of this user with the given fields replaced with the new values
  User copyWith({
    String? id,
    String? username,
    String? password,
    String? role,
    String? className,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      className: className ?? this.className,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    password,
    role,
    className,
    createdAt,
    updatedAt,
  ];
}
