import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

/// Course entity representing a course in the application
class Course extends Equatable {
  final String id;
  final String title;
  final String description;
  final String filePath;
  final String fileType; // pdf or flash
  final String className; // The class/grade this course belongs to
  final String subject;
  final String uploadedBy; // User ID of the admin who uploaded this course
  final DateTime createdAt;
  final DateTime updatedAt;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.filePath,
    required this.fileType,
    required this.className,
    required this.subject,
    required this.uploadedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if course is PDF
  bool get isPdf => fileType == AppConstants.typePdf;

  /// Check if course is Video
  bool get isVideo => fileType == AppConstants.typeVideo;

  /// Create a copy of this course with the given fields replaced with the new values
  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? filePath,
    String? fileType,
    String? className,
    String? subject,
    String? uploadedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      className: className ?? this.className,
      subject: subject ?? this.subject,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object> get props => [
    id,
    title,
    description,
    filePath,
    fileType,
    className,
    uploadedBy,
    createdAt,
    updatedAt,
  ];
}
