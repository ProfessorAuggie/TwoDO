import 'package:cloud_firestore/cloud_firestore.dart';

class FileModel {
  final String id;
  final String spaceId;
  final String fileName;
  final String fileUrl;
  final String fileType; // 'image', 'document', 'video', 'audio', 'other'
  final int fileSizeBytes;
  final String mimeType;
  final String? thumbnail;
  final String uploadedBy;
  final String uploadedByName;
  final String? uploadedByPhotoUrl;
  final DateTime uploadedAt;
  final DateTime? expiresAt; // For temporary files
  final Map<String, dynamic> metadata;
  final bool isArchived;

  FileModel({
    required this.id,
    required this.spaceId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSizeBytes,
    required this.mimeType,
    this.thumbnail,
    required this.uploadedBy,
    required this.uploadedByName,
    this.uploadedByPhotoUrl,
    required this.uploadedAt,
    this.expiresAt,
    required this.metadata,
    required this.isArchived,
  });

  factory FileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FileModel(
      id: doc.id,
      spaceId: data['spaceId'] ?? '',
      fileName: data['fileName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileType: data['fileType'] ?? 'other',
      fileSizeBytes: data['fileSizeBytes'] ?? 0,
      mimeType: data['mimeType'] ?? 'application/octet-stream',
      thumbnail: data['thumbnail'],
      uploadedBy: data['uploadedBy'] ?? '',
      uploadedByName: data['uploadedByName'] ?? '',
      uploadedByPhotoUrl: data['uploadedByPhotoUrl'],
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'] ?? {},
      isArchived: data['isArchived'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'spaceId': spaceId,
    'fileName': fileName,
    'fileUrl': fileUrl,
    'fileType': fileType,
    'fileSizeBytes': fileSizeBytes,
    'mimeType': mimeType,
    'thumbnail': thumbnail,
    'uploadedBy': uploadedBy,
    'uploadedByName': uploadedByName,
    'uploadedByPhotoUrl': uploadedByPhotoUrl,
    'uploadedAt': Timestamp.fromDate(uploadedAt),
    'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    'metadata': metadata,
    'isArchived': isArchived,
  };

  bool get isImage => fileType == 'image';
  bool get isDocument => fileType == 'document';
  bool get isVideo => fileType == 'video';
  bool get isAudio => fileType == 'audio';

  String get fileSizeDisplay {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(2)} KB';
    if (fileSizeBytes < 1024 * 1024 * 1024) return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  FileModel copyWith({
    String? id,
    String? spaceId,
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSizeBytes,
    String? mimeType,
    String? thumbnail,
    String? uploadedBy,
    String? uploadedByName,
    String? uploadedByPhotoUrl,
    DateTime? uploadedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
    bool? isArchived,
  }) => FileModel(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    fileName: fileName ?? this.fileName,
    fileUrl: fileUrl ?? this.fileUrl,
    fileType: fileType ?? this.fileType,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    mimeType: mimeType ?? this.mimeType,
    thumbnail: thumbnail ?? this.thumbnail,
    uploadedBy: uploadedBy ?? this.uploadedBy,
    uploadedByName: uploadedByName ?? this.uploadedByName,
    uploadedByPhotoUrl: uploadedByPhotoUrl ?? this.uploadedByPhotoUrl,
    uploadedAt: uploadedAt ?? this.uploadedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    metadata: metadata ?? this.metadata,
    isArchived: isArchived ?? this.isArchived,
  );

  @override
  String toString() => 'FileModel(id: $id, fileName: $fileName, fileType: $fileType)';
}
