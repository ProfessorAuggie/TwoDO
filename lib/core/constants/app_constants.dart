class AppConstants {
  // App Info
  static const String appName = 'Twoदो';
  static const String appVersion = '2.0.0';
  static const String appBuild = '1';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String spacesCollection = 'spaces';
  static const String notesCollection = 'notes';
  static const String tasksCollection = 'tasks';
  static const String filesCollection = 'files';
  static const String membersCollection = 'members';
  static const String invitesCollection = 'invites';
  static const String activitiesCollection = 'activities';
  static const String presenceCollection = 'presence';

  // Firestore Fields
  static const String idField = 'id';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String createdByField = 'createdBy';
  static const String ownerIdField = 'ownerId';
  static const String memberIdsField = 'memberIds';
  static const String deletedAtField = 'deletedAt';
  static const String isDeletedField = 'isDeleted';

  // Storage Paths
  static const String userAvatarsPath = 'users/avatars';
  static const String spaceImagesPath = 'spaces/images';
  static const String filesPath = 'spaces/files';
  static const String tempFilesPath = 'temp';

  // Feature Limits
  static const int maxSpaceMembers = 100;
  static const int maxFileSize = 52428800; // 50MB
  static const int maxImageSize = 5242880; // 5MB
  static const int notePreviewLength = 100;
  static const int searchResultLimit = 50;
  static const int paginationLimit = 20;

  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration debounceSearchDuration = Duration(milliseconds: 500);
  static const Duration presenceUpdateInterval = Duration(seconds: 30);
}
