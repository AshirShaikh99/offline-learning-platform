import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_local_data_source.dart';
import '../models/course_model.dart';

/// Implementation of the CourseRepository interface
class CourseRepositoryImpl implements CourseRepository {
  final CourseLocalDataSource localDataSource;

  CourseRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Course>>> getAllCourses() async {
    try {
      final courses = await localDataSource.getAllCourses();
      return Right(courses);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Course>>> getCoursesByClassName(
    String className,
  ) async {
    try {
      final courses = await localDataSource.getCoursesByClassName(className);
      return Right(courses);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Course>> getCourseById(String id) async {
    try {
      final course = await localDataSource.getCourseById(id);
      return Right(course);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Course>> addCourse(Course course, File file) async {
    try {
      final courseModel = CourseModel.fromEntity(course);
      final addedCourse = await localDataSource.addCourse(courseModel, file);
      return Right(addedCourse);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on FileException catch (e) {
      return Left(FileFailure(message: e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Course>> updateCourse(Course course) async {
    try {
      final courseModel = CourseModel.fromEntity(course);
      final updatedCourse = await localDataSource.updateCourse(courseModel);
      return Right(updatedCourse);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCourse(String id) async {
    try {
      await localDataSource.deleteCourse(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on FileException catch (e) {
      return Left(FileFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
