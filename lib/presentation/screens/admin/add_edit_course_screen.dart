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

/// Screen for adding or editing a course
class AddEditCourseScreen extends StatefulWidget {
  final Course? course;

  const AddEditCourseScreen({super.key, this.course});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedClass;
  String? _selectedSubject;
  String _selectedFileType = AppConstants.typePdf;
  File? _selectedFile;
  String? _selectedFileName;
  bool _isEditing = false;

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

  final List<String> _classes = [
    'Play Group',
    'Nursery',
    'KG',
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.course != null;
    if (_isEditing) {
      _titleController.text = widget.course!.title;
      _descriptionController.text = widget.course!.description;
      _selectedClass = widget.course!.className;
      _selectedSubject = widget.course!.subject;
      _selectedFileType = widget.course!.fileType;
      _selectedFileName = widget.course!.filePath.split('/').last;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions:
          _selectedFileType == AppConstants.typePdf ? ['pdf'] : ['swf', 'html'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
      });
    }
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      if (!_isEditing && _selectedFile == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a file')));
        return;
      }

      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to add a course'),
          ),
        );
        return;
      }

      if (_isEditing) {
        final updatedCourse = widget.course!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          className: _selectedClass!,
          subject: _selectedSubject!,
          fileType: _selectedFileType,
          updatedAt: DateTime.now(),
        );

        context.read<CourseBloc>().add(
          UpdateCourseEvent(course: updatedCourse),
        );
      } else {
        final newCourse = Course(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          filePath: '', // This will be set by the repository
          fileType: _selectedFileType,
          className: _selectedClass!,
          subject: _selectedSubject!,
          uploadedBy: authState.user.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        context.read<CourseBloc>().add(
          AddCourseEvent(course: newCourse, file: _selectedFile!),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Course' : 'Add Course',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is CourseAdded || state is CourseUpdated) {
            Navigator.of(context).pop();
          } else if (state is CourseError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Basic Information',
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _titleController,
                          style: AppTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'Course Title',
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: Icon(
                              Icons.title_outlined,
                              color: AppTheme.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.primaryColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true
                                      ? 'Please enter a title'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          style: AppTheme.bodyLarge,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Course Description',
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: Icon(
                              Icons.description_outlined,
                              color: AppTheme.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.primaryColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true
                                      ? 'Please enter a description'
                                      : null,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Course Details',
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedClass,
                            decoration: InputDecoration(
                              hintText: 'Select Class',
                              prefixIcon: Icon(
                                Icons.class_outlined,
                                color: AppTheme.primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items:
                                _classes.map((String className) {
                                  return DropdownMenuItem<String>(
                                    value: className,
                                    child: Text(className),
                                  );
                                }).toList(),
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Please select a class'
                                        : null,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedClass = newValue;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedSubject,
                            decoration: InputDecoration(
                              hintText: 'Select Subject',
                              prefixIcon: Icon(
                                Icons.subject,
                                color: AppTheme.primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items:
                                _subjects.map((String subject) {
                                  return DropdownMenuItem<String>(
                                    value: subject,
                                    child: Text(subject),
                                  );
                                }).toList(),
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Please select a subject'
                                        : null,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSubject = newValue;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Course Content',
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedFileType,
                            decoration: InputDecoration(
                              hintText: 'Select File Type',
                              prefixIcon: Icon(
                                Icons.file_present_outlined,
                                color: AppTheme.primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: AppConstants.typePdf,
                                child: const Text('PDF'),
                              ),
                              DropdownMenuItem<String>(
                                value: AppConstants.typeFlash,
                                child: const Text('Flash/HTML'),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedFileType =
                                    newValue ?? AppConstants.typePdf;
                                _selectedFile = null;
                                _selectedFileName = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: _pickFile,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.upload_file_outlined,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Upload File',
                                        style: AppTheme.bodyLarge,
                                      ),
                                      if (_selectedFileName != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          _selectedFileName!,
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed:
                                state is CourseLoading ? null : _saveCourse,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                state is CourseLoading
                                    ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      _isEditing
                                          ? 'Update Course'
                                          : 'Add Course',
                                      style: AppTheme.labelLarge.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
