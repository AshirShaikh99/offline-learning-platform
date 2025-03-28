import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/course.dart';

/// Interface for course repository
abstract class CourseRepository {
  /// Get all courses
  Future<Either<Failure, List<Course>>> getAllCourses();

  /// Get courses by class name
  Future<Either<Failure, List<Course>>> getCoursesByClassName(String className);

  /// Get course by id
  Future<Either<Failure, Course>> getCourseById(String id);

  /// Add a new course
  Future<Either<Failure, Course>> addCourse(Course course, File file);

  /// Update course
  Future<Either<Failure, Course>> updateCourse(Course course);

  /// Delete course
  Future<Either<Failure, void>> deleteCourse(String id);
}
