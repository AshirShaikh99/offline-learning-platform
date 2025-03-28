import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../core/error/failures.dart';
import '../../../core/utils/download_manager.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/file_model.dart';
import 'file_event.dart';
import 'file_state.dart';

/// File bloc that handles file download events and emits file states
class FileBloc extends Bloc<FileEvent, FileState> {
  final Box<CourseModel> courseBox;
  final _uuid = const Uuid();

  FileBloc({required this.courseBox}) : super(FileInitial()) {
    on<DownloadFileEvent>(_onDownloadFile);
    on<CheckFileStatusEvent>(_onCheckFileStatus);
    on<DeleteFileEvent>(_onDeleteFile);
    on<LoadFilesEvent>(_onLoadFiles);
    on<UploadFileEvent>(_onUploadFile);
  }

  /// Handle download file event
  Future<void> _onDownloadFile(
    DownloadFileEvent event,
    Emitter<FileState> emit,
  ) async {
    emit(FileDownloading(fileId: event.fileId));
    try {
      final filePath = await DownloadManager.downloadAndCacheFile(
        event.fileUrl,
        event.fileId,
        event.fileType,
      );
      emit(FileDownloaded(fileId: event.fileId, filePath: filePath));
    } catch (e) {
      emit(
        FileError(
          fileId: event.fileId,
          message: e is FileFailure ? e.message : e.toString(),
        ),
      );
    }
  }

  /// Handle check file status event
  Future<void> _onCheckFileStatus(
    CheckFileStatusEvent event,
    Emitter<FileState> emit,
  ) async {
    emit(FileChecking(fileId: event.fileId));
    try {
      final isDownloaded = await DownloadManager.isFileDownloaded(event.fileId);
      if (isDownloaded) {
        final filePath = await DownloadManager.getCachedFilePath(event.fileId);
        emit(FileDownloaded(fileId: event.fileId, filePath: filePath!));
      } else {
        emit(FileNotDownloaded(fileId: event.fileId));
      }
    } catch (e) {
      emit(
        FileError(
          fileId: event.fileId,
          message: e is FileFailure ? e.message : e.toString(),
        ),
      );
    }
  }

  /// Handle delete file event
  Future<void> _onDeleteFile(
    DeleteFileEvent event,
    Emitter<FileState> emit,
  ) async {
    emit(FileDeleting(fileId: event.fileId));
    try {
      await DownloadManager.deleteCachedFile(
        event.fileId,
      ); // Changed from deleteFile to deleteCachedFile
      emit(FileDeleted(fileId: event.fileId));
    } catch (e) {
      emit(
        FileError(
          fileId: event.fileId,
          message: e is FileFailure ? e.message : e.toString(),
        ),
      );
    }
  }

  /// Handle load files event
  Future<void> _onLoadFiles(
    LoadFilesEvent event,
    Emitter<FileState> emit,
  ) async {
    emit(FileLoading());
    try {
      // Get all courses for the specified class and subject
      final files =
          courseBox.values
              .where(
                (course) =>
                    course.className == event.className &&
                    course.subject == event.subject,
              )
              .map(
                (course) => FileModel(
                  id: course.id,
                  name: course.title,
                  type: course.fileType,
                  path: course.filePath,
                ),
              )
              .toList();

      emit(FilesLoaded(files: files));
    } catch (e) {
      emit(
        FileError(
          fileId: '${event.className}_${event.subject}',
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUploadFile(
    UploadFileEvent event,
    Emitter<FileState> emit,
  ) async {
    emit(FileLoading());
    try {
      // Generate unique ID for the file
      final fileId = _uuid.v4();

      // Copy file to app's documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(event.filePath);
      final savedPath = '${appDir.path}/courses/$fileId-$fileName';

      final coursesDir = Directory('${appDir.path}/courses');
      if (!await coursesDir.exists()) {
        await coursesDir.create(recursive: true);
      }

      await File(event.filePath).copy(savedPath);

      // Save course information
      final course = CourseModel(
        id: fileId,
        title: event.fileName,
        description: 'Uploaded content',
        className: event.className,
        subject: event.subject,
        fileType: event.fileType,
        filePath: savedPath,
        uploadedBy: 'admin', // Add a default value or pass it through event
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await courseBox.put(fileId, course);

      // Reload files
      add(LoadFilesEvent(className: event.className, subject: event.subject));
    } catch (e) {
      emit(FileError(fileId: 'upload', message: e.toString()));
    }
  }
}
