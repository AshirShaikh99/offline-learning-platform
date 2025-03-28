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
      backgroundColor: const Color(
        0xFFF8E8C8,
      ), // Cream background color to match login screen
      appBar: AppBar(
        backgroundColor: Colors.black, // Black to match login button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Course' : 'Add Course',
          style: AppTheme.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _titleController,
                        hintText: 'Course Title',
                        icon: Icons.title_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        hintText: 'Course Description',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Course Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDropdown(
                        value: _selectedClass,
                        items: _classes,
                        hintText: 'Select Class',
                        icon: Icons.class_outlined,
                        onChanged: (value) {
                          setState(() {
                            _selectedClass = value;
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Please select a class' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        value: _selectedSubject,
                        items: _subjects,
                        hintText: 'Select Subject',
                        icon: Icons.subject,
                        onChanged: (value) {
                          setState(() {
                            _selectedSubject = value;
                          });
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Please select a subject'
                                    : null,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Course Content',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDropdown(
                        value: _selectedFileType,
                        items: [AppConstants.typePdf, AppConstants.typeFlash],
                        hintText: 'Select File Type',
                        icon: Icons.file_present_outlined,
                        onChanged: (value) {
                          setState(() {
                            _selectedFileType = value!;
                            _selectedFile = null;
                            _selectedFileName = null;
                          });
                        },
                        itemBuilder:
                            (item) =>
                                item == AppConstants.typePdf
                                    ? 'PDF'
                                    : 'Flash/HTML',
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: _pickFile,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.upload_file_outlined,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedFileName ?? 'Upload File',
                                      style: TextStyle(
                                        color:
                                            _selectedFileName != null
                                                ? Colors.black
                                                : Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black, Color(0xFF333333)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ElevatedButton(
                            onPressed:
                                state is CourseLoading ? null : _saveCourse,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
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
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.grey),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String hintText,
    required IconData icon,
    required Function(T?) onChanged,
    String? Function(T?)? validator,
    String Function(T)? itemBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.grey),
        ),
        style: TextStyle(fontSize: 16, color: Colors.black),
        dropdownColor: Colors.white,
        items:
            items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemBuilder != null ? itemBuilder(item) : item.toString(),
                ),
              );
            }).toList(),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}
