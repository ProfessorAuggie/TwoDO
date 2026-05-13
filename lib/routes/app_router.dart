import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twodo/presentation/pages/auth/login_screen.dart';
import 'package:twodo/presentation/pages/auth/signup_screen.dart';
import 'package:twodo/presentation/pages/onboarding/splash_screen.dart';
import 'package:twodo/presentation/pages/home/home_screen.dart';
import 'package:twodo/presentation/pages/spaces/space_detail_screen.dart';
import 'package:twodo/presentation/pages/spaces/create_space_screen.dart';
import 'package:twodo/presentation/pages/profile/profile_screen.dart';
import 'package:twodo/presentation/pages/notes/notes_list_screen.dart';
import 'package:twodo/presentation/pages/notes/create_note_screen.dart';
import 'package:twodo/presentation/pages/notes/note_detail_screen.dart';
import 'package:twodo/presentation/pages/tasks/tasks_list_screen.dart';
import 'package:twodo/presentation/pages/tasks/create_task_screen.dart';
import 'package:twodo/presentation/pages/tasks/task_detail_screen.dart';
import 'package:twodo/presentation/pages/files/files_list_screen.dart';
import 'package:twodo/presentation/pages/files/upload_file_screen.dart';
import 'package:twodo/presentation/pages/files/file_detail_screen.dart';

class AppRouter {
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String createSpaceRoute = '/create-space';
  static const String spaceRoute = '/space/:spaceId';
  static const String profileRoute = '/profile';

  static GoRouter router(AsyncValue<User?> authState) {
    return GoRouter(
      redirect: (context, state) async {
        final user = authState.maybeWhen(
          data: (data) => data,
          orElse: () => null,
        );

        // If user is null, redirect to login (unless on splash)
        if (user == null) {
          if (state.matchedLocation == splashRoute) {
            return splashRoute;
          }
          return loginRoute;
        }

        // If user is logged in and trying to access auth routes, redirect to home
        if (state.matchedLocation == loginRoute ||
            state.matchedLocation == signupRoute) {
          return homeRoute;
        }

        return null; // No redirect needed
      },
      initialLocation: splashRoute,
      routes: [
        GoRoute(
          path: splashRoute,
          pageBuilder: (context, state) => const MaterialPage(
            child: SplashScreen(),
          ),
        ),
        GoRoute(
          path: loginRoute,
          pageBuilder: (context, state) => const MaterialPage(
            child: LoginScreen(),
          ),
        ),
        GoRoute(
          path: signupRoute,
          pageBuilder: (context, state) => const MaterialPage(
            child: SignupScreen(),
          ),
        ),
        GoRoute(
          path: homeRoute,
          pageBuilder: (context, state) => const MaterialPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: createSpaceRoute,
          pageBuilder: (context, state) => const MaterialPage(
            child: CreateSpaceScreen(),
          ),
        ),
        GoRoute(
          path: spaceRoute,
          pageBuilder: (context, state) {
            final spaceId = state.pathParameters['spaceId']!;
            return MaterialPage(
              child: SpaceDetailScreenNew(spaceId: spaceId),
            );
          },
          routes: [
            // Notes Routes
            GoRoute(
              path: 'notes',
              pageBuilder: (context, state) {
                final spaceId = state.pathParameters['spaceId']!;
                return MaterialPage(
                  child: NotesListScreen(spaceId: spaceId),
                );
              },
              routes: [
                GoRoute(
                  path: 'create',
                  pageBuilder: (context, state) {
                    final spaceId = state.pathParameters['spaceId']!;
                    return MaterialPage(
                      child: CreateNoteScreen(spaceId: spaceId),
                    );
                  },
                ),
                GoRoute(
                  path: ':noteId',
                  pageBuilder: (context, state) {
                    final noteId = state.pathParameters['noteId']!;
                    return MaterialPage(
                      child: NoteDetailScreen(noteId: noteId),
                    );
                  },
                ),
              ],
            ),
            // Tasks Routes
            GoRoute(
              path: 'tasks',
              pageBuilder: (context, state) {
                final spaceId = state.pathParameters['spaceId']!;
                return MaterialPage(
                  child: TasksListScreen(spaceId: spaceId),
                );
              },
              routes: [
                GoRoute(
                  path: 'create',
                  pageBuilder: (context, state) {
                    final spaceId = state.pathParameters['spaceId']!;
                    return MaterialPage(
                      child: CreateTaskScreen(spaceId: spaceId),
                    );
                  },
                ),
                GoRoute(
                  path: ':taskId',
                  pageBuilder: (context, state) {
                    final taskId = state.pathParameters['taskId']!;
                    return MaterialPage(
                      child: TaskDetailScreen(taskId: taskId),
                    );
                  },
                ),
              ],
            ),
            // Files Routes
            GoRoute(
              path: 'files',
              pageBuilder: (context, state) {
                final spaceId = state.pathParameters['spaceId']!;
                return MaterialPage(
                  child: FilesListScreen(spaceId: spaceId),
                );
              },
              routes: [
                GoRoute(
                  path: 'upload',
                  pageBuilder: (context, state) {
                    final spaceId = state.pathParameters['spaceId']!;
                    return MaterialPage(
                      child: UploadFileScreen(spaceId: spaceId),
                    );
                  },
                ),
                GoRoute(
                  path: ':fileId',
                  pageBuilder: (context, state) {
                    final fileId = state.pathParameters['fileId']!;
                    return MaterialPage(
                      child: FileDetailScreen(fileId: fileId),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: profileRoute,
          pageBuilder: (context, state) => const MaterialPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    );
  }
}
