import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../error/exceptions.dart';
import 'file_utils.dart';

/// Download manager for handling file downloads and caching
class DownloadManager {
  /// Get the cached file path if it exists, otherwise return null
  static Future<String?> getCachedFilePath(String fileId) async {
    try {
      final cacheDir = await FileUtils.documentsDirectory;
      final filePath = '${cacheDir.path}/courses/$fileId';
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting cached file path: $e');
      return null;
    }
  }

  /// Check if a file is downloaded and cached
  static Future<bool> isFileDownloaded(String fileId) async {
    final filePath = await getCachedFilePath(fileId);
    return filePath != null;
  }

  /// Download a file and cache it
  static Future<String> downloadAndCacheFile(
    String fileUrl,
    String fileId,
    String fileType,
  ) async {
    try {
      // In a real app, this would download from a remote URL
      // For this offline app, we'll simulate by copying from assets or another location

      // Create cache directory if it doesn't exist
      final cacheDir = await FileUtils.documentsDirectory;
      final coursesDir = await FileUtils.createDirectoryIfNotExists(
        '${cacheDir.path}/courses',
      );

      final filePath = '${coursesDir.path}/$fileId';
      final file = File(filePath);

      // If file already exists, return its path
      if (await file.exists()) {
        return filePath;
      }

      // In a real app, download would happen here
      // For now, we'll just return the path since files are already stored locally

      return filePath;
    } catch (e) {
      throw FileException(
        message: 'Failed to download and cache file: ${e.toString()}',
      );
    }
  }

  /// Delete a cached file
  static Future<void> deleteCachedFile(String fileId) async {
    try {
      final filePath = await getCachedFilePath(fileId);
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      throw FileException(
        message: 'Failed to delete cached file: ${e.toString()}',
      );
    }
  }

  /// Clear all cached files
  static Future<void> clearCache() async {
    try {
      final cacheDir = await FileUtils.documentsDirectory;
      final coursesDir = Directory('${cacheDir.path}/courses');
      if (await coursesDir.exists()) {
        await coursesDir.delete(recursive: true);
        await FileUtils.createDirectoryIfNotExists(coursesDir.path);
      }
    } catch (e) {
      throw FileException(message: 'Failed to clear cache: ${e.toString()}');
    }
  }
}
