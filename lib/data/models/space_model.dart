import 'package:cloud_firestore/cloud_firestore.dart';

enum SpaceType {
  couple('couple'),
  duo('duo'),
  trio('trio'),
  personal('personal'),
  team('team');

  final String value;
  const SpaceType(this.value);

  String get displayName {
    return switch (this) {
      SpaceType.couple => 'Couple',
      SpaceType.duo => 'Duo',
      SpaceType.trio => 'Trio',
      SpaceType.personal => 'Personal',
      SpaceType.team => 'Team',
    };
  }

  factory SpaceType.fromValue(String value) {
    return SpaceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SpaceType.personal,
    );
  }
}

enum UserRole {
  admin('admin'),
  editor('editor'),
  viewer('viewer'),
  member('member');

  final String value;
  const UserRole(this.value);

  bool get isAdmin => this == UserRole.admin;
  bool get isEditor => this == UserRole.editor;
  bool get canEdit => this == UserRole.admin || this == UserRole.editor;

  factory UserRole.fromValue(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.member,
    );
  }
}

class SpaceMember {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final UserRole role;
  final DateTime joinedAt;

  SpaceMember({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.joinedAt,
  });

  factory SpaceMember.fromMap(Map<String, dynamic> data) {
    return SpaceMember(
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      role: UserRole.fromValue(data['role'] ?? 'member'),
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'role': role.value,
    'joinedAt': Timestamp.fromDate(joinedAt),
  };
}

class SpaceModel {
  final String id;
  final String name;
  final String? description;
  final String? photoUrl;
  final SpaceType type;
  final String ownerId;
  final List<SpaceMember> members;
  final List<String> noteIds;
  final List<String> taskIds;
  final List<String> fileIds;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  SpaceModel({
    required this.id,
    required this.name,
    this.description,
    this.photoUrl,
    required this.type,
    required this.ownerId,
    required this.members,
    required this.noteIds,
    required this.taskIds,
    required this.fileIds,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpaceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SpaceModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      photoUrl: data['photoUrl'],
      type: SpaceType.fromValue(data['type'] ?? 'personal'),
      ownerId: data['ownerId'] ?? '',
      members: (data['members'] as List?)?.map((m) => SpaceMember.fromMap(m as Map<String, dynamic>)).toList() ?? [],
      noteIds: List<String>.from(data['noteIds'] ?? []),
      taskIds: List<String>.from(data['taskIds'] ?? []),
      fileIds: List<String>.from(data['fileIds'] ?? []),
      settings: data['settings'] ?? {},
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'photoUrl': photoUrl,
    'type': type.value,
    'ownerId': ownerId,
    'members': members.map((m) => m.toMap()).toList(),
    'noteIds': noteIds,
    'taskIds': taskIds,
    'fileIds': fileIds,
    'settings': settings,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  SpaceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? photoUrl,
    SpaceType? type,
    String? ownerId,
    List<SpaceMember>? members,
    List<String>? noteIds,
    List<String>? taskIds,
    List<String>? fileIds,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SpaceModel(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    photoUrl: photoUrl ?? this.photoUrl,
    type: type ?? this.type,
    ownerId: ownerId ?? this.ownerId,
    members: members ?? this.members,
    noteIds: noteIds ?? this.noteIds,
    taskIds: taskIds ?? this.taskIds,
    fileIds: fileIds ?? this.fileIds,
    settings: settings ?? this.settings,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  String toString() => 'SpaceModel(id: $id, name: $name, type: ${type.value})';
}
