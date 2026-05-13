import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twodo/services/firestore_service.dart';
import 'package:twodo/data/models/space_model.dart';
import 'package:twodo/data/models/note_model.dart';
import 'package:twodo/data/models/task_model.dart';
import 'package:twodo/data/models/file_model.dart';
import 'package:twodo/presentation/providers/auth_providers.dart';

// Firestore Services
final firestoreSpaceServiceProvider = Provider<FirestoreSpaceService>((ref) {
  return FirestoreSpaceService();
});

final firestoreNoteServiceProvider = Provider<FirestoreNoteService>((ref) {
  return FirestoreNoteService();
});

final firestoreTaskServiceProvider = Provider<FirestoreTaskService>((ref) {
  return FirestoreTaskService();
});

// USER SPACES
final userSpacesProvider = StreamProvider<List<SpaceModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  final spaceService = ref.watch(firestoreSpaceServiceProvider);
  return spaceService.getUserSpacesStream(userId);
});

// SPECIFIC SPACE
final spaceProvider = StreamProvider.family<SpaceModel?, String>((ref, spaceId) {
  final spaceService = ref.watch(firestoreSpaceServiceProvider);
  return spaceService.getSpaceStream(spaceId);
});

// SPACE NOTES
final spaceNotesProvider =
    StreamProvider.family<List<NoteModel>, String>((ref, spaceId) {
  final noteService = ref.watch(firestoreNoteServiceProvider);
  return noteService.getSpaceNotesStream(spaceId);
});

// SPACE TASKS
final spaceTasksProvider =
    StreamProvider.family<List<TaskModel>, String>((ref, spaceId) {
  final taskService = ref.watch(firestoreTaskServiceProvider);
  return taskService.getSpaceTasksStream(spaceId);
});

// SPACE FILES (Mock for now)
final spaceFilesProvider =
    StreamProvider.family<List<FileModel>, String>((ref, spaceId) {
  return Stream.value([]);
});

// SPECIFIC NOTE
final noteProvider = FutureProvider.family<NoteModel?, String>((ref, noteId) {
  final noteService = ref.watch(firestoreNoteServiceProvider);
  return noteService.getNoteById(noteId);
});

// SPECIFIC TASK
final taskProvider = FutureProvider.family<TaskModel?, String>((ref, taskId) {
  final taskService = ref.watch(firestoreTaskServiceProvider);
  return taskService.getTaskById(taskId);
});

// SPECIFIC FILE (Mock for now)
final fileProvider =
    FutureProvider.family<FileModel?, String>((ref, fileId) {
  return Future.value(null);
});

// CREATE SPACE CONTROLLER
final createSpaceControllerProvider =
    StateNotifierProvider<CreateSpaceController, AsyncValue<String?>>((ref) {
  return CreateSpaceController(ref);
});

class CreateSpaceController extends StateNotifier<AsyncValue<String?>> {
  final Ref ref;

  CreateSpaceController(this.ref) : super(const AsyncValue.data(null));

  Future<void> createSpace({
    required String name,
    required String description,
    required SpaceType type,
    String? photoUrl,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('No user logged in');

      final spaceService = ref.read(firestoreSpaceServiceProvider);

      final newSpace = SpaceModel(
        id: '',
        name: name,
        description: description,
        photoUrl: photoUrl,
        type: type,
        ownerId: userId,
        members: [
          SpaceMember(
            userId: userId,
            displayName: '',
            role: UserRole.admin,
            joinedAt: DateTime.now(),
          ),
        ],
        noteIds: [],
        taskIds: [],
        fileIds: [],
        settings: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final spaceId = await spaceService.createSpace(newSpace);
      state = AsyncValue.data(spaceId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// UPDATE SPACE CONTROLLER
final updateSpaceControllerProvider =
    StateNotifierProvider<UpdateSpaceController, AsyncValue<void>>((ref) {
  return UpdateSpaceController(ref);
});

class UpdateSpaceController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  UpdateSpaceController(this.ref) : super(const AsyncValue.data(null));

  Future<void> updateSpace(SpaceModel space) async {
    state = const AsyncValue.loading();

    try {
      final spaceService = ref.read(firestoreSpaceServiceProvider);
      await spaceService.updateSpace(space);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// CREATE NOTE CONTROLLER
final createNoteControllerProvider =
    StateNotifierProvider<CreateNoteController, AsyncValue<String?>>((ref) {
  return CreateNoteController(ref);
});

class CreateNoteController extends StateNotifier<AsyncValue<String?>> {
  final Ref ref;

  CreateNoteController(this.ref) : super(const AsyncValue.data(null));

  Future<void> createNote({
    required String spaceId,
    required String title,
    required String content,
    String? htmlContent,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('No user logged in');

      final noteService = ref.read(firestoreNoteServiceProvider);

      final newNote = NoteModel(
        id: '',
        spaceId: spaceId,
        title: title,
        content: content,
        htmlContent: htmlContent,
        createdBy: userId,
        lastEditedBy: userId,
        collaborators: [userId],
        pinnedBy: [],
        reactions: {},
        comments: [],
        isArchived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final noteId = await noteService.createNote(newNote);
      state = AsyncValue.data(noteId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// UPDATE NOTE CONTROLLER
final updateNoteControllerProvider =
    StateNotifierProvider<UpdateNoteController, AsyncValue<void>>((ref) {
  return UpdateNoteController(ref);
});

class UpdateNoteController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  UpdateNoteController(this.ref) : super(const AsyncValue.data(null));

  Future<void> updateNote(NoteModel note) async {
    state = const AsyncValue.loading();

    try {
      final noteService = ref.read(firestoreNoteServiceProvider);
      await noteService.updateNote(note);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// CREATE TASK CONTROLLER
final createTaskControllerProvider =
    StateNotifierProvider<CreateTaskController, AsyncValue<String?>>((ref) {
  return CreateTaskController(ref);
});

class CreateTaskController extends StateNotifier<AsyncValue<String?>> {
  final Ref ref;

  CreateTaskController(this.ref) : super(const AsyncValue.data(null));

  Future<void> createTask({
    required String spaceId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    String? assigneeId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('No user logged in');

      final taskService = ref.read(firestoreTaskServiceProvider);

      final newTask = TaskModel(
        id: '',
        spaceId: spaceId,
        title: title,
        description: description,
        status: TaskStatus.pending,
        priority: priority,
        assigneeId: assigneeId,
        createdBy: userId,
        lastEditedBy: userId,
        collaborators: [userId],
        pinnedBy: [],
        reactions: {},
        comments: [],
        attachments: [],
        isArchived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        dueDate: dueDate,
      );

      final taskId = await taskService.createTask(newTask);
      state = AsyncValue.data(taskId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// UPDATE TASK CONTROLLER
final updateTaskControllerProvider =
    StateNotifierProvider<UpdateTaskController, AsyncValue<void>>((ref) {
  return UpdateTaskController(ref);
});

class UpdateTaskController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  UpdateTaskController(this.ref) : super(const AsyncValue.data(null));

  Future<void> updateTask(TaskModel task) async {
    state = const AsyncValue.loading();

    try {
      final taskService = ref.read(firestoreTaskServiceProvider);
      await taskService.updateTask(task);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// Search Notes Controller
final searchNotesControllerProvider =
    StateNotifierProvider<SearchNotesController, AsyncValue<List<NoteModel>>>((ref) {
  return SearchNotesController(ref);
});

class SearchNotesController extends StateNotifier<AsyncValue<List<NoteModel>>> {
  final Ref ref;

  SearchNotesController(this.ref) : super(const AsyncValue.data([]));

  Future<void> search(String spaceId, String query) async {
    state = const AsyncValue.loading();

    try {
      if (query.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      final noteService = ref.read(firestoreNoteServiceProvider);
      final results = await noteService.searchNotes(spaceId, query);
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// Overdue Tasks Provider
final overdueTasksProvider =
    FutureProvider.family<List<TaskModel>, String>((ref, spaceId) {
  final taskService = ref.watch(firestoreTaskServiceProvider);
  return taskService.getOverdueTasks(spaceId);
});
