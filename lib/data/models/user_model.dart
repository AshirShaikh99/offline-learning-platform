import 'package:hive/hive.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// User model for local storage with Hive
@HiveType(typeId: 0)
class UserModel extends User {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String username;

  @HiveField(2)
  @override
  final String password;

  @HiveField(3)
  @override
  final String role;

  @HiveField(4)
  @override
  final String? className;

  @HiveField(5)
  @override
  final DateTime createdAt;

  @HiveField(6)
  @override
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    this.className,
    required this.createdAt,
    required this.updatedAt,
  }) : super(
         id: id,
         username: username,
         password: password,
         role: role,
         className: className,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Create a UserModel from a User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      password: user.password,
      role: user.role,
      className: user.className,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  /// Create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      role: json['role'],
      className: json['className'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'className': className,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of this UserModel with the given fields replaced with the new values
  @override
  UserModel copyWith({
    String? id,
    String? username,
    String? password,
    String? role,
    String? className,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      className: className ?? this.className,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
