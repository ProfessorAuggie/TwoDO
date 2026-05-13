import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String spaceId;
  final String title;
  final String content;
  final String? htmlContent;
  final String createdBy;
  final String lastEditedBy;
  final List<String> collaborators;
  final List<String> pinnedBy;
  final Map<String, List<String>> reactions; // emoji -> [userIds]
  final List<NoteComment> comments;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.spaceId,
    required this.title,
    required this.content,
    this.htmlContent,
    required this.createdBy,
    required this.lastEditedBy,
    required this.collaborators,
    required this.pinnedBy,
    required this.reactions,
    required this.comments,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final reactionsRaw = data['reactions'] as Map<String, dynamic>?;
    final reactions = reactionsRaw?.map(
      (key, value) => MapEntry(key, List<String>.from(value ?? [])),
    ) ?? {};

    return NoteModel(
      id: doc.id,
      spaceId: data['spaceId'] ?? '',
      title: data['title'] ?? 'Untitled',
      content: data['content'] ?? '',
      htmlContent: data['htmlContent'],
      createdBy: data['createdBy'] ?? '',
      lastEditedBy: data['lastEditedBy'] ?? '',
      collaborators: List<String>.from(data['collaborators'] ?? []),
      pinnedBy: List<String>.from(data['pinnedBy'] ?? []),
      reactions: reactions,
      comments: (data['comments'] as List?)?.map((c) => NoteComment.fromMap(c as Map<String, dynamic>)).toList() ?? [],
      isArchived: data['isArchived'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'spaceId': spaceId,
    'title': title,
    'content': content,
    'htmlContent': htmlContent,
    'createdBy': createdBy,
    'lastEditedBy': lastEditedBy,
    'collaborators': collaborators,
    'pinnedBy': pinnedBy,
    'reactions': reactions,
    'comments': comments.map((c) => c.toMap()).toList(),
    'isArchived': isArchived,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  NoteModel copyWith({
    String? id,
    String? spaceId,
    String? title,
    String? content,
    String? htmlContent,
    String? createdBy,
    String? lastEditedBy,
    List<String>? collaborators,
    List<String>? pinnedBy,
    Map<String, List<String>>? reactions,
    List<NoteComment>? comments,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => NoteModel(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    title: title ?? this.title,
    content: content ?? this.content,
    htmlContent: htmlContent ?? this.htmlContent,
    createdBy: createdBy ?? this.createdBy,
    lastEditedBy: lastEditedBy ?? this.lastEditedBy,
    collaborators: collaborators ?? this.collaborators,
    pinnedBy: pinnedBy ?? this.pinnedBy,
    reactions: reactions ?? this.reactions,
    comments: comments ?? this.comments,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  String toString() => 'NoteModel(id: $id, title: $title)';
}

class NoteComment {
  final String id;
  final String userId;
  final String displayName;
  final String? photoUrl;
  final String content;
  final DateTime createdAt;

  NoteComment({
    required this.id,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.content,
    required this.createdAt,
  });

  factory NoteComment.fromMap(Map<String, dynamic> data) {
    return NoteComment(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'content': content,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
