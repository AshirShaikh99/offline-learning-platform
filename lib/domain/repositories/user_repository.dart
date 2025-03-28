import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user.dart';

/// Interface for user repository
abstract class UserRepository {
  /// Get the current logged in user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Login with username and password
  Future<Either<Failure, User>> login(String username, String password);

  /// Register a new user
  Future<Either<Failure, User>> register(User user);

  /// Logout the current user
  Future<Either<Failure, void>> logout();

  /// Update user information
  Future<Either<Failure, User>> updateUser(User user);

  /// Get all users
  Future<Either<Failure, List<User>>> getAllUsers();

  /// Get user by id
  Future<Either<Failure, User>> getUserById(String id);

  /// Delete user
  Future<Either<Failure, void>> deleteUser(String id);
}
