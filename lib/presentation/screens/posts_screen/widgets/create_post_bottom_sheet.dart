import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../../../data/model/user_model.dart';
import '../../../../bloc/sections/sections_cubit.dart';
import '../../../../bloc/sections/sections_state.dart';
import '../../../../generated/l10n.dart';

class CreatePostBottomSheet extends StatefulWidget {
  final UserModel user;
  final Function(Map<String, dynamic>) onPostCreated;

  const CreatePostBottomSheet({
    super.key,
    required this.user,
    required this.onPostCreated,
  });

  @override
  State<CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<File> _selectedImages = [];
  final List<PlatformFile> _selectedFiles = [];
  String _selectedShareType = 'Public';
  final List<int> _selectedSectionIds = [];
  bool _isLoading = false;

  final List<String> _shareTypes = ['Public', 'Private'];

  @override
  void initState() {
    super.initState();
    // Load sections when the bottom sheet is opened
    context.read<SectionsCubit>().getSections();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAuthorInfo(),
                  const SizedBox(height: 16),
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildContentField(),
                  const SizedBox(height: 16),
                  _buildShareTypeSelector(),
                  if (_selectedShareType == 'Private') ...[
                    const SizedBox(height: 16),
                    _buildSectionSelector(),
                  ],
                  const SizedBox(height: 16),
                  if (_selectedImages.isNotEmpty) _buildSelectedImages(),
                  if (_selectedFiles.isNotEmpty) _buildSelectedFiles(),
                  const SizedBox(height: 16),
                  _buildAttachmentOptions(),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, color: Colors.grey[600]!, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).createPost,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.user.firstName} ${widget.user.lastName}',
                  style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
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
    );
  }

  Widget _buildAuthorInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            widget.user.firstName[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.user.firstName} ${widget.user.lastName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              widget.user.role,
              style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        hintText: S.of(context).postTitle,
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildContentField() {
    return TextField(
      controller: _contentController,
      decoration: InputDecoration(
        hintText: S.of(context).whatsOnYourMind,
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      maxLines: 6,
      style: const TextStyle(fontSize: 16, height: 1.4),
    );
  }

  Widget _buildShareTypeSelector() {
    return Row(
      children: [
        Icon(Icons.visibility, color: Colors.grey[600]!, size: 20),
        const SizedBox(width: 8),
        Text(
          'Share with: ',
          style: TextStyle(color: Colors.grey[600]!, fontSize: 14),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: _selectedShareType,
          items: _shareTypes.map((type) {
            String localizedType;
            switch (type) {
              case 'Public':
                localizedType = S.of(context).public;
                break;
              case 'Private':
                localizedType = 'Private';
                break;
              default:
                localizedType = type;
            }
            return DropdownMenuItem(value: type, child: Text(localizedType));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedShareType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSectionSelector() {
    return BlocBuilder<SectionsCubit, SectionsState>(
      builder: (context, state) {
        if (state is SectionsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SectionsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Sections:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.sections.length,
                  itemBuilder: (context, index) {
                    final section = state.sections[index];
                    final isSelected = _selectedSectionIds.contains(section.id);

                    return CheckboxListTile(
                      title: Text(section.displayName),
                      subtitle: Text(
                        '${section.grade.studyStage.name} - ${section.grade.studyYear.name}',
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedSectionIds.add(section.id);
                          } else {
                            _selectedSectionIds.remove(section.id);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else if (state is SectionsError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600]!, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to load sections: ${state.message}',
                    style: TextStyle(color: Colors.red[600]!),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSelectedImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images (${_selectedImages.length})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImages[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${S.of(context).files} (${_selectedFiles.length})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...(_selectedFiles.map(
          (file) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  _getFileIcon(file.extension ?? ''),
                  color: Colors.grey[600]!,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatFileSize(file.size),
                        style: TextStyle(
                          color: Colors.grey[600]!,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeFile(file),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
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
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
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

  Widget _buildAttachmentOptions() {
    return Row(
      children: [
        _buildAttachmentButton(
          icon: Icons.photo_library,
          label: S.of(context).photo,
          onTap: _addImages,
        ),
        const SizedBox(width: 16),
        _buildAttachmentButton(
          icon: Icons.attach_file,
          label: S.of(context).file,
          onTap: _addFiles,
        ),
        const SizedBox(width: 16),
        _buildAttachmentButton(
          icon: Icons.location_on,
          label: S.of(context).location,
          onTap: _addLocation,
        ),
      ],
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]!),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600]!,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[600]!, size: 16),
              const SizedBox(width: 8),
              Text(
                S.of(context).yourPostVisibleTo(_selectedShareType),
                style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(S.of(context).createPost),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          for (final image in images) {
            _selectedImages.add(File(image.path));
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
    }
  }

  Future<void> _addFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking files: $e')));
    }
  }

  void _addLocation() {
    // TODO: Implement location picker
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).location + ' feature coming soon!')),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });
  }

  void _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).pleaseEnterContent)));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Convert selected images and files to File objects
    final List<File> attachments = [];
    attachments.addAll(_selectedImages);
    attachments.addAll(_selectedFiles.map((file) => File(file.path!)));

    // Call the Cubit to create the post
    widget.onPostCreated({
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'isPublic': _selectedShareType == 'Public',
      'attachments': attachments,
      'sectionIds': _selectedSectionIds,
    });

    Navigator.pop(context);
  }
}
