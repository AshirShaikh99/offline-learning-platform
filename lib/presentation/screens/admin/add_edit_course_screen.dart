import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../blocs/course/course_bloc.dart';
import '../../blocs/course/course_event.dart';
import '../../blocs/course/course_state.dart';

// This is a placeholder list - replace with your actual classes
class Classes {
  static const List<String> values = [
    'Playgroup',
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
}

// This is a placeholder list - replace with your actual subjects
class Subjects {
  static const List<String> values = [
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
}

/// Screen for adding or editing a course
class AddEditCourseScreen extends StatefulWidget {
  final Course? course;

  const AddEditCourseScreen({Key? key, this.course}) : super(key: key);

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  // Controllers
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _selectedClass;
  String? _selectedSubject;
  File? _thumbnail;
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isEditing = false;
  String _selectedFileType = AppConstants.typePdf;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.course != null;
    _titleController = TextEditingController(text: widget.course?.title);
    _descriptionController = TextEditingController(
      text: widget.course?.description,
    );
    _selectedClass = widget.course?.className;
    _selectedSubject = widget.course?.subject;
    _selectedFileType = widget.course?.fileType ?? AppConstants.typePdf;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _thumbnail = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions:
          _selectedFileType == AppConstants.typePdf
              ? ['pdf', 'swf']
              : ['mp4', 'mov', 'avi', 'mkv'],
    );
    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  void _saveCourse() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedClass == null ||
        _selectedSubject == null ||
        (_thumbnail == null && !_isEditing) ||
        (_selectedFilePath == null && !_isEditing)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final DateTime now = DateTime.now();
    final course = Course(
      id: widget.course?.id ?? 'course_${now.millisecondsSinceEpoch}',
      title: _titleController.text,
      description: _descriptionController.text,
      className: _selectedClass!,
      subject: _selectedSubject!,
      filePath: widget.course?.filePath ?? '',
      fileType: _selectedFileType,
      uploadedBy: widget.course?.uploadedBy ?? 'current_user',
      createdAt: widget.course?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditing) {
      context.read<CourseBloc>().add(UpdateCourseEvent(course: course));
    } else {
      context.read<CourseBloc>().add(
        AddCourseEvent(course: course, file: File(_selectedFilePath!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourseBloc, CourseState>(
      listener: (context, state) {
        if (state is CourseAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is CourseUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is CourseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF000000),
          appBar: AppBar(
            backgroundColor: const Color(0xFF121212),
            elevation: 0,
            title: Text(
              _isEditing ? 'Edit Course' : 'Add New Course',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Course Title',
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 4,
                    icon: Icons.description,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownSection(
                    title: 'Class',
                    options: Classes.values,
                    selectedValue: _selectedClass,
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value;
                      });
                    },
                    icon: Icons.school,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownSection(
                    title: 'Subject',
                    options: Subjects.values,
                    selectedValue: _selectedSubject,
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value;
                      });
                    },
                    icon: Icons.book,
                  ),
                  const SizedBox(height: 24),
                  _buildFileTypeSelector(),
                  const SizedBox(height: 24),
                  _buildThumbnailSelector(),
                  const SizedBox(height: 24),
                  _buildFileSelector(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(state),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
          prefixIcon: Icon(icon, color: const Color(0xFFB0B0B0)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFFF2D95), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF1E1E1E),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFB0B0B0)),
          value: selectedValue,
          hint: Row(
            children: [
              Icon(icon, color: const Color(0xFFB0B0B0)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Color(0xFFB0B0B0))),
            ],
          ),
          onChanged: onChanged,
          items:
              options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(icon, color: const Color(0xFFB0B0B0)),
                      const SizedBox(width: 12),
                      Text(value, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildFileTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'File Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildFileTypeOption(
              title: 'PDF',
              value: AppConstants.typePdf,
              icon: Icons.picture_as_pdf,
            ),
            const SizedBox(width: 16),
            _buildFileTypeOption(
              title: 'Video',
              value: AppConstants.typeVideo,
              icon: Icons.video_library,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileTypeOption({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedFileType == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFileType = value;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFFF2D95) : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border:
                isSelected ? null : Border.all(color: const Color(0xFF2C2C2C)),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFFB0B0B0),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFB0B0B0),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course Thumbnail',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickThumbnail,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2C2C2C), width: 2),
            ),
            child:
                _thumbnail != null ||
                        (widget.course?.filePath != null && _isEditing)
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child:
                          _thumbnail != null
                              ? Image.file(_thumbnail!, fit: BoxFit.cover)
                              : _isEditing
                              ? Image.network(
                                widget.course!.filePath,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFFFF2D95),
                                          ),
                                    ),
                                  );
                                },
                              )
                              : null,
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to select thumbnail',
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedFileType == AppConstants.typePdf ? 'PDF File' : 'Video File',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2C2C2C), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedFileName != null ||
                    (widget.course?.filePath != null && _isEditing)) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D95).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Color(0xFFFF2D95),
                            textDirection: TextDirection.ltr,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFileName ??
                                  (widget.course?.filePath.split('/').last ??
                                      'File selected'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_selectedFileName == null &&
                    (widget.course?.filePath == null || !_isEditing)) ...[
                  Icon(
                    _selectedFileType == AppConstants.typePdf
                        ? Icons.picture_as_pdf
                        : Icons.video_library,
                    size: 32,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ],
                if (_selectedFileName == null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: Color(0xFFB0B0B0),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Click to choose file',
                          style: TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_selectedFileName != null ||
                    (widget.course?.filePath != null && _isEditing)) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Click to change file',
                    style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Supported formats: ${_selectedFileType == AppConstants.typePdf ? 'PDF/SWF' : 'MP4/MOV/AVI/MKV'}',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF808080),
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
          colors: [Color(0xFFFF2D95), Color(0xFFFF2D55)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF2D95).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _isEditing ? "Update Course" : "Add Course",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                  ),
                ),
      ),
    );
  }
}
