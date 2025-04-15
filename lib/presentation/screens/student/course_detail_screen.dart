import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/course.dart';
import '../../blocs/file/file_bloc.dart';
import '../../blocs/file/file_event.dart';
import '../../blocs/file/file_state.dart';
import 'pdf_viewer.dart';
import 'html_viewer.dart';

/// Course detail screen for viewing course content
class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  WebViewController? _webViewController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _thumbnailPath;
  int _pdfTotalPages = 0;
  int _pdfCurrentPage = 0;
  bool _isVideoInitializing = false;
  bool _isVideoInitialized = false;
  bool _hasBeenInitialized =
      false; // Track if video has been initialized before
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    context.read<FileBloc>().add(
      CheckFileStatusEvent(fileId: widget.course.id),
    );

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuint),
    );

    // Start animation
    _animationController.forward();

    // Initialize video player if it's a video
    if (widget.course.fileType == 'video' &&
        widget.course.filePath != null &&
        !_hasBeenInitialized) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    // Don't reinitialize if we're already initialized and not disposed
    if (_isVideoInitialized &&
        _videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      return;
    }

    // Don't set loading state to true if we're in the process of returning to the screen
    bool shouldShowLoading = true;
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      shouldShowLoading = false;
    }

    if (shouldShowLoading) {
      setState(() {
        _isVideoInitializing = true;
      });
    }

    try {
      final videoFile = File(widget.course.filePath!);
      if (await videoFile.exists()) {
        // Dispose existing controllers to prevent memory leaks
        _videoPlayerController?.dispose();
        _chewieController?.dispose();

        _videoPlayerController = VideoPlayerController.file(videoFile);
        await _videoPlayerController!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: false,
          looping: false,
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFFFF2D95),
            handleColor: const Color(0xFFFF2D95),
            backgroundColor: Colors.grey[900]!,
            bufferedColor: Colors.grey[600]!,
          ),
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF2D95)),
              ),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFFF2D95),
                    size: 42,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $errorMessage',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );

        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
            _isVideoInitializing = false;
            _hasBeenInitialized = true; // Mark as having been initialized
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isVideoInitializing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.course.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
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
          onPressed: () {
            // Navigate all the way back to the dashboard
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(position: _slideAnimation, child: child),
            );
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('Preview'),
                const SizedBox(height: 16),
                _buildContentPreview(),
                const SizedBox(height: 24),
                _buildSectionTitle('Description'),
                const SizedBox(height: 16),
                _buildDescriptionCard(),
                const SizedBox(height: 24),
                _buildActionButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A1A1A), const Color(0xFF121212)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF2D95).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2D95).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getIconForContent(widget.course.fileType),
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
                      widget.course.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                        widget.course.fileType.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.class_, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Class: ${widget.course.className}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.subject, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Subject: ${widget.course.subject}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFFF2D95),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        widget.course.description ?? 'No description available.',
        style: TextStyle(color: Colors.grey[300], fontSize: 15, height: 1.5),
      ),
    );
  }

  Widget _buildContentPreview() {
    if (widget.course.fileType == 'video') {
      if (_isVideoInitializing) {
        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF2D95)),
            ),
          ),
        );
      }

      if (_isVideoInitialized && _chewieController != null) {
        return Hero(
          tag: 'video_${widget.course.id}',
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Chewie(controller: _chewieController!),
              ),
            ),
          ),
        );
      }
    }

    // For other content types or if video failed to initialize
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForContent(widget.course.fileType),
              color: const Color(0xFFFF2D95),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              widget.course.fileType == 'video'
                  ? 'Video preview not available'
                  : 'Preview not available',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Click the button below to view content',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    // Don't show the action button for videos
    if (widget.course.fileType == 'video') {
      return const SizedBox.shrink(); // This will hide the button for video content
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _openContent,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF2D95),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIconForAction(widget.course.fileType), size: 20),
            const SizedBox(width: 8),
            Text(
              _getActionText(widget.course.fileType),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
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

  IconData _getIconForAction(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.play_arrow_rounded;
      case 'html':
        return Icons.web_asset;
      default:
        return Icons.open_in_new;
    }
  }

  String _getActionText(String type) {
    switch (type) {
      case 'pdf':
        return 'Open PDF Document';
      case 'html':
        return 'Open Interactive Content';
      default:
        return 'View Content';
    }
  }

  void _openContent() {
    // First, handle loading state
    setState(() {
      _isVideoInitializing = false;
    });

    try {
      if (widget.course.fileType == 'pdf' && widget.course.filePath != null) {
        // Check if file exists before navigating
        final pdfFile = File(widget.course.filePath!);
        if (!pdfFile.existsSync()) {
          _showContentError('PDF file not found');
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PdfViewer(
                  title: widget.course.title,
                  filePath: widget.course.filePath!,
                ),
          ),
        ).then((_) {
          // Ensure we don't show loading indicator when returning
          if (mounted) {
            setState(() {
              _isVideoInitializing = false;
            });
          }
        });
      } else if (widget.course.fileType == 'video' &&
          widget.course.filePath != null) {
        // Check if file exists before navigating
        final videoFile = File(widget.course.filePath!);
        if (!videoFile.existsSync()) {
          _showContentError('Video file not found');
          return;
        }

        // Set loading state to false before navigating
        setState(() {
          _isVideoInitializing = false;
        });

        // Create a full screen video player with enhanced animations
        Navigator.of(context)
            .push(
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) => Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        backgroundColor: Colors.black,
                        elevation: 0,
                        title: Text(
                          widget.course.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        iconTheme: const IconThemeData(color: Colors.white),
                      ),
                      body: SafeArea(
                        child: Hero(
                          tag: 'video_${widget.course.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Center(
                              child: FutureBuilder(
                                future:
                                    VideoPlayerController.file(
                                      videoFile,
                                    ).initialize(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    final controller =
                                        snapshot.data as VideoPlayerController?;
                                    if (controller == null) {
                                      return const Center(
                                        child: Text(
                                          'Error loading video',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }

                                    final chewieController = ChewieController(
                                      videoPlayerController: controller,
                                      autoPlay: true,
                                      looping: false,
                                      aspectRatio: controller.value.aspectRatio,
                                      allowFullScreen: true,
                                      allowMuting: true,
                                      showControls: true,
                                      materialProgressColors:
                                          ChewieProgressColors(
                                            playedColor: const Color(
                                              0xFFFF2D95,
                                            ),
                                            handleColor: const Color(
                                              0xFFFF2D95,
                                            ),
                                            backgroundColor: Colors.grey[800]!,
                                            bufferedColor: Colors.grey[500]!,
                                          ),
                                      errorBuilder: (context, errorMessage) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.error_outline,
                                                color: Color(0xFFFF2D95),
                                                size: 42,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Error: $errorMessage',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );

                                    return WillPopScope(
                                      onWillPop: () async {
                                        // Dispose controllers before popping
                                        controller.pause();
                                        await controller.dispose();
                                        // Ensure loading indicator doesn't show when we return
                                        if (mounted) {
                                          setState(() {
                                            _isVideoInitializing = false;
                                          });
                                        }
                                        return true;
                                      },
                                      child: Chewie(
                                        controller: chewieController,
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    // Handle initialization error
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Color(0xFFFF2D95),
                                            size: 42,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Error: ${snapshot.error}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFFF2D95,
                                              ),
                                            ),
                                            child: const Text('Go Back'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFFFF2D95),
                                                ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Loading video...',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(0.0, 0.1);
                  const end = Offset.zero;
                  const curve = Curves.easeOutQuint;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
              ),
            )
            .then((_) {
              // Reset video state when returning to this screen
              if (mounted) {
                setState(() {
                  // Clear loading state immediately to prevent loading indicator from showing
                  _isVideoInitializing = false;

                  // Keep track that we've already initialized this video
                  _hasBeenInitialized = true;

                  if (_isVideoInitialized) {
                    // Just ensure controllers are paused
                    _chewieController?.pause();
                    _videoPlayerController?.pause();

                    // Don't try to reinitialize unless controllers were disposed
                    if (_videoPlayerController == null ||
                        !_videoPlayerController!.value.isInitialized) {
                      // Only reinitialize if controllers are gone
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          // Set this to false so we don't show loading indicator during re-init
                          setState(() {
                            _isVideoInitializing = false;
                          });
                          _initializeVideo().catchError((error) {
                            // Handle any errors during reinitialization
                            if (mounted) {
                              setState(() {
                                _isVideoInitializing = false;
                              });
                            }
                          });
                        }
                      });
                    }
                  }
                });
              }
            });
      } else if (widget.course.fileType == 'html' &&
          widget.course.filePath != null) {
        // Check if file exists before navigating
        final htmlFile = File(widget.course.filePath!);
        if (!htmlFile.existsSync()) {
          _showContentError('HTML file not found');
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => HtmlViewer(
                  title: widget.course.title,
                  filePath: widget.course.filePath!,
                ),
          ),
        ).then((_) {
          // Ensure we don't show loading indicator when returning
          if (mounted) {
            setState(() {
              _isVideoInitializing = false;
            });
          }
        });
      } else {
        _showContentError('Content not available');
      }
    } catch (e) {
      _showContentError('Error opening content: $e');
    }
  }

  void _showContentError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}
