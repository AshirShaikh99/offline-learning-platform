import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/file_utils.dart';
import '../models/course_model.dart';

/// Interface for course local data source
abstract class CourseLocalDataSource {
  /// Get all courses
  Future<List<CourseModel>> getAllCourses();

  /// Get courses by class name
  Future<List<CourseModel>> getCoursesByClassName(String className);

  /// Get course by id
  Future<CourseModel> getCourseById(String id);

  /// Add a new course
  Future<CourseModel> addCourse(CourseModel course, File file);

  /// Update course
  Future<CourseModel> updateCourse(CourseModel course);

  /// Delete course
  Future<void> deleteCourse(String id);
}

/// Implementation of the CourseLocalDataSource interface
class CourseLocalDataSourceImpl implements CourseLocalDataSource {
  final Box<CourseModel> courseBox;
  final Uuid uuid;

  CourseLocalDataSourceImpl({required this.courseBox, required this.uuid});

  @override
  Future<List<CourseModel>> getAllCourses() async {
    try {
      return courseBox.values.toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get all courses: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<CourseModel>> getCoursesByClassName(String className) async {
    try {
      final courses =
          courseBox.values
              .where((course) => course.className == className)
              .toList();
      return courses;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get courses by class name: ${e.toString()}',
      );
    }
  }

  @override
  Future<CourseModel> getCourseById(String id) async {
    try {
      final course = courseBox.get(id);
      if (course == null) {
        throw CacheException(message: 'Course not found');
      }

      return course;
    } catch (e) {
      if (e is CacheException) {
        throw e;
      }
      throw CacheException(
        message: 'Failed to get course by id: ${e.toString()}',
      );
    }
  }

  @override
  Future<CourseModel> addCourse(CourseModel course, File file) async {
    try {
      // Create courses directory if it doesn't exist
      final appDir = await getApplicationDocumentsDirectory();
      final coursesDir = await FileUtils.createDirectoryIfNotExists(
        '${appDir.path}/courses',
      );

      // Generate a unique file name
      final fileName = FileUtils.generateUniqueFileName(
        file.path.split('/').last,
      );
      final destinationPath = '${coursesDir.path}/$fileName';

      // Copy the file to the courses directory
      final copiedFile = await FileUtils.copyFile(file, destinationPath);

      // Generate a new ID if not provided
      final newCourse = course.copyWith(
        id: course.id.isEmpty ? uuid.v4() : course.id,
        filePath: copiedFile.path,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the course
      await courseBox.put(newCourse.id, newCourse);

      return newCourse;
    } catch (e) {
      if (e is FileException || e is StorageException) {
        throw e;
      }
      throw CacheException(message: 'Failed to add course: ${e.toString()}');
    }
  }

  @override
  Future<CourseModel> updateCourse(CourseModel course) async {
    try {
      final existingCourse = courseBox.get(course.id);
      if (existingCourse == null) {
        throw CacheException(message: 'Course not found');
      }

      final updatedCourse = course.copyWith(updatedAt: DateTime.now());

      await courseBox.put(course.id, updatedCourse);

      return updatedCourse;
    } catch (e) {
      if (e is CacheException) {
        throw e;
      }
      throw CacheException(message: 'Failed to update course: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCourse(String id) async {
    try {
      final course = courseBox.get(id);
      if (course == null) {
        throw CacheException(message: 'Course not found');
      }

      // Delete the file
      await FileUtils.deleteFile(course.filePath);

      // Delete the course from the box
      await courseBox.delete(id);
    } catch (e) {
      if (e is CacheException || e is FileException) {
        throw e;
      }
      throw CacheException(message: 'Failed to delete course: ${e.toString()}');
    }
  }
}
