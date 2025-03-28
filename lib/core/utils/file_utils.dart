import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../error/exceptions.dart';

/// Utility class for file operations
class FileUtils {
  static const Uuid _uuid = Uuid();

  /// Get the application documents directory
  static Future<Directory> get documentsDirectory async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      throw StorageException(
        message: 'Failed to get documents directory: ${e.toString()}',
      );
    }
  }

  /// Get the application temporary directory
  static Future<Directory> get temporaryDirectory async {
    try {
      return await getTemporaryDirectory();
    } catch (e) {
      throw StorageException(
        message: 'Failed to get temporary directory: ${e.toString()}',
      );
    }
  }

  /// Generate a unique file name
  static String generateUniqueFileName(String originalFileName) {
    final String extension = originalFileName.split('.').last;
    final String uniqueId = _uuid.v4();
    return '$uniqueId.$extension';
  }

  /// Create a directory if it doesn't exist
  static Future<Directory> createDirectoryIfNotExists(String path) async {
    try {
      final Directory directory = Directory(path);
      if (await directory.exists()) {
        return directory;
      }
      return await directory.create(recursive: true);
    } catch (e) {
      throw StorageException(
        message: 'Failed to create directory: ${e.toString()}',
      );
    }
  }

  /// Copy a file to a new location
  static Future<File> copyFile(File sourceFile, String destinationPath) async {
    try {
      return await sourceFile.copy(destinationPath);
    } catch (e) {
      throw FileException(message: 'Failed to copy file: ${e.toString()}');
    }
  }

  /// Delete a file
  static Future<void> deleteFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileException(message: 'Failed to delete file: ${e.toString()}');
    }
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        final int bytes = await file.length();
        return bytes / (1024 * 1024);
      }
      return 0.0;
    } catch (e) {
      throw FileException(message: 'Failed to get file size: ${e.toString()}');
    }
  }

  /// Check if file exists
  static Future<bool> fileExists(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.exists();
    } catch (e) {
      throw FileException(
        message: 'Failed to check if file exists: ${e.toString()}',
      );
    }
  }

  /// Get file extension
  static String getFileExtension(String filePath) {
    try {
      return filePath.split('.').last.toLowerCase();
    } catch (e) {
      throw FileException(
        message: 'Failed to get file extension: ${e.toString()}',
      );
    }
  }

  /// Check if file is PDF
  static bool isPdf(String filePath) {
    return getFileExtension(filePath) == 'pdf';
  }

  /// Check if file is Flash
  static bool isFlash(String filePath) {
    return getFileExtension(filePath) == 'swf';
  }
}
