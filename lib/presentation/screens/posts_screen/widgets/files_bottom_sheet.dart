import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../../generated/l10n.dart';

class FilesBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> files;
  final String postTitle;

  const FilesBottomSheet({
    super.key,
    required this.files,
    required this.postTitle,
  });

  @override
  State<FilesBottomSheet> createState() => _FilesBottomSheetState();
}

class _FilesBottomSheetState extends State<FilesBottomSheet> {
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _isDownloading = {};
  final Map<String, String> _downloadedFiles = {};

  // Filter out image files - only show non-image files
  List<Map<String, dynamic>> get _nonImageFiles {
    return widget.files.where((file) {
      final type = (file['type'] ?? '').toLowerCase();
      return !['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(type);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _nonImageFiles.isEmpty
                ? _buildEmptyState(locale)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _nonImageFiles.length,
                    itemBuilder: (context, index) {
                      final file = _nonImageFiles[index];
                      return _buildFileItem(file, context);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            Icon(Icons.attach_file, color: Colors.grey[600]!, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).files,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.postTitle,
                    style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.attach_file, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            locale.noFilesAttached,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600]!,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            locale.thisPostNoFiles,
            style: TextStyle(color: Colors.grey[500]!, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(Map<String, dynamic> file, BuildContext context) {
    final name = file['name'] ?? '';
    final type = file['type'] ?? '';
    final url = file['url'] ?? '';
    final isDownloading = _isDownloading[name] ?? false;
    final progress = _downloadProgress[name] ?? 0.0;
    final isDownloaded = _downloadedFiles.containsKey(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFileIcon(type),
                  color: Colors.grey[600]!,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFileTypeDescription(type),
                      style: TextStyle(color: Colors.grey[500]!, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (isDownloading)
                Column(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: progress,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    if (isDownloaded) ...[
                      IconButton(
                        onPressed: () => _openDownloadedFile(name),
                        icon: const Icon(Icons.open_in_new),
                      ),
                      IconButton(
                        onPressed: () => _shareFile(name),
                        icon: const Icon(Icons.share),
                      ),
                    ] else ...[
                      IconButton(
                        onPressed: () => _downloadFile(url, name, context),
                        icon: const Icon(Icons.download),
                      ),
                    ],
                  ],
                ),
            ],
          ),
          if (isDownloading) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      default:
        return Icons.attach_file;
    }
  }

  String _getFileTypeDescription(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return 'PDF Document';
      case 'doc':
      case 'docx':
        return 'Word Document';
      case 'xls':
      case 'xlsx':
        return 'Excel Spreadsheet';
      case 'ppt':
      case 'pptx':
        return 'PowerPoint Presentation';
      case 'txt':
        return 'Text File';
      case 'mp4':
      case 'avi':
      case 'mov':
        return 'Video File';
      case 'mp3':
      case 'wav':
        return 'Audio File';
      default:
        return 'File';
    }
  }

  void _openFile(String url, BuildContext context) {
    try {
      if (url.isNotEmpty) {
        // For now, just show a snackbar with the URL
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(url)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).filePathNotAvailable)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).errorOpeningFile(e.toString()))),
      );
    }
  }

  Future<void> _downloadFile(
    String url,
    String name,
    BuildContext context,
  ) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).filePathNotAvailable)),
      );
      return;
    }

    setState(() {
      _isDownloading[name] = true;
      _downloadProgress[name] = 0.0;
    });

    try {
      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$name';

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress[name] = received / total;
            });
          }
        },
      );

      setState(() {
        _isDownloading[name] = false;
        _downloadedFiles[name] = filePath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File downloaded successfully!'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => _openDownloadedFile(name),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isDownloading[name] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: ${e.toString()}')),
      );
    }
  }

  void _openDownloadedFile(String name) {
    try {
      final filePath = _downloadedFiles[name];
      if (filePath != null) {
        OpenFile.open(filePath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: ${e.toString()}')),
      );
    }
  }

  void _shareFile(String name) {
    try {
      final filePath = _downloadedFiles[name];
      if (filePath != null) {
        Share.shareXFiles([XFile(filePath)], text: 'Sharing file: $name');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing file: ${e.toString()}')),
      );
    }
  }
}
