import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/extensions.dart';
import '../../providers/space_providers.dart';
import '../../widgets/common/app_widgets.dart';

class UploadFileScreen extends ConsumerStatefulWidget {
  final String spaceId;

  const UploadFileScreen({required this.spaceId, super.key});

  @override
  ConsumerState<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends ConsumerState<UploadFileScreen> {
  String? _selectedFilePath;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    // TODO: Implement file picker
    SnackBarHelper.showInfo(context, 'File picker coming soon');
  }

  Future<void> _uploadFile() async {
    if (_selectedFilePath == null) {
      SnackBarHelper.showError(context, 'Please select a file first');
      return;
    }

    setState(() => _isUploading = true);

    try {
      // TODO: Implement file upload via provider
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        SnackBarHelper.showSuccess(context, 'File uploaded successfully');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload File'),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Upload Area
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Drop files here or click to select',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Maximum file size: 50 MB',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Select File'),
                  ),
                ],
              ),
            ),

            if (_selectedFilePath != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'File selected',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            _selectedFilePath!.split('/').last,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Upload Button
            ElevatedButton.icon(
              onPressed:
                  _isUploading || _selectedFilePath == null ? null : _uploadFile,
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.upload),
              label: Text(_isUploading ? 'Uploading...' : 'Upload File'),
            ),
          ],
        ),
      ),
    );
  }
}
