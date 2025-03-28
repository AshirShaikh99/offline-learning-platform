import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/course.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/course/course_bloc.dart';
import '../../blocs/course/course_event.dart';
import '../../blocs/course/course_state.dart';
import 'add_edit_course_screen.dart';

/// Screen for managing courses (admin only)
class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    context.read<CourseBloc>().add(GetAllCoursesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Courses')),
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is CourseAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course added successfully')),
            );
            _loadCourses();
          } else if (state is CourseUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course updated successfully')),
            );
            _loadCourses();
          } else if (state is CourseDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course deleted successfully')),
            );
            _loadCourses();
          } else if (state is CourseError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CoursesLoaded) {
            return state.courses.isEmpty
                ? _buildEmptyCoursesList()
                : _buildCoursesList(state.courses);
          } else {
            return _buildEmptyCoursesList();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditCourseScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyCoursesList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No courses available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a new course by clicking the + button',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddEditCourseScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Course'),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(List<Course> courses) {
    return ListView.builder(
      itemCount: courses.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  course.fileType == AppConstants.typePdf
                      ? Colors.red.shade100
                      : Colors.blue.shade100,
              child: Icon(
                course.fileType == AppConstants.typePdf
                    ? Icons.picture_as_pdf
                    : Icons.flash_on,
                color:
                    course.fileType == AppConstants.typePdf
                        ? Colors.red
                        : Colors.blue,
              ),
            ),
            title: Text(course.title),
            subtitle: Text(
              course.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => AddEditCourseScreen(course: course),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(course);
                  },
                ),
              ],
            ),
            onTap: () {
              // View course details
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Course course) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Course'),
            content: Text('Are you sure you want to delete "${course.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<CourseBloc>().add(
                    DeleteCourseEvent(id: course.id),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
