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
}

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

  int get maxMembers {
    return switch (this) {
      SpaceType.couple => 2,
      SpaceType.duo => 2,
      SpaceType.trio => 3,
      SpaceType.personal => 1,
      SpaceType.team => 100,
    };
  }
}

enum TaskPriority {
  low('low'),
  medium('medium'),
  high('high'),
  urgent('urgent');

  final String value;
  const TaskPriority(this.value);

  String get displayName => value[0].toUpperCase() + value.substring(1);
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
}

enum ActivityType {
  created('created'),
  edited('edited'),
  deleted('deleted'),
  commented('commented'),
  reacted('reacted'),
  memberAdded('member_added'),
  memberRemoved('member_removed');

  final String value;
  const ActivityType(this.value);
}

enum NotificationPriority {
  low(0),
  normal(1),
  high(2);

  final int value;
  const NotificationPriority(this.value);
}

enum PresenceStatus {
  online('online'),
  away('away'),
  offline('offline');

  final String value;
  const PresenceStatus(this.value);
}

enum SyncStatus {
  synced('synced'),
  syncing('syncing'),
  failed('failed'),
  offline('offline');

  final String value;
  const SyncStatus(this.value);
}
