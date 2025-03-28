import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_utils.dart';
import '../../blocs/file/file_bloc.dart';
import '../../blocs/file/file_event.dart';
import '../../blocs/file/file_state.dart';

/// Content management screen for handling file uploads
class ContentManagementScreen extends StatefulWidget {
  final String className;
  final String subject;

  const ContentManagementScreen({
    super.key,
    required this.className,
    required this.subject,
  });

  @override
  State<ContentManagementScreen> createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FileBloc>().add(
      LoadFilesEvent(className: widget.className, subject: widget.subject),
    );
  }

  Future<void> _pickAndUploadFile(FileType fileType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: fileType == FileType.custom ? ['pdf'] : ['swf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        context.read<FileBloc>().add(
          UploadFileEvent(
            filePath: file.path!,
            fileName: file.name,
            className: widget.className,
            subject: widget.subject,
            fileType: fileType == FileType.custom ? 'pdf' : 'flash',
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Content - ${widget.className}'),
      ),
      body: Column(
        children: [
          _buildUploadSection(),
          const Divider(),
          Expanded(child: _buildContentList()),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () => _pickAndUploadFile(FileType.custom),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _pickAndUploadFile(FileType.any),
            icon: const Icon(Icons.flash_on),
            label: const Text('Upload Flash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return BlocBuilder<FileBloc, FileState>(
      builder: (context, state) {
        if (state is FileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FileError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is FilesLoaded) {
          if (state.files.isEmpty) {
            return const Center(child: Text('No content uploaded yet'));
          }

          return ListView.builder(
            itemCount: state.files.length,
            itemBuilder: (context, index) {
              final file = state.files[index];
              return ListTile(
                leading: Icon(
                  file.type == 'pdf' ? Icons.picture_as_pdf : Icons.flash_on,
                  color: AppTheme.primaryColor,
                ),
                title: Text(file.name),
                subtitle: Text('Type: ${file.type}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<FileBloc>().add(
                      DeleteFileEvent(
                        fileId: file.id,
                        fileName: file.name,
                        className: widget.className,
                        subject: widget.subject,
                      ),
                    );
                  },
                ),
                onTap: () {
                  // TODO: Implement file preview
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
