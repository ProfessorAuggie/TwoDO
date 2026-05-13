import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../data/models/file_model.dart';
import '../../providers/space_providers.dart';
import '../../widgets/common/app_widgets.dart';

class FilesListScreen extends ConsumerStatefulWidget {
  final String spaceId;

  const FilesListScreen({required this.spaceId, super.key});

  @override
  ConsumerState<FilesListScreen> createState() => _FilesListScreenState();
}

class _FilesListScreenState extends ConsumerState<FilesListScreen> {
  String? _filterType;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final files = ref.watch(spaceFilesProvider(widget.spaceId));
    final isDesktop = context.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Files'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: AppTextField(
              controller: _searchController,
              label: 'Search files',
              hint: 'Search by file name...',
              prefixIcon: Icons.search,
              suffixIcon: _searchController.text.isNotEmpty
                  ? Icons.clear
                  : null,
              onChanged: (value) => setState(() {}),
              onSuffixTap: () {
                _searchController.clear();
                setState(() {});
              },
            ),
          ),

          // Files Grid/List
          Expanded(
            child: files.when(
              data: (allFiles) {
                var filteredFiles = allFiles;

                // Filter by type
                if (_filterType != null) {
                  filteredFiles = filteredFiles
                      .where((file) => file.fileType == _filterType)
                      .toList();
                }

                // Filter by search
                if (_searchController.text.isNotEmpty) {
                  filteredFiles = filteredFiles
                      .where((file) => file.fileName
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase()))
                      .toList();
                }

                if (filteredFiles.isEmpty) {
                  return EmptyState(
                    icon: Icons.folder_open,
                    title: 'No files',
                    subtitle: 'Upload files to share with your team',
                    actionLabel: 'Upload File',
                    onAction: () =>
                        context.push('/spaces/${widget.spaceId}/files/upload'),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 12,
                    vertical: 8,
                  ),
                  gridDelegate:
                      SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: isDesktop ? 300 : 180,
                    childAspectRatio: 3 / 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: filteredFiles.length,
                  itemBuilder: (context, index) {
                    final file = filteredFiles[index];
                    return FileCard(
                      file: file,
                      onTap: () => context.push(
                        '/spaces/${widget.spaceId}/files/${file.id}',
                      ),
                    );
                  },
                );
              },
              loading: () => const SkeletonLoader(),
              error: (error, _) => ErrorState(
                error: error.toString(),
                onRetry: () =>
                    ref.refresh(spaceFilesProvider(widget.spaceId)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/spaces/${widget.spaceId}/files/upload'),
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
      ),
    );
  }

  void _showFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter by Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterType == null,
                  onSelected: (_) => setState(() {
                    _filterType = null;
                    Navigator.pop(context);
                  }),
                ),
                FilterChip(
                  label: const Text('Images'),
                  selected: _filterType == 'image',
                  onSelected: (_) => setState(() {
                    _filterType = 'image';
                    Navigator.pop(context);
                  }),
                ),
                FilterChip(
                  label: const Text('Documents'),
                  selected: _filterType == 'document',
                  onSelected: (_) => setState(() {
                    _filterType = 'document';
                    Navigator.pop(context);
                  }),
                ),
                FilterChip(
                  label: const Text('Videos'),
                  selected: _filterType == 'video',
                  onSelected: (_) => setState(() {
                    _filterType = 'video';
                    Navigator.pop(context);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FileCard extends ConsumerWidget {
  final FileModel file;
  final VoidCallback onTap;

  const FileCard({required this.file, required this.onTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail/Preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: file.isImage && file.thumbnail != null
                      ? Image.network(
                          file.thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildFileIcon(context),
                        )
                      : _buildFileIcon(context),
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.fileName,
                    style: Theme.of(context).textTheme.labelMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file.fileSizeDisplay,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  Text(
                    file.uploadedAt.relativeTime(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIcon(BuildContext context) {
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
      size: 48,
      color: iconColor.withOpacity(0.5),
    );
  }
}
