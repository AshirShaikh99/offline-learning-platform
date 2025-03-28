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
      appBar: AppBar(title: Text('${widget.subject} Content')),
      body: BlocBuilder<FileBloc, FileState>(
        builder: (context, state) {
          if (state is FileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FileError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is FilesLoaded) {
            if (state.files.isEmpty) {
              return const Center(
                child: Text('No content available for this subject'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.files.length,
              itemBuilder: (context, index) {
                final file = state.files[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      file.fileType == AppConstants.typePdf
                          ? Icons.picture_as_pdf
                          : Icons.flash_on,
                      color: AppTheme.primaryColor,
                      size: 32,
                    ),
                    title: Text(
                      file.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Type: ${file.fileType}'),
                    onTap: () {
                      if (file.fileType == AppConstants.typePdf) {
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
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => HtmlViewer(
                                  filePath: file.filePath,
                                  title: file.title,
                                ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
