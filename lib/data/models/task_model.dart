import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority {
  low('low'),
  medium('medium'),
  high('high'),
  urgent('urgent');

  final String value;
  const TaskPriority(this.value);

  String get displayName => value[0].toUpperCase() + value.substring(1);

  factory TaskPriority.fromValue(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

enum TaskStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const TaskStatus(this.value);

  String get displayName {
    return switch (this) {
      TaskStatus.pending => 'Pending',
      TaskStatus.inProgress => 'In Progress',
      TaskStatus.completed => 'Completed',
      TaskStatus.cancelled => 'Cancelled',
    };
  }

  factory TaskStatus.fromValue(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskStatus.pending,
    );
  }
}

class TaskModel {
  final String id;
  final String spaceId;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final String? assigneeName;
  final String? assigneePhotoUrl;
  final DateTime? dueDate;
  final String createdBy;
  final String lastEditedBy;
  final List<String> collaborators;
  final List<String> pinnedBy;
  final Map<String, List<String>> reactions;
  final List<TaskComment> comments;
  final List<String> attachments;
  final List<TaskChecklist>? checklist;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.spaceId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.assigneeId,
    this.assigneeName,
    this.assigneePhotoUrl,
    this.dueDate,
    required this.createdBy,
    required this.lastEditedBy,
    required this.collaborators,
    required this.pinnedBy,
    required this.reactions,
    required this.comments,
    required this.attachments,
    this.checklist,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final reactionsRaw = data['reactions'] as Map<String, dynamic>?;
    final reactions = reactionsRaw?.map(
      (key, value) => MapEntry(key, List<String>.from(value ?? [])),
    ) ?? {};

    final checklistRaw = data['checklist'] as List?;
    final checklist = checklistRaw?.map((c) => TaskChecklist.fromMap(c as Map<String, dynamic>)).toList();

    return TaskModel(
      id: doc.id,
      spaceId: data['spaceId'] ?? '',
      title: data['title'] ?? 'Untitled',
      description: data['description'],
      status: TaskStatus.fromValue(data['status'] ?? 'pending'),
      priority: TaskPriority.fromValue(data['priority'] ?? 'medium'),
      assigneeId: data['assigneeId'],
      assigneeName: data['assigneeName'],
      assigneePhotoUrl: data['assigneePhotoUrl'],
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] ?? '',
      lastEditedBy: data['lastEditedBy'] ?? '',
      collaborators: List<String>.from(data['collaborators'] ?? []),
      pinnedBy: List<String>.from(data['pinnedBy'] ?? []),
      reactions: reactions,
      comments: (data['comments'] as List?)?.map((c) => TaskComment.fromMap(c as Map<String, dynamic>)).toList() ?? [],
      attachments: List<String>.from(data['attachments'] ?? []),
      checklist: checklist,
      isArchived: data['isArchived'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'spaceId': spaceId,
    'title': title,
    'description': description,
    'status': status.value,
    'priority': priority.value,
    'assigneeId': assigneeId,
    'assigneeName': assigneeName,
    'assigneePhotoUrl': assigneePhotoUrl,
    'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
    'createdBy': createdBy,
    'lastEditedBy': lastEditedBy,
    'collaborators': collaborators,
    'pinnedBy': pinnedBy,
    'reactions': reactions,
    'comments': comments.map((c) => c.toMap()).toList(),
    'attachments': attachments,
    'checklist': checklist?.map((c) => c.toMap()).toList(),
    'isArchived': isArchived,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  TaskModel copyWith({
    String? id,
    String? spaceId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    String? assigneeName,
    String? assigneePhotoUrl,
    DateTime? dueDate,
    String? createdBy,
    String? lastEditedBy,
    List<String>? collaborators,
    List<String>? pinnedBy,
    Map<String, List<String>>? reactions,
    List<TaskComment>? comments,
    List<String>? attachments,
    List<TaskChecklist>? checklist,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TaskModel(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    assigneeId: assigneeId ?? this.assigneeId,
    assigneeName: assigneeName ?? this.assigneeName,
    assigneePhotoUrl: assigneePhotoUrl ?? this.assigneePhotoUrl,
    dueDate: dueDate ?? this.dueDate,
    createdBy: createdBy ?? this.createdBy,
    lastEditedBy: lastEditedBy ?? this.lastEditedBy,
    collaborators: collaborators ?? this.collaborators,
    pinnedBy: pinnedBy ?? this.pinnedBy,
    reactions: reactions ?? this.reactions,
    comments: comments ?? this.comments,
    attachments: attachments ?? this.attachments,
    checklist: checklist ?? this.checklist,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && status != TaskStatus.completed;

  int get completedChecklistItems => checklist?.where((c) => c.isCompleted).length ?? 0;
  int get totalChecklistItems => checklist?.length ?? 0;
  double get checklistProgress => totalChecklistItems == 0 ? 0 : completedChecklistItems / totalChecklistItems;

  @override
  String toString() => 'TaskModel(id: $id, title: $title, status: ${status.value})';
}

class TaskComment {
  final String id;
  final String userId;
  final String displayName;
  final String? photoUrl;
  final String content;
  final DateTime createdAt;

  TaskComment({
    required this.id,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.content,
    required this.createdAt,
  });

  factory TaskComment.fromMap(Map<String, dynamic> data) {
    return TaskComment(
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

class TaskChecklist {
  final String id;
  final String title;
  final bool isCompleted;
  final String? assigneeId;
  final DateTime? dueDate;

  TaskChecklist({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.assigneeId,
    this.dueDate,
  });

  factory TaskChecklist.fromMap(Map<String, dynamic> data) {
    return TaskChecklist(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      assigneeId: data['assigneeId'],
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'assigneeId': assigneeId,
    'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
  };
}
