import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/course.dart';

/// Base class for course events
abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

/// Get all courses event
class GetAllCoursesEvent extends CourseEvent {}

/// Get courses by class name event
class GetCoursesByClassNameEvent extends CourseEvent {
  final String className;

  const GetCoursesByClassNameEvent({required this.className});

  @override
  List<Object> get props => [className];
}

/// Get courses by class name and subject event
class GetCoursesByClassAndSubjectEvent extends CourseEvent {
  final String className;
  final String subject;

  const GetCoursesByClassAndSubjectEvent({
    required this.className,
    required this.subject,
  });

  @override
  List<Object> get props => [className, subject];
}

/// Get course by id event
class GetCourseByIdEvent extends CourseEvent {
  final String id;

  const GetCourseByIdEvent({required this.id});

  @override
  List<Object> get props => [id];
}

/// Add course event
class AddCourseEvent extends CourseEvent {
  final Course course;
  final File file;

  const AddCourseEvent({required this.course, required this.file});

  @override
  List<Object> get props => [course, file];
}

/// Update course event
class UpdateCourseEvent extends CourseEvent {
  final Course course;

  const UpdateCourseEvent({required this.course});

  @override
  List<Object> get props => [course];
}

/// Delete course event
class DeleteCourseEvent extends CourseEvent {
  final String id;

  const DeleteCourseEvent({required this.id});

  @override
  List<Object> get props => [id];
}
