import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Authentication related failures
class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message: message);
}

/// Storage related failures
class StorageFailure extends Failure {
  const StorageFailure({required String message}) : super(message: message);
}

/// File related failures
class FileFailure extends Failure {
  const FileFailure({required String message}) : super(message: message);
}

/// Network related failures (even though the app is offline, we might have network-like failures)
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

/// Server related failures
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({required String message}) : super(message: message);
}
