import 'package:equatable/equatable.dart';

/// Base class for file events
abstract class FileEvent extends Equatable {
  const FileEvent();

  @override
  List<Object?> get props => [];
}

/// Download file event
class DownloadFileEvent extends FileEvent {
  final String fileId;
  final String fileUrl;
  final String fileType;

  const DownloadFileEvent({
    required this.fileId,
    required this.fileUrl,
    required this.fileType,
  });

  @override
  List<Object> get props => [fileId, fileUrl, fileType];
}

/// Check file status event
class CheckFileStatusEvent extends FileEvent {
  final String fileId;

  const CheckFileStatusEvent({required this.fileId});

  @override
  List<Object> get props => [fileId];
}

/// Delete file event
class DeleteFileEvent extends FileEvent {
  final String fileId;
  final String fileName;
  final String className;
  final String subject;

  const DeleteFileEvent({
    required this.fileId,
    required this.fileName,
    required this.className,
    required this.subject,
  });

  @override
  List<Object> get props => [fileName, className, subject];
}

/// Upload file event
class UploadFileEvent extends FileEvent {
  final String filePath;
  final String fileName;
  final String className;
  final String subject;
  final String fileType;

  const UploadFileEvent({
    required this.filePath,
    required this.fileName,
    required this.className,
    required this.subject,
    required this.fileType,
  });

  @override
  List<Object> get props => [filePath, fileName, className, subject, fileType];
}

/// Load files event
class LoadFilesEvent extends FileEvent {
  final String className;
  final String subject;

  const LoadFilesEvent({required this.className, required this.subject});

  @override
  List<Object> get props => [className, subject];
}
