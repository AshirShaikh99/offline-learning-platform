import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/course/course_bloc.dart';
import '../../blocs/course/course_event.dart';
import '../../blocs/course/course_state.dart';
import '../login_screen.dart';
import 'course_detail_screen.dart';
import 'content_viewer_screen.dart';

/// Subject selection screen for students
class SubjectSelectionScreen extends StatefulWidget {
  final String className;

  const SubjectSelectionScreen({super.key, required this.className});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
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
          title: Text('Select Subject for ${widget.className}'),
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
                          'Student - ${widget.className}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please select a subject to view available content:',
                  style: TextStyle(fontSize: 14),
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
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        return _buildSubjectCard(_subjects[index]);
      },
    );
  }

  Widget _buildSubjectCard(String subject) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          // Load courses for this class and subject
          context.read<CourseBloc>().add(
            GetCoursesByClassAndSubjectEvent(
              className: widget.className,
              subject: subject,
            ),
          );

          // Navigate to a screen that shows courses for this subject
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => ContentViewerScreen(
                    className: widget.className,
                    subject: subject,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getSubjectIcon(subject),
                size: 40,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                subject,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'english':
        return Icons.menu_book;
      case 'social studies':
        return Icons.public;
      case 'computer science':
        return Icons.computer;
      case 'art':
        return Icons.palette;
      case 'music':
        return Icons.music_note;
      case 'physical education':
        return Icons.sports_basketball;
      default:
        return Icons.book;
    }
  }
}

/// Course list screen for a specific class and subject
class CourseListScreen extends StatelessWidget {
  final String className;
  final String subject;

  const CourseListScreen({
    super.key,
    required this.className,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$subject - $className')),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CourseError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is CoursesLoaded) {
            final courses = state.courses;

            if (courses.isEmpty) {
              return const Center(
                child: Text('No courses available for this subject'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Icon(
                      course.isPdf ? Icons.picture_as_pdf : Icons.flash_on,
                      color: AppTheme.primaryColor,
                    ),
                    title: Text(course.title),
                    subtitle: Text(course.description),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => CourseDetailScreen(course: course),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Select a subject to view courses'));
        },
      ),
    );
  }
}
