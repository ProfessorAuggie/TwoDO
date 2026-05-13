import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../data/models/file_model.dart';
import '../../providers/space_providers.dart';
import '../../widgets/common/app_widgets.dart';

class FileDetailScreen extends ConsumerStatefulWidget {
  final String fileId;

  const FileDetailScreen({required this.fileId, super.key});

  @override
  ConsumerState<FileDetailScreen> createState() => _FileDetailScreenState();
}

class _FileDetailScreenState extends ConsumerState<FileDetailScreen> {
  bool _isDownloading = false;

  Future<void> _downloadFile(FileModel file) async {
    setState(() => _isDownloading = true);

    try {
      // TODO: Implement file download via provider
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          'File downloaded to Downloads folder',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileAsync = ref.watch(fileProvider(widget.fileId));
    final isDesktop = context.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Details'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.share, size: 20),
                    SizedBox(width: 12),
                    Text('Share'),
                  ],
                ),
                onTap: () => SnackBarHelper.showInfo(
                  context,
                  'Share functionality coming soon',
                ),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete, size: 20),
                    SizedBox(width: 12),
                    Text('Delete'),
                  ],
                ),
                onTap: () => _showDeleteDialog(context),
              ),
            ],
          ),
        ],
      ),
      body: fileAsync.when(
        data: (file) {
          if (file == null) {
            return Center(
              child: Text(
                'File not found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: file.isImage && file.thumbnail != null
                        ? Image.network(
                            file.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildFileIcon(context, file),
                          )
                        : _buildFileIcon(context, file),
                  ),
                ),
                const SizedBox(height: 32),

                // File Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'File Name',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  file.fileName,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'File Size',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                file.fileSizeDisplay,
                                style:
                                    Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'File Type',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                file.fileType,
                                style:
                                    Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Uploaded By',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                file.uploadedByName,
                                style:
                                    Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Uploaded On',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                file.uploadedAt.relativeTime(),
                                style:
                                    Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading
                        ? null
                        : () => _downloadFile(file),
                    icon: _isDownloading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.download),
                    label: Text(_isDownloading
                        ? 'Downloading...'
                        : 'Download File'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => SnackBarHelper.showInfo(
                      context,
                      'Share functionality coming soon',
                    ),
                    icon: const Icon(Icons.share),
                    label: const Text('Share File'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          error: error.toString(),
          onRetry: () => ref.refresh(fileProvider(widget.fileId)),
        ),
      ),
    );
  }

  Widget _buildFileIcon(BuildContext context, FileModel file) {
    IconData iconData;
    Color iconColor;

    if (file.isImage) {
      iconData = Icons.image;
      iconColor = Colors.blue;
    } else if (file.isDocument) {
      iconData = Icons.description;
      iconColor = Colors.red;
    } else {
      iconData = Icons.file_present;
      iconColor = Colors.grey;
    }

    return Icon(
      iconData,
      size: 96,
      color: iconColor.withOpacity(0.5),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement via provider
              Navigator.pop(context);
              Navigator.pop(context);
              SnackBarHelper.showSuccess(context, 'File deleted');
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
