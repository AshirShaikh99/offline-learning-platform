import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

/// Base class for authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status event
class CheckAuthStatusEvent extends AuthEvent {}

/// Login event
class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  const LoginEvent({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

/// Register event
class RegisterEvent extends AuthEvent {
  final User user;

  const RegisterEvent({required this.user});

  @override
  List<Object> get props => [user];
}

/// Logout event
class LogoutEvent extends AuthEvent {}

/// Update user event
class UpdateUserEvent extends AuthEvent {
  final User user;

  const UpdateUserEvent({required this.user});

  @override
  List<Object> get props => [user];
}

/// Delete user event
class DeleteUserEvent extends AuthEvent {
  final String id;

  const DeleteUserEvent({required this.id});

  @override
  List<Object> get props => [id];
}

/// Get all users event
class GetAllUsersEvent extends AuthEvent {}
