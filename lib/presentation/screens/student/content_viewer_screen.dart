import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_utils.dart';
import '../../blocs/file/file_bloc.dart';
import '../../blocs/file/file_event.dart';
import '../../blocs/file/file_state.dart';
import 'pdf_viewer.dart';
import 'html_viewer.dart';

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
      backgroundColor: const Color(
        0xFFF8EAC8,
      ), // Cream background color to match login screen
      appBar: AppBar(
        backgroundColor: Colors.black, // Black to match login button
        title: Text(
          '${widget.subject} Content',
          style: AppTheme.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocBuilder<FileBloc, FileState>(
        builder: (context, state) {
          if (state is FileLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.black, // Black to match theme
                strokeWidth: 3,
              ),
            );
          }

          if (state is FileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.black54),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: AppTheme.bodyLarge.copyWith(color: Colors.black54),
                    textAlign: TextAlign.center,
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
                    Icon(Icons.folder_open, size: 60, color: Colors.black54),
                    const SizedBox(height: 16),
                    Text(
                      'No content available for this subject',
                      style: AppTheme.bodyLarge.copyWith(color: Colors.black54),
                      textAlign: TextAlign.center,
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

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFileCard(dynamic file) {
    final bool isPdf = file.fileType == AppConstants.typePdf;
    final bool isVideo = !isPdf;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.black, // Set card background to black
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isVideo)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: FutureBuilder<ChewieController?>(
                  future: _initializeVideoPlayer(file.filePath),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        color: Colors.black.withOpacity(0.1),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    }

                    if (snapshot.hasError || snapshot.data == null) {
                      return Container(
                        color: Colors.black.withOpacity(0.1),
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }

                    return Chewie(controller: snapshot.data!);
                  },
                ),
              ),
            ),
          if (isPdf)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PdfViewer(
                          filePath: file.filePath,
                          title: file.title,
                        ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        file.title,
                        style: AppTheme.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isVideo)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                file.title,
                style: AppTheme.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
