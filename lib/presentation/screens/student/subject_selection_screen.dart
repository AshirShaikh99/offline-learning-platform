import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'content_viewer_screen.dart';

class SubjectSelectionScreen extends StatelessWidget {
  final String className;
  final List<Map<String, dynamic>> _subjects = [
    {'name': 'English', 'icon': Icons.language, 'color': Colors.black},
    {'name': 'Mathematics', 'icon': Icons.calculate, 'color': Colors.black87},
    {'name': 'Science', 'icon': Icons.science, 'color': Colors.black},
    {
      'name': 'Social Studies',
      'icon': Icons.history_edu,
      'color': Colors.black87,
    },
    {'name': 'Computer', 'icon': Icons.computer, 'color': Colors.black},
    {'name': 'Islamiat', 'icon': Icons.menu_book, 'color': Colors.black87},
    {'name': 'GK', 'icon': Icons.psychology, 'color': Colors.black},
    {'name': 'Urdu', 'icon': Icons.translate, 'color': Colors.black87},
    {'name': 'Sindhi', 'icon': Icons.text_fields, 'color': Colors.black},
  ];

  SubjectSelectionScreen({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8EAC8,
      ), // Cream background color to match login screen
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
      expandedHeight: 180,
      pinned: true,
      backgroundColor: Colors.black, // Black to match login button
      leading:
          Navigator.canPop(context)
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
              : null,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '$className Subjects',
          style: AppTheme.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          color: Colors.black, // Solid black to match login button
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [subject['color'], subject['color'].withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  subject['icon'],
                  size: 100,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(subject['icon'], color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      subject['name'],
                      style: AppTheme.titleLarge.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'View Content',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
