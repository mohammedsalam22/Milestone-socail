class AttachmentModel {
  final String file;
  final String fileType;

  AttachmentModel({required this.file, required this.fileType});

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      file: json['file'] ?? '',
      fileType: json['file_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'file': file, 'file_type': fileType};
  }

  bool get isImage => fileType.toLowerCase() == 'image';
  bool get isFile => fileType.toLowerCase() == 'file';

  String get fileName {
    final parts = file.split('/');
    return parts.isNotEmpty ? parts.last : file;
  }
}
