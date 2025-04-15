import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A widget for viewing HTML content
class HtmlViewer extends StatefulWidget {
  final String filePath;
  final String title;

  const HtmlViewer({super.key, required this.filePath, required this.title});

  @override
  State<HtmlViewer> createState() => _HtmlViewerState();
}

class _HtmlViewerState extends State<HtmlViewer> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _isError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    try {
      final file = File(widget.filePath);
      if (!file.existsSync()) {
        setState(() {
          _isError = true;
          _errorMessage = 'File not found: ${widget.filePath}';
          _isLoading = false;
        });
        return;
      }

      _webViewController =
          WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(Colors.white)
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageStarted: (String url) {
                  setState(() {
                    _isLoading = true;
                  });
                },
                onPageFinished: (String url) {
                  setState(() {
                    _isLoading = false;
                  });
                },
                onWebResourceError: (WebResourceError error) {
                  setState(() {
                    _isError = true;
                    _errorMessage =
                        'Error loading content: ${error.description}';
                    _isLoading = false;
                  });
                },
              ),
            );

      // Try loading the file
      _webViewController.loadFile(widget.filePath).catchError((error) {
        setState(() {
          _isError = true;
          _errorMessage = 'Error loading file: $error';
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = 'Failed to load content: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body:
          _isError
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage ?? 'An unknown error occurred',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
              : Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF2D95),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }
}
