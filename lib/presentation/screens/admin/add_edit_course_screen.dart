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
  String? _selectedFileType;
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
    'Playgroup', // Changed from 'Play Group'
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
      _selectedClass = _classes.firstWhere(
        (c) => c == widget.course!.className,
        orElse: () => widget.course!.className,
      );
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
          fileType: _selectedFileType ?? AppConstants.typePdf,
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
      ), // Match register screen background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                constraints: const BoxConstraints(
                  maxWidth: 600, // Maximum width for larger screens
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'Edit Course' : 'Add New Course',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
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
                      _buildDropdown<String>(
                        value: _selectedClass,
                        items: _classes,
                        hintText: 'Class',
                        icon: Icons.class_outlined,
                        onChanged: (value) {
                          setState(() {
                            _selectedClass = value;
                            _selectedSubject =
                                null; // Reset subject when class changes
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Please select a class' : null,
                        itemBuilder: (item) => item,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown<String>(
                        value: _selectedSubject,
                        items: _subjects,
                        hintText: 'Subject',
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
                        itemBuilder: (item) => item,
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
                      _buildDropdown<String>(
                        value: _selectedFileType,
                        items: [AppConstants.typePdf, AppConstants.typeFlash],
                        hintText: 'File Type',
                        icon: Icons.file_present_outlined,
                        onChanged: (value) {
                          setState(() {
                            _selectedFileType = value;
                            _selectedFile = null;
                            _selectedFileName = null;
                          });
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Please select a file type'
                                    : null,
                        itemBuilder:
                            (item) =>
                                item == AppConstants.typePdf
                                    ? 'PDF Document'
                                    : 'Flash/HTML Content',
                      ),
                      const SizedBox(height: 24),
                      _buildFileUploadSection(),
                      const SizedBox(height: 40),
                      _buildSubmitButton(state),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintText,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.grey),
              fillColor: Colors.transparent,
              filled: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    T? value,
    required List<T> items,
    required String hintText,
    required IconData icon,
    required void Function(T?) onChanged,
    required String? Function(T?)? validator,
    required String Function(T) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintText,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            hint: Text(
              'Select ${hintText.toLowerCase()}',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              prefixIcon: Icon(icon, color: Colors.grey),
              fillColor: Colors.transparent,
              filled: true,
            ),
            style: TextStyle(
              fontSize: 16,
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
            dropdownColor: Theme.of(context).cardColor,
            items:
                items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      itemBuilder(item),
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.black,
                      ),
                    ),
                  );
                }).toList(),
            validator: validator,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course File',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickFile,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color:
                    _selectedFileName != null
                        ? Colors.green.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _selectedFileName != null
                          ? Icons.check_circle_outline
                          : Icons.upload_file_outlined,
                      color:
                          _selectedFileName != null
                              ? Colors.green
                              : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedFileName ?? 'No file chosen',
                        style: TextStyle(
                          color:
                              _selectedFileName != null
                                  ? Colors.black
                                  : Colors.grey.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (_selectedFileName == null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Click to choose file',
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_selectedFileName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Click to change file',
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Supported formats: ${_selectedFileType == AppConstants.typePdf ? 'PDF/SWF' : 'HTML/SWF'}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(CourseState state) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.black, Color(0xFF333333)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: state is CourseLoading ? null : _saveCourse,
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  _isEditing ? 'Update Course' : 'Add Course',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
      ),
    );
  }
}
