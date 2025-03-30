import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../core/utils/thumbnail_utils.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/course.dart';
import '../../blocs/file/file_bloc.dart';
import '../../blocs/file/file_event.dart';
import '../../blocs/file/file_state.dart';

/// Course detail screen for viewing course content
class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late WebViewController _webViewController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _thumbnailPath;
  int _pdfTotalPages = 0;
  int _pdfCurrentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.course.isVideo) {
      _generateThumbnail();
    }
    context.read<FileBloc>().add(
      CheckFileStatusEvent(fileId: widget.course.id),
    );
  }

  Future<void> _generateThumbnail() async {
    if (widget.course.filePath.isNotEmpty) {
      final thumbnailPath = await ThumbnailUtils.generateThumbnail(
        widget.course.filePath,
      );
      if (mounted) {
        setState(() {
          _thumbnailPath = thumbnailPath;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.course.title)),
      body: Column(
        children: [_buildCourseInfo(), Expanded(child: _buildCourseContent())],
      ),
    );
  }

  Widget _buildCourseInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.course.isVideo && _thumbnailPath != null)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_thumbnailPath!), fit: BoxFit.cover),
              ),
            ),
          Text(
            widget.course.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                widget.course.isPdf
                    ? Icons.picture_as_pdf
                    : Icons.video_library,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                widget.course.isPdf ? 'PDF Document' : 'Video Content',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.class_, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                widget.course.className,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.subject, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                widget.course.subject,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseContent() {
    return BlocConsumer<FileBloc, FileState>(
      listener: (context, state) {
        if (state is FileDownloaded && state.fileId == widget.course.id) {
          if (widget.course.isVideo) {
            _initializeVideo(state.filePath);
          }
        }
      },
      builder: (context, state) {
        // Handle different file states
        if (state is FileChecking && state.fileId == widget.course.id) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FileDownloading &&
            state.fileId == widget.course.id) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Downloading file...'),
              ],
            ),
          );
        } else if (state is FileError && state.fileId == widget.course.id) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<FileBloc>().add(
                      DownloadFileEvent(
                        fileId: widget.course.id,
                        fileUrl: widget.course.filePath,
                        fileType: widget.course.fileType,
                      ),
                    );
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        } else if (state is FileNotDownloaded &&
            state.fileId == widget.course.id) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_download, size: 48),
                const SizedBox(height: 16),
                const Text('File not downloaded'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<FileBloc>().add(
                      DownloadFileEvent(
                        fileId: widget.course.id,
                        fileUrl: widget.course.filePath,
                        fileType: widget.course.fileType,
                      ),
                    );
                  },
                  child: const Text('Download'),
                ),
              ],
            ),
          );
        } else if (state is FileDownloaded &&
            state.fileId == widget.course.id) {
          if (widget.course.isPdf) {
            return _buildPdfViewer(state.filePath);
          } else if (widget.course.isVideo) {
            return _buildVideoPlayer();
          }
        }

        // Default case or unknown file type
        return const Center(child: Text('Unsupported file type'));
      },
    );
  }

  Widget _buildPdfViewer(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return const Center(child: Text('PDF file not found'));
    }

    return Column(
      children: [
        Expanded(
          child: PDFView(
            filePath: filePath,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: false,
            onRender: (pages) {
              setState(() {
                _pdfTotalPages = pages!;
              });
            },
            onPageChanged: (page, total) {
              setState(() {
                _pdfCurrentPage = page!;
              });
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Page ${_pdfCurrentPage + 1} of $_pdfTotalPages',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _initializeVideo(String filePath) async {
    _videoPlayerController = VideoPlayerController.file(File(filePath));
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      placeholder: Center(child: CircularProgressIndicator()),
    );
    setState(() {});
  }

  Widget _buildVideoPlayer() {
    if (_chewieController == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Chewie(controller: _chewieController!);
  }
}
