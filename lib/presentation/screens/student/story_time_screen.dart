import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A screen that displays a web page for Story Time
class StoryTimeScreen extends StatefulWidget {
  /// The title of the screen
  final String title;

  /// The color of the screen
  final Color color;

  /// Constructor
  const StoryTimeScreen({super.key, required this.title, required this.color});

  @override
  State<StoryTimeScreen> createState() => _StoryTimeScreenState();
}

class _StoryTimeScreenState extends State<StoryTimeScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                setState(() {
                  _progress = progress / 100;
                  if (progress == 100) {
                    _isLoading = false;
                  }
                });
              },
              onPageStarted: (String url) {
                setState(() {
                  _isLoading = true;
                  _currentUrl = url;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('Web resource error: ${error.description}');
              },
            ),
          )
          ..loadRequest(
            Uri.parse('https://edutechsolutionpk.com/rufflegames/'),
          );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: AnimatedOpacity(
          opacity: _isLoading ? 0.6 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 20 : 24,
              letterSpacing: 0.5,
            ),
          ),
        ),
        backgroundColor: widget.color.withAlpha(242), // 95% opacity
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              _controller.reload();
              HapticFeedback.mediumImpact();
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Home',
            onPressed: () {
              _controller.loadRequest(
                Uri.parse('https://edutechsolutionpk.com/rufflegames/'),
              );
              HapticFeedback.mediumImpact();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.color.withAlpha(25), // 10% opacity
                  Colors.white,
                ],
              ),
            ),
          ),

          // WebView
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSmallScreen ? 0 : 16),
              child: WebViewWidget(controller: _controller),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                ),
              ),
            ),

          // URL display
          if (_currentUrl.isNotEmpty && !_isLoading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: const Color.fromRGBO(0, 0, 0, 0.7),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentUrl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.arrow_back),
        label: const Text('Back'),
        onPressed: () {
          Navigator.of(context).pop();
          HapticFeedback.mediumImpact();
        },
      ),
    );
  }
}
