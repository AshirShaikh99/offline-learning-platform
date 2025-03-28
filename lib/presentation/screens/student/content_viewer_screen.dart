import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (isPdf) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        PdfViewer(filePath: file.filePath, title: file.title),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        HtmlViewer(filePath: file.filePath, title: file.title),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.flash_on,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.title,
                      style: AppTheme.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type: ${file.fileType}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
