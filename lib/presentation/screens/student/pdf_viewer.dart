import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

/// A widget for viewing PDF content with enhanced controls
class PdfViewer extends StatefulWidget {
  final String filePath;
  final String title;

  const PdfViewer({super.key, required this.filePath, required this.title});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isLoading = true;
  bool _isError = false;
  String? _errorMessage;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _checkFile();
  }

  void _checkFile() async {
    try {
      final file = File(widget.filePath);
      if (!file.existsSync()) {
        setState(() {
          _isError = true;
          _errorMessage = 'PDF file not found';
          _isLoading = false;
        });
        return;
      }

      // Check if file is readable and has content
      if (file.lengthSync() == 0) {
        setState(() {
          _isError = true;
          _errorMessage = 'PDF file is empty';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = 'Error checking PDF file: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
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
                      Icons.picture_as_pdf,
                      color: Color(0xFFFF2D95),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ?? 'Error loading PDF',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2D95),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        PDFView(
                          filePath: widget.filePath,
                          enableSwipe: true,
                          swipeHorizontal: true,
                          autoSpacing: false,
                          pageFling: true,
                          pageSnap: true,
                          defaultPage: _currentPage,
                          fitPolicy: FitPolicy.BOTH,
                          preventLinkNavigation: false,
                          onRender: (pages) {
                            if (mounted) {
                              setState(() {
                                _totalPages = pages!;
                                _isLoading = false;
                              });
                            }
                          },
                          onError: (error) {
                            if (mounted) {
                              setState(() {
                                _isError = true;
                                _errorMessage = error.toString();
                                _isLoading = false;
                              });
                            }
                          },
                          onPageError: (page, error) {
                            if (mounted) {
                              setState(() {
                                _isError = true;
                                _errorMessage =
                                    'Error loading page $page: $error';
                                _isLoading = false;
                              });
                            }
                          },
                          onViewCreated: (PDFViewController controller) {
                            _pdfViewController = controller;
                          },
                          onPageChanged: (page, total) {
                            if (mounted) {
                              setState(() {
                                _currentPage = page!;
                              });
                            }
                          },
                        ),
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
                  ),
                  if (!_isLoading && !_isError && _totalPages > 0)
                    _buildControlBar(),
                ],
              ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed:
                _currentPage > 0
                    ? () {
                      if (_pdfViewController != null) {
                        _pdfViewController!.setPage(_currentPage - 1);
                      }
                    }
                    : null,
          ),
          Text(
            'Page ${_currentPage + 1} of $_totalPages',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed:
                _currentPage < _totalPages - 1
                    ? () {
                      if (_pdfViewController != null) {
                        _pdfViewController!.setPage(_currentPage + 1);
                      }
                    }
                    : null,
          ),
        ],
      ),
    );
  }
}
