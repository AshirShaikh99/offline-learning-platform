import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/user.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

/// Screen for managing users (admin only)
class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _isLoading = true;
    });

    // Use the auth bloc to get all users
    context.read<AuthBloc>().stream.listen((state) {
      if (state is Authenticated) {
        // This is just to ensure we're authenticated
        context.read<AuthBloc>().add(GetAllUsersEvent());
      }
    });

    // In a real implementation, we would listen for a specific state
    // Here we're simulating the loading of users
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        // Simulated users for now
        _users = [
          User(
            id: '1',
            username: 'admin',
            password: 'admin123',
            role: AppConstants.roleAdmin,
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            updatedAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
          User(
            id: '2',
            username: 'student1',
            password: 'student123',
            role: AppConstants.roleStudent,
            className: 'Class 5',
            createdAt: DateTime.now().subtract(const Duration(days: 20)),
            updatedAt: DateTime.now().subtract(const Duration(days: 20)),
          ),
          User(
            id: '3',
            username: 'student2',
            password: 'student123',
            role: AppConstants.roleStudent,
            className: 'Class 8',
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
            updatedAt: DateTime.now().subtract(const Duration(days: 15)),
          ),
        ];
      });
    });
  }

  void _deleteUser(String id) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete User'),
            content: const Text('Are you sure you want to delete this user?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Delete user
                  context.read<AuthBloc>().add(DeleteUserEvent(id: id));
                  // Refresh user list
                  setState(() {
                    _users.removeWhere((user) => user.id == id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted successfully')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
              ? _buildEmptyUsersList()
              : _buildUsersList(),
    );
  }

  Widget _buildEmptyUsersList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No users available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Users will appear here once registered',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor:
                  user.isAdmin ? AppTheme.primaryColor : Colors.blue,
              child: Text(
                user.username.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Role: ${user.isAdmin ? "Admin" : "Student"}'),
                if (user.isStudent && user.className != null)
                  Text('Class: ${user.className}'),
                const SizedBox(height: 4),
                Text(
                  'Created: ${user.createdAt.toString().substring(0, 10)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing:
                user.isAdmin
                    ? const Icon(Icons.admin_panel_settings)
                    : IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(user.id),
                    ),
          ),
        );
      },
    );
  }
}
