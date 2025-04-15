import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/black_theme.dart';
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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;
    final isLargeScreen = screenSize.width >= 1200;

    return Scaffold(
      backgroundColor: BlackTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: BlackTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Courses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: isSmallScreen ? 20 : 24,
          ),
        ),
        elevation: 0,
      ),
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
            return Center(
              child: CircularProgressIndicator(color: BlackTheme.primaryColor),
            );
          } else if (state is CoursesLoaded) {
            return state.courses.isEmpty
                ? _buildEmptyCoursesList(screenSize)
                : _buildCoursesList(state.courses, screenSize);
          } else {
            return _buildEmptyCoursesList(screenSize);
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
        backgroundColor: BlackTheme.primaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: isSmallScreen ? 24 : 28,
        ),
      ),
    );
  }

  Widget _buildEmptyCoursesList(Size screenSize) {
    final isSmallScreen = screenSize.width < 600;
    final containerWidth =
        screenSize.width >= 1200
            ? screenSize.width * 0.4
            : (screenSize.width >= 600
                ? screenSize.width * 0.6
                : screenSize.width * 0.9);

    return Center(
      child: Container(
        width: containerWidth,
        margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
        decoration: BoxDecoration(
          color: BlackTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: BlackTheme.primaryColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: isSmallScreen ? 60 : 80,
              color: BlackTheme.primaryColor.withOpacity(0.5),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'No courses available',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              'Add a new course by clicking the + button',
              style: TextStyle(
                color: BlackTheme.subtitleColor,
                fontSize: isSmallScreen ? 13 : 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 20 : 24),
            SizedBox(
              width: double.infinity,
              height: isSmallScreen ? 44 : 50,
              child: _buildAddCourseButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList(List<Course> courses, Size screenSize) {
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;
    final isLargeScreen = screenSize.width >= 1200;

    final contentWidth =
        isLargeScreen
            ? screenSize.width * 0.7
            : (isMediumScreen ? screenSize.width * 0.8 : screenSize.width);

    return Center(
      child: Container(
        width: contentWidth,
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 16 : 24,
          horizontal: isSmallScreen ? 0 : 16,
        ),
        child: ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            return _buildCourseCard(courses[index], screenSize);
          },
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course, Size screenSize) {
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;

    // Responsive sizes
    final cardPadding = isSmallScreen ? 16.0 : 20.0;
    final iconSize = isSmallScreen ? 48.0 : 56.0;
    final titleSize = isSmallScreen ? 16.0 : 18.0;
    final subtitleSize = isSmallScreen ? 13.0 : 14.0;
    final tagSize = isSmallScreen ? 11.0 : 12.0;
    final iconButtonSize = isSmallScreen ? 20.0 : 24.0;

    final fileTypeColor =
        course.fileType == AppConstants.typePdf
            ? BlackTheme.errorColor
            : BlackTheme.accentColor;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24,
        vertical: isSmallScreen ? 8 : 12,
      ),
      elevation: 4,
      color: BlackTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: BlackTheme.dividerColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading icon
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: fileTypeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    course.fileType == AppConstants.typePdf
                        ? Icons.picture_as_pdf
                        : Icons.flash_on,
                    color: fileTypeColor,
                    size: iconSize * 0.5,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 16 : 20),
                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: titleSize,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: BlackTheme.subtitleColor,
                          fontSize: subtitleSize,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                if (!isSmallScreen) ...[
                  const SizedBox(width: 16),
                  _buildActionButtons(course, iconButtonSize),
                ],
              ],
            ),
            const SizedBox(height: 16),
            // Tags and action buttons row
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(course.className, tagSize),
                      _buildTag(course.subject, tagSize),
                    ],
                  ),
                ),
                if (isSmallScreen) _buildActionButtons(course, iconButtonSize),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Course course, double iconSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          icon: Icons.edit_outlined,
          color: BlackTheme.accentColor,
          size: iconSize,
          onTap: () => _navigateToEditScreen(course),
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          icon: Icons.delete_outline,
          color: BlackTheme.errorColor,
          size: iconSize,
          onTap: () => _showDeleteConfirmationDialog(course),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: color, size: size),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: BlackTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BlackTheme.dividerColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAddCourseButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BlackTheme.primaryColor,
            BlackTheme.primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BlackTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _navigateToAddScreen(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Add Course',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEditCourseScreen()),
    );
  }

  void _navigateToEditScreen(Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditCourseScreen(course: course),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Course course) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: BlackTheme.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete Course',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to delete "${course.title}"?',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: BlackTheme.subtitleColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: BlackTheme.subtitleColor,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      BlackTheme.errorColor,
                      BlackTheme.errorColor.withOpacity(0.7),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<CourseBloc>().add(
                      DeleteCourseEvent(id: course.id),
                    );
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
