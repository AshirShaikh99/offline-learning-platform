import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Interface for user local data source
abstract class UserLocalDataSource {
  /// Get the current logged in user
  Future<UserModel?> getCurrentUser();

  /// Login with username and password
  Future<UserModel> login(String username, String password);

  /// Register a new user
  Future<UserModel> register(UserModel user);

  /// Logout the current user
  Future<void> logout();

  /// Update user information
  Future<UserModel> updateUser(UserModel user);

  /// Get all users
  Future<List<UserModel>> getAllUsers();

  /// Get user by id
  Future<UserModel> getUserById(String id);

  /// Delete user
  Future<void> deleteUser(String id);
}

/// Implementation of the UserLocalDataSource interface
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final Box<UserModel> userBox;
  final Box<String> settingsBox;
  final Uuid uuid;

  UserLocalDataSourceImpl({
    required this.userBox,
    required this.settingsBox,
    required this.uuid,
  });

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUserId = settingsBox.get('current_user_id');
      if (currentUserId == null) {
        return null;
      }

      final user = userBox.get(currentUserId);
      if (user == null) {
        throw CacheException(message: 'User not found');
      }

      return user;
    } catch (e) {
      if (e is CacheException) {
        throw e;
      }
      throw CacheException(
        message: 'Failed to get current user: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final users = userBox.values.toList();
      final user = users.firstWhere(
        (user) => user.username == username && user.password == password,
        orElse:
            () =>
                throw AuthException(
                  message: AppConstants.errorInvalidCredentials,
                ),
      );

      await settingsBox.put('current_user_id', user.id);

      return user;
    } catch (e) {
      if (e is AuthException) {
        throw e;
      }
      throw CacheException(message: 'Failed to login: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(UserModel user) async {
    try {
      // Check if username already exists
      final users = userBox.values.toList();
      final existingUser =
          users.where((u) => u.username == user.username).toList();

      if (existingUser.isNotEmpty) {
        throw AuthException(message: AppConstants.errorUsernameExists);
      }

      // Save user to Hive box
      await userBox.put(user.id, user);

      // Set as current user
      await settingsBox.put('current_user_id', user.id);

      return user;
    } catch (e) {
      if (e is AuthException) {
        throw e;
      }
      throw CacheException(message: 'Failed to register: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await settingsBox.delete('current_user_id');
    } catch (e) {
      throw CacheException(message: 'Failed to logout: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      await userBox.put(user.id, user);
      return user;
    } catch (e) {
      throw CacheException(message: 'Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      return userBox.values.toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get all users: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getUserById(String id) async {
    try {
      final user = userBox.get(id);
      if (user == null) {
        throw CacheException(message: 'User not found');
      }
      return user;
    } catch (e) {
      if (e is CacheException) {
        throw e;
      }
      throw CacheException(message: 'Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await userBox.delete(id);
    } catch (e) {
      throw CacheException(message: 'Failed to delete user: ${e.toString()}');
    }
  }
}
