import 'package:equatable/equatable.dart';
import '../../../data/models/course_model.dart';

/// Base class for file states
abstract class FileState extends Equatable {
  const FileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FileInitial extends FileState {}

/// File loading state
class FileLoading extends FileState {}

/// Files loaded state
class FilesLoaded extends FileState {
  final List<CourseModel> files;

  const FilesLoaded({required this.files});

  @override
  List<Object?> get props => [files];
}

/// File uploaded state
class FileUploaded extends FileState {
  final String fileId;

  const FileUploaded({required this.fileId});

  @override
  List<Object?> get props => [fileId];
}

/// File checking state
class FileChecking extends FileState {
  final String fileId;

  const FileChecking({required this.fileId});

  @override
  List<Object> get props => [fileId];
}

/// File not downloaded state
class FileNotDownloaded extends FileState {
  final String fileId;

  const FileNotDownloaded({required this.fileId});

  @override
  List<Object> get props => [fileId];
}

/// File downloading state
class FileDownloading extends FileState {
  final String fileId;

  const FileDownloading({required this.fileId});

  @override
  List<Object> get props => [fileId];
}

/// File downloaded state
class FileDownloaded extends FileState {
  final String fileId;
  final String filePath;

  const FileDownloaded({required this.fileId, required this.filePath});

  @override
  List<Object> get props => [fileId, filePath];
}

/// File deleting state
class FileDeleting extends FileState {
  final String fileId;

  const FileDeleting({required this.fileId});

  @override
  List<Object> get props => [fileId];
}

/// File deleted state
class FileDeleted extends FileState {
  final String fileId;

  const FileDeleted({required this.fileId});

  @override
  List<Object> get props => [fileId];
}

/// File error state
class FileError extends FileState {
  final String fileId;
  final String message;

  const FileError({required this.fileId, required this.message});

  @override
  List<Object> get props => [fileId, message];
}
