import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'content_viewer_screen.dart';

class SubjectSelectionScreen extends StatelessWidget {
  final String className;
  final List<Map<String, dynamic>> _subjects = [
    {'name': 'Mathematics', 'icon': Icons.calculate, 'color': Colors.blue},
    {'name': 'Science', 'icon': Icons.science, 'color': Colors.green},
    {'name': 'English', 'icon': Icons.language, 'color': Colors.purple},
    {'name': 'History', 'icon': Icons.history_edu, 'color': Colors.orange},
    {'name': 'Geography', 'icon': Icons.public, 'color': Colors.teal},
    {'name': 'Physics', 'icon': Icons.flash_on, 'color': Colors.red},
  ];

  SubjectSelectionScreen({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _buildSubjectGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('$className Subjects'),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectGrid(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final subject = _subjects[index];
        return _buildSubjectCard(context, subject);
      }, childCount: _subjects.length),
    );
  }

  Widget _buildSubjectCard(BuildContext context, Map<String, dynamic> subject) {
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ContentViewerScreen(
                    className: className,
                    subject: subject['name'],
                  ),
            ),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: subject['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: subject['color'].withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                subject['icon'],
                size: 100,
                color: subject['color'].withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(subject['icon'], color: subject['color'], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    subject['name'],
                    style: TextStyle(
                      color: subject['color'],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to view content',
                    style: TextStyle(
                      color: subject['color'].withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
