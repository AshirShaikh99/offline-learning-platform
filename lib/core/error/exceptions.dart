/// Custom exceptions for the application

/// Authentication exceptions
class AuthException implements Exception {
  final String message;

  AuthException({required this.message});
}

/// Storage exceptions
class StorageException implements Exception {
  final String message;

  StorageException({required this.message});
}

/// File exceptions
class FileException implements Exception {
  final String message;

  FileException({required this.message});
}

/// Cache exceptions
class CacheException implements Exception {
  final String message;

  CacheException({required this.message});
}

/// Server exceptions
class ServerException implements Exception {
  final String message;

  ServerException({required this.message});
}

/// Permission exceptions
class PermissionException implements Exception {
  final String message;

  PermissionException({required this.message});
}
