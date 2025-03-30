import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailUtils {
  static Future<String?> generateThumbnail(String videoPath) async {
    try {
      debugPrint('Attempting to generate thumbnail for: $videoPath');

      if (videoPath.isEmpty) {
        debugPrint('Video path is empty');
        return null;
      }

      // Check if the video file exists
      final file = File(videoPath);
      if (!await file.exists()) {
        debugPrint('Video file does not exist: $videoPath');
        return null;
      }

      // Get the file size to verify it's a valid video file
      final fileSize = await file.length();
      debugPrint('Video file size: $fileSize bytes');

      // Create a unique filename for the thumbnail
      final fileName = 'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = '${tempDir.path}/$fileName';

      debugPrint('Attempting to generate thumbnail at: $thumbnailPath');

      // Generate the thumbnail with more specific parameters
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbnailPath,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 0, // 0 means original size
        maxWidth: 0, // 0 means original size
        quality: 100, // Higher quality
        timeMs: 0, // Get thumbnail from first frame
      );

      if (thumbnail == null) {
        debugPrint('Failed to generate thumbnail');
        return null;
      }

      // Verify the thumbnail was created
      final thumbnailFile = File(thumbnail);
      if (!await thumbnailFile.exists()) {
        debugPrint('Thumbnail file was not created');
        return null;
      }

      debugPrint('Thumbnail generated successfully at: $thumbnail');
      return thumbnail;
    } catch (e, stackTrace) {
      debugPrint('Error generating thumbnail: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<void> clearThumbnailCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailDir = Directory(tempDir.path);
      if (await thumbnailDir.exists()) {
        await for (var entity in thumbnailDir.list()) {
          if (entity is File &&
              entity.path.contains('thumb_') &&
              entity.path.endsWith('.jpg')) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing thumbnail cache: $e');
    }
  }
}
