import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../login_screen.dart';
import 'content_management_screen.dart';

/// Subject selection screen for admins to manage content
class AdminSubjectSelectionScreen extends StatefulWidget {
  final String className;

  const AdminSubjectSelectionScreen({super.key, required this.className});

  @override
  State<AdminSubjectSelectionScreen> createState() =>
      _AdminSubjectSelectionScreenState();
}

class _AdminSubjectSelectionScreenState
    extends State<AdminSubjectSelectionScreen> {
  final List<String> _subjects = [
    'English',
    'Math',
    'Science',
    'Social Studies',
    'Computer',
    'Islamiat',
    'GK',
    'Urdu',
    'Sindhi',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen:
          (previous, current) =>
              current is Unauthenticated && previous is! AuthInitial,
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manage Content - ${widget.className}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutEvent());
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 16),
            Expanded(child: _buildSubjectGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      radius: 24,
                      child: Text(
                        state.user.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${state.user.username}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Managing content for ${widget.className}',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSubjectGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showContentManagementDialog(subject),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.7),
                    AppTheme.primaryColor.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.upload_file, color: Colors.white, size: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToContentManagement(String subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ContentManagementScreen(
              className: widget.className,
              subject: subject,
            ),
      ),
    );
  }

  void _showContentManagementDialog(String subject) {
    _navigateToContentManagement(subject);
  }
}
