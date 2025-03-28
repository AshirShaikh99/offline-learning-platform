import 'package:hive/hive.dart';

import '../../domain/entities/course.dart';

part 'course_model.g.dart';

/// Course model for local storage with Hive
@HiveType(typeId: 1)
class CourseModel extends Course {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String title;

  @HiveField(2)
  @override
  final String description;

  @HiveField(3)
  @override
  final String filePath;

  @HiveField(4)
  @override
  final String fileType;

  @HiveField(5)
  @override
  final String className;

  @HiveField(6)
  @override
  final String uploadedBy;

  @HiveField(7)
  @override
  final DateTime createdAt;

  @HiveField(8)
  @override
  final DateTime updatedAt;

  @HiveField(9)
  @override
  final String subject;

  const CourseModel({
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
  }) : super(
         id: id,
         title: title,
         description: description,
         filePath: filePath,
         fileType: fileType,
         className: className,
         subject: subject,
         uploadedBy: uploadedBy,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Create a CourseModel from a Course entity
  factory CourseModel.fromEntity(Course course) {
    return CourseModel(
      id: course.id,
      title: course.title,
      description: course.description,
      filePath: course.filePath,
      fileType: course.fileType,
      className: course.className,
      subject: course.subject,
      uploadedBy: course.uploadedBy,
      createdAt: course.createdAt,
      updatedAt: course.updatedAt,
    );
  }

  /// Create a CourseModel from JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      filePath: json['filePath'],
      fileType: json['fileType'],
      className: json['className'],
      subject: json['subject'],
      uploadedBy: json['uploadedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert CourseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'filePath': filePath,
      'fileType': fileType,
      'className': className,
      'subject': subject,
      'uploadedBy': uploadedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of this CourseModel with the given fields replaced with the new values
  @override
  CourseModel copyWith({
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
    return CourseModel(
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
}
