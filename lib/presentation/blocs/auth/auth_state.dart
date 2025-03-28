import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

/// Base class for authentication states
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {}

/// Loading state
class AuthLoading extends AuthState {}

/// Authenticated state
class Authenticated extends AuthState {
  final User user;
  
  const Authenticated({required this.user});
  
  @override
  List<Object> get props => [user];
}

/// Unauthenticated state
class Unauthenticated extends AuthState {}

/// Registration success state
class RegistrationSuccess extends AuthState {
  final User user;
  
  const RegistrationSuccess({required this.user});
  
  @override
  List<Object> get props => [user];
}

/// Error state
class AuthError extends AuthState {
  final String message;
  
  const AuthError({required this.message});
  
  @override
  List<Object> get props => [message];
}