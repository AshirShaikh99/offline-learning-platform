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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Manage Content - ${widget.className}',
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
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
            _buildWelcomeSection(isSmallScreen),
            const SizedBox(height: 16),
            Expanded(child: _buildSubjectGrid(isSmallScreen)),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(bool isSmallScreen) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  radius: isSmallScreen ? 24 : 28,
                  child: Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: isSmallScreen ? 24 : 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome, ${state.user.username}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Managing content for ${widget.className}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSubjectGrid(bool isSmallScreen) {
    return GridView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 2 : 3,
        crossAxisSpacing: isSmallScreen ? 12 : 16,
        mainAxisSpacing: isSmallScreen ? 12 : 16,
        childAspectRatio: isSmallScreen ? 1.3 : 1.5,
      ),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        return _buildSubjectCard(_subjects[index], isSmallScreen);
      },
    );
  }

  Widget _buildSubjectCard(String subject, bool isSmallScreen) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
      ),
      child: InkWell(
        onTap: () => _showContentManagementDialog(subject),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
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
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Icon(
                Icons.upload_file,
                color: Colors.white,
                size: isSmallScreen ? 28 : 32,
              ),
            ],
          ),
        ),
      ),
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
