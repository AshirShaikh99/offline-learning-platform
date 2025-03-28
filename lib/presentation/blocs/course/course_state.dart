import 'package:equatable/equatable.dart';

import '../../../domain/entities/course.dart';

/// Base class for course states
abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CourseInitial extends CourseState {}

/// Loading state
class CourseLoading extends CourseState {}

/// Courses loaded state
class CoursesLoaded extends CourseState {
  final List<Course> courses;

  const CoursesLoaded({required this.courses});

  @override
  List<Object> get props => [courses];
}

/// Single course loaded state
class CourseLoaded extends CourseState {
  final Course course;

  const CourseLoaded({required this.course});

  @override
  List<Object> get props => [course];
}

/// Course added state
class CourseAdded extends CourseState {
  final Course course;

  const CourseAdded({required this.course});

  @override
  List<Object> get props => [course];
}

/// Course updated state
class CourseUpdated extends CourseState {
  final Course course;

  const CourseUpdated({required this.course});

  @override
  List<Object> get props => [course];
}

/// Course deleted state
class CourseDeleted extends CourseState {
  final String id;

  const CourseDeleted({required this.id});

  @override
  List<Object> get props => [id];
}

/// Error state
class CourseError extends CourseState {
  final String message;

  const CourseError({required this.message});

  @override
  List<Object> get props => [message];
}
