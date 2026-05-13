import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twodo/core/constants/app_constants.dart';
import 'package:twodo/core/utils/app_exceptions.dart';
import 'package:twodo/data/models/space_model.dart';
import 'package:twodo/data/models/note_model.dart';
import 'package:twodo/data/models/task_model.dart';

class FirestoreSpaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE SPACE
  Future<String> createSpace(SpaceModel space) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.spacesCollection)
          .add(space.toFirestore());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to create space',
        code: e.code,
        originalException: e,
      );
    }
  }

  // GET SPACE BY ID
  Future<SpaceModel?> getSpaceById(String spaceId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.spacesCollection)
          .doc(spaceId)
          .get();

      if (!doc.exists) return null;
      return SpaceModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to fetch space',
        code: e.code,
        originalException: e,
      );
    }
  }

  // GET USER SPACES
  Future<List<SpaceModel>> getUserSpaces(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.spacesCollection)
          .where('members', arrayContains: userId)
          .get();

      return snapshot.docs.map((doc) => SpaceModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to fetch spaces',
        code: e.code,
        originalException: e,
      );
    }
  }

  // UPDATE SPACE
  Future<void> updateSpace(SpaceModel space) async {
    try {
      await _firestore
          .collection(AppConstants.spacesCollection)
          .doc(space.id)
          .update(space.toFirestore());
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to update space',
        code: e.code,
        originalException: e,
      );
    }
  }

  // DELETE SPACE
  Future<void> deleteSpace(String spaceId) async {
    try {
      await _firestore
          .collection(AppConstants.spacesCollection)
          .doc(spaceId)
          .delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to delete space',
        code: e.code,
        originalException: e,
      );
    }
  }

  // ADD MEMBER TO SPACE
  Future<void> addMemberToSpace(String spaceId, SpaceMember member) async {
    try {
      await _firestore
          .collection(AppConstants.spacesCollection)
          .doc(spaceId)
          .update({
        'members': FieldValue.arrayUnion([member.toMap()]),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to add member',
        code: e.code,
        originalException: e,
      );
    }
  }

  // REMOVE MEMBER FROM SPACE
  Future<void> removeMemberFromSpace(String spaceId, String userId) async {
    try {
      final space = await getSpaceById(spaceId);
      if (space == null) return;

      final updatedMembers = space.members
          .where((m) => m.userId != userId)
          .toList();

      await _firestore
          .collection(AppConstants.spacesCollection)
          .doc(spaceId)
          .update({
        'members': updatedMembers.map((m) => m.toMap()).toList(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to remove member',
        code: e.code,
        originalException: e,
      );
    }
  }

  // GET SPACE STREAM
  Stream<SpaceModel?> getSpaceStream(String spaceId) {
    return _firestore
        .collection(AppConstants.spacesCollection)
        .doc(spaceId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return SpaceModel.fromFirestore(doc);
        });
  }

  // GET USER SPACES STREAM
  Stream<List<SpaceModel>> getUserSpacesStream(String userId) {
    return _firestore
        .collection(AppConstants.spacesCollection)
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SpaceModel.fromFirestore(doc))
            .toList());
  }
}

class FirestoreNoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE NOTE
  Future<String> createNote(NoteModel note) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.notesCollection)
          .add(note.toFirestore());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to create note',
        code: e.code,
        originalException: e,
      );
    }
  }

  // GET NOTE BY ID
  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .get();

      if (!doc.exists) return null;
      return NoteModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to fetch note',
        code: e.code,
        originalException: e,
      );
    }
  }

  // GET SPACE NOTES
  Future<List<NoteModel>> getSpaceNotes(String spaceId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.notesCollection)
          .where('spaceId', isEqualTo: spaceId)
          .where('isArchived', isEqualTo: false)
          .orderBy('updatedAt', descending: true)
          .limit(AppConstants.paginationLimit)
          .get();

      return snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to fetch notes',
        code: e.code,
        originalException: e,
      );
    }
  }

  // UPDATE NOTE
  Future<void> updateNote(NoteModel note) async {
    try {
      await _firestore
          .collection(AppConstants.notesCollection)
          .doc(note.id)
          .update(note.toFirestore());
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to update note',
        code: e.code,
        originalException: e,
      );
    }
  }

  // DELETE NOTE
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to delete note',
        code: e.code,
        originalException: e,
      );
    }
  }

  // ADD REACTION
  Future<void> addReaction(String noteId, String emoji, String userId) async {
    try {
      await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .update({
        'reactions.$emoji': FieldValue.arrayUnion([userId]),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to add reaction',
        code: e.code,
        originalException: e,
      );
    }
  }

  // REMOVE REACTION
  Future<void> removeReaction(String noteId, String emoji, String userId) async {
    try {
      await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .update({
        'reactions.$emoji': FieldValue.arrayRemove([userId]),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to remove reaction',
        code: e.code,
        originalException: e,
      );
    }
  }

  // GET NOTES STREAM
  Stream<List<NoteModel>> getSpaceNotesStream(String spaceId) {
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('spaceId', isEqualTo: spaceId)
        .where('isArchived', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromFirestore(doc))
            .toList());
  }

  // SEARCH NOTES
  Future<List<NoteModel>> searchNotes(String spaceId, String query) async {
    try {
      if (query.isEmpty) return [];

      final snapshot = await _firestore
          .collection(AppConstants.notesCollection)
          .where('spaceId', isEqualTo: spaceId)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .get();

      return snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to search notes',
        code: e.code,
        originalException: e,
      );
    }
  }
}

class FirestoreTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE TASK
  Future<String> createTask(TaskModel task) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.tasksCollection)
          .add(task.toFirestore());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to create task',
        code: e.code,
        originalException: e,
      );
    }
  }

  // GET TASK BY ID
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.tasksCollection)
          .doc(taskId)
          .get();

      if (!doc.exists) return null;
      return TaskModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to fetch task',
        code: e.code,
        originalException: e,
      );
    }
  }

  // GET SPACE TASKS
  Future<List<TaskModel>> getSpaceTasks(String spaceId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.tasksCollection)
          .where('spaceId', isEqualTo: spaceId)
          .where('isArchived', isEqualTo: false)
          .orderBy('dueDate')
          .limit(AppConstants.paginationLimit)
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to fetch tasks',
        code: e.code,
        originalException: e,
      );
    }
  }

  // UPDATE TASK
  Future<void> updateTask(TaskModel task) async {
    try {
      await _firestore
          .collection(AppConstants.tasksCollection)
          .doc(task.id)
          .update(task.toFirestore());
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to update task',
        code: e.code,
        originalException: e,
      );
    }
  }

  // DELETE TASK
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore
          .collection(AppConstants.tasksCollection)
          .doc(taskId)
          .delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to delete task',
        code: e.code,
        originalException: e,
      );
    }
  }

  // GET TASKS STREAM
  Stream<List<TaskModel>> getSpaceTasksStream(String spaceId) {
    return _firestore
        .collection(AppConstants.tasksCollection)
        .where('spaceId', isEqualTo: spaceId)
        .where('isArchived', isEqualTo: false)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  // GET OVERDUE TASKS
  Future<List<TaskModel>> getOverdueTasks(String spaceId) async {
    try {
      final now = Timestamp.now();
      final snapshot = await _firestore
          .collection(AppConstants.tasksCollection)
          .where('spaceId', isEqualTo: spaceId)
          .where('status', isNotEqualTo: 'completed')
          .where('dueDate', isLessThan: now)
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to fetch overdue tasks',
        code: e.code,
        originalException: e,
      );
    }
  }
}
