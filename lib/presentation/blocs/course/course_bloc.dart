import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/course_repository.dart';
import 'course_event.dart';
import 'course_state.dart';

/// Course bloc that handles course events and emits course states
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository courseRepository;

  CourseBloc({required this.courseRepository}) : super(CourseInitial()) {
    on<GetAllCoursesEvent>(_onGetAllCourses);
    on<GetCoursesByClassNameEvent>(_onGetCoursesByClassName);
    on<GetCoursesByClassAndSubjectEvent>(_onGetCoursesByClassAndSubject);
    on<GetCourseByIdEvent>(_onGetCourseById);
    on<AddCourseEvent>(_onAddCourse);
    on<UpdateCourseEvent>(_onUpdateCourse);
    on<DeleteCourseEvent>(_onDeleteCourse);
  }

  /// Handle get all courses event
  Future<void> _onGetAllCourses(
    GetAllCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());
    final result = await courseRepository.getAllCourses();
    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (courses) => emit(CoursesLoaded(courses: courses)),
    );
  }

  /// Handle get courses by class name event
  Future<void> _onGetCoursesByClassName(
    GetCoursesByClassNameEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());
    final result = await courseRepository.getCoursesByClassName(
      event.className,
    );
    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (courses) => emit(CoursesLoaded(courses: courses)),
    );
  }

  /// Handle get courses by class name and subject event
  Future<void> _onGetCoursesByClassAndSubject(
    GetCoursesByClassAndSubjectEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());
    final result = await courseRepository.getCoursesByClassName(
      event.className,
    );
    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (courses) => emit(
        CoursesLoaded(
          courses:
              courses
                  .where((course) => course.subject == event.subject)
                  .toList(),
        ),
      ),
    );
  }

  /// Handle get course by id event
  Future<void> _onGetCourseById(
    GetCourseByIdEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());
    final result = await courseRepository.getCourseById(event.id);
    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (course) => emit(CourseLoaded(course: course)),
    );
  }

  /// Handle add course event
  Future<void> _onAddCourse(
    AddCourseEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());
    final result = await courseRepository.addCourse(event.course, event.file);
    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (course) => emit(CourseAdded(course: course)),
    );
  }

  /// Handle update course event
  Future<void> _onUpdateCourse(
    UpdateCourseEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());
    final result = await courseRepository.updateCourse(event.course);
    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (course) => emit(CourseUpdated(course: course)),
    );
  }

  /// Handle delete course event
  Future<void> _onDeleteCourse(
    DeleteCourseEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());
    final result = await courseRepository.deleteCourse(event.id);
    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (_) => emit(CourseDeleted(id: event.id)),
    );
  }
}
