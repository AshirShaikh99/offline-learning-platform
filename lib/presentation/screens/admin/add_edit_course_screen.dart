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
      appBar: AppBar(title: Text(_isEditing ? 'Edit Course' : 'Add Course')),
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
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedClass,
                    decoration: const InputDecoration(
                      labelText: 'Class',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _classes.map((String className) {
                          return DropdownMenuItem<String>(
                            value: className,
                            child: Text(className),
                          );
                        }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a class';
                      }
                      return null;
                    },
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedClass = newValue;
                        _selectedSubject = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _subjects.map((String subject) {
                          return DropdownMenuItem<String>(
                            value: subject,
                            child: Text(subject),
                          );
                        }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a subject';
                      }
                      return null;
                    },
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSubject = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedFileType,
                    decoration: const InputDecoration(
                      labelText: 'File Type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: AppConstants.typePdf,
                        child: Text('PDF'),
                      ),
                      DropdownMenuItem<String>(
                        value: AppConstants.typeFlash,
                        child: Text('Flash/HTML'),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFileType = newValue ?? AppConstants.typePdf;
                        _selectedFile = null;
                        _selectedFileName = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _pickFile,
                    child: Text(_selectedFileName ?? 'Select File'),
                  ),
                  if (_selectedFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_selectedFileName!),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveCourse,
                    child: Text(_isEditing ? 'Update Course' : 'Add Course'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
