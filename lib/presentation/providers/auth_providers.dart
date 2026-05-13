import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twodo/services/auth_service.dart';
import 'package:twodo/data/models/user_model.dart';

// Firebase Auth Service Provider
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final firestoreUserServiceProvider = Provider<FirestoreUserService>((ref) {
  return FirestoreUserService();
});

// Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

// Current User ID Provider
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((user) => user?.uid).value;
});

// Current User Data Provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final userService = ref.watch(firestoreUserServiceProvider);
  return userService.getUserById(userId);
});

// Current User Stream Provider
final currentUserStreamProvider = StreamProvider<UserModel?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);

  final userService = ref.watch(firestoreUserServiceProvider);
  return userService.getUserStream(userId);
});

// Auth Loading State
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Auth Error State
final authErrorProvider = StateProvider<String?>((ref) => null);

// Sign Up Controller
final signUpControllerProvider =
    StateNotifierProvider<SignUpController, AsyncValue<void>>((ref) {
  return SignUpController(ref);
});

class SignUpController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  SignUpController(this.ref) : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();

    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final userService = ref.read(firestoreUserServiceProvider);

      final credential = await authService.signUpWithEmail(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await userService.createUserProfile(
          userId: credential.user!.uid,
          email: email,
          displayName: displayName,
        );

        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// Login Controller
final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>((ref) {
  return LoginController(ref);
});

class LoginController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  LoginController(this.ref) : super(const AsyncValue.data(null));

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final authService = ref.read(firebaseAuthServiceProvider);

      await authService.loginWithEmail(
        email: email,
        password: password,
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// Logout Controller
final logoutControllerProvider =
    StateNotifierProvider<LogoutController, AsyncValue<void>>((ref) {
  return LogoutController(ref);
});

class LogoutController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  LogoutController(this.ref) : super(const AsyncValue.data(null));

  Future<void> logout() async {
    state = const AsyncValue.loading();

    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// Password Reset Controller
final passwordResetControllerProvider =
    StateNotifierProvider<PasswordResetController, AsyncValue<void>>((ref) {
  return PasswordResetController(ref);
});

class PasswordResetController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  PasswordResetController(this.ref) : super(const AsyncValue.data(null));

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();

    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.resetPassword(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// Update User Profile Controller
final updateUserProfileControllerProvider =
    StateNotifierProvider<UpdateUserProfileController, AsyncValue<UserModel?>>((ref) {
  return UpdateUserProfileController(ref);
});

class UpdateUserProfileController extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref ref;

  UpdateUserProfileController(this.ref) : super(const AsyncValue.data(null));

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? bio,
  }) async {
    state = const AsyncValue.loading();

    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final userService = ref.read(firestoreUserServiceProvider);
      final userId = ref.read(currentUserIdProvider);

      if (userId == null) throw Exception('No user logged in');

      if (displayName != null || photoUrl != null) {
        await authService.updateUserProfile(
          displayName: displayName,
          photoUrl: photoUrl,
        );
      }

      final currentUser = await userService.getUserById(userId);
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          displayName: displayName ?? currentUser.displayName,
          photoUrl: photoUrl ?? currentUser.photoUrl,
          bio: bio ?? currentUser.bio,
          updatedAt: DateTime.now(),
        );

        await userService.updateUserProfile(updatedUser);
        state = AsyncValue.data(updatedUser);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
