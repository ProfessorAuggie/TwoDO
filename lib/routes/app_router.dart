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
              child: SpaceDetailScreen(spaceId: spaceId),
            );
          },
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
