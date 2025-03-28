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

  @override
  void initState() {
    super.initState();
    _checkFile();
  }

  void _checkFile() {
    final file = File(widget.filePath);
    if (!file.existsSync()) {
      setState(() {
        _isError = true;
        _errorMessage = 'PDF file not found';
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
              ? Center(child: Text(_errorMessage ?? 'Error loading PDF'))
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
                            setState(() {
                              _totalPages = pages!;
                              _isLoading = false;
                            });
                          },
                          onError: (error) {
                            setState(() {
                              _isError = true;
                              _errorMessage = error.toString();
                              _isLoading = false;
                            });
                          },
                          onPageError: (page, error) {
                            setState(() {
                              _isError = true;
                              _errorMessage =
                                  'Error loading page $page: $error';
                              _isLoading = false;
                            });
                          },
                          onPageChanged: (page, total) {
                            setState(() {
                              _currentPage = page!;
                            });
                          },
                        ),
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                      ],
                    ),
                  ),
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
                      setState(() {
                        _currentPage--;
                      });
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
                      setState(() {
                        _currentPage++;
                      });
                    }
                    : null,
          ),
        ],
      ),
    );
  }
}
