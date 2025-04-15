import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_utils.dart';
import '../../../domain/entities/course.dart';
import '../../blocs/file/file_bloc.dart';
import '../../blocs/file/file_event.dart';
import '../../blocs/file/file_state.dart';
import 'pdf_viewer.dart';
import 'html_viewer.dart';
import '../../blocs/course/course_bloc.dart';
import '../../blocs/course/course_event.dart';
import '../../blocs/course/course_state.dart';
import 'course_detail_screen.dart';

/// Content viewer screen for students to view uploaded content
class ContentViewerScreen extends StatefulWidget {
  final String className;
  final String subject;

  const ContentViewerScreen({
    super.key,
    required this.className,
    required this.subject,
  });

  @override
  State<ContentViewerScreen> createState() => _ContentViewerScreenState();
}

class _ContentViewerScreenState extends State<ContentViewerScreen> {
  final Map<String, ChewieController?> _videoControllers = {};

  @override
  void dispose() {
    _disposeAllControllers();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Clear controllers when dependencies change (including hot restart)
    _disposeAllControllers();
  }

  void _disposeAllControllers() {
    for (var controller in _videoControllers.values) {
      if (controller != null) {
        controller.videoPlayerController.dispose();
        controller.dispose();
      }
    }
    _videoControllers.clear();
  }

  Future<ChewieController?> _initializeVideoPlayer(String videoPath) async {
    // Dispose existing controller for this video if it exists
    if (_videoControllers.containsKey(videoPath)) {
      final existingController = _videoControllers[videoPath];
      if (existingController != null) {
        existingController.videoPlayerController.dispose();
        existingController.dispose();
        _videoControllers.remove(videoPath);
      }
    }

    try {
      final videoPlayerController = VideoPlayerController.file(File(videoPath));
      await videoPlayerController.initialize();

      final chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: false,
        looping: false,
        aspectRatio: videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: Container(
          color: Colors.black.withOpacity(0.1),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );

      _videoControllers[videoPath] = chewieController;
      return chewieController;
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<FileBloc>().add(
      LoadFilesEvent(className: widget.className, subject: widget.subject),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          '${widget.subject} Content',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFF2D95).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFFFF2D95),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<FileBloc, FileState>(
          builder: (context, state) {
            if (state is FileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF2D95)),
              );
            }

            if (state is FileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: const Color(0xFFFF2D95),
                      size: 56,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FileBloc>().add(
                          LoadFilesEvent(
                            className: widget.className,
                            subject: widget.subject,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2D95),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is FilesLoaded) {
              if (state.files.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFFFF2D95),
                        size: 56,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No content available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for updates',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.files.length,
                itemBuilder: (context, index) {
                  final file = state.files[index];
                  return _buildFileCard(file);
                },
              );
            }

            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF2D95)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFileCard(Course file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF121212), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF2D95).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToContent(file),
            splashColor: const Color(0xFFFF2D95).withOpacity(0.1),
            highlightColor: const Color(0xFFFF2D95).withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2D95).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getIconForContent(file.fileType),
                          color: const Color(0xFFFF2D95),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              file.description ?? 'No description available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          file.fileType.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'View Content',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForContent(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.play_circle_fill;
      case 'html':
        return Icons.web;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _navigateToContent(Course file) {
    if (file.fileType == 'pdf' && file.filePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  PdfViewer(title: file.title, filePath: file.filePath!),
        ),
      );
    } else if (file.fileType == 'html' && file.filePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  HtmlViewer(title: file.title, filePath: file.filePath!),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseDetailScreen(course: file),
        ),
      );
    }
  }
}
