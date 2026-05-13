import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twodo/core/constants/app_constants.dart';
import 'package:twodo/core/utils/app_exceptions.dart';
import 'package:twodo/data/models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isAuthenticated => _auth.currentUser != null;

  // SIGN UP WITH EMAIL
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw ValidationException(message: 'Email and password are required');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw AuthException(
        message: 'An error occurred during sign up',
        originalException: e,
      );
    }
  }

  // LOGIN WITH EMAIL
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw ValidationException(message: 'Email and password are required');
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw AuthException(
        message: 'An error occurred during login',
        originalException: e,
      );
    }
  }

  // LOGIN WITH GOOGLE
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // For web, you'd use GoogleSignInWeb
      // For mobile, you'd use GoogleSignIn
      return null;
    } catch (e) {
      throw AuthException(
        message: 'Google sign in failed',
        originalException: e,
      );
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException(
        message: 'An error occurred during logout',
        originalException: e,
      );
    }
  }

  // RESET PASSWORD
  Future<void> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        throw ValidationException(message: 'Email is required');
      }
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw AuthException(
        message: 'An error occurred sending password reset',
        originalException: e,
      );
    }
  }

  // UPDATE PROFILE
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No user is currently logged in');
      }

      await user.updateDisplayName(displayName ?? user.displayName);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }
      await user.reload();
    } catch (e) {
      throw AuthException(
        message: 'Failed to update profile',
        originalException: e,
      );
    }
  }

  // GET USER EMAIL VERIFICATION STATUS
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // SEND EMAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No user is currently logged in');
      }
      await user.sendEmailVerification();
    } catch (e) {
      throw AuthException(
        message: 'Failed to send email verification',
        originalException: e,
      );
    }
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      throw AuthException(
        message: 'Failed to delete account',
        originalException: e,
      );
    }
  }

  String _getAuthErrorMessage(String code) {
    return switch (code) {
      'user-not-found' => 'No user found with that email',
      'wrong-password' => 'Wrong password provided',
      'email-already-in-use' => 'Email is already in use',
      'invalid-email' => 'Invalid email address',
      'weak-password' => 'Password is too weak',
      'user-disabled' => 'User account has been disabled',
      'operation-not-allowed' => 'Operation not allowed',
      'invalid-credential' => 'Invalid credentials',
      'too-many-requests' => 'Too many requests. Please try again later',
      _ => 'An authentication error occurred',
    };
  }
}

class FirestoreUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE USER PROFILE
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    try {
      final user = UserModel(
        id: userId,
        email: email,
        displayName: displayName,
        spaceIds: [],
        preferences: {},
        isOnline: true,
        lastSeenAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .set(user.toFirestore());
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to create user profile',
        code: e.code,
        originalException: e,
      );
    }
  }

  // GET USER BY ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to fetch user',
        code: e.code,
        originalException: e,
      );
    }
  }

  // UPDATE USER PROFILE
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(user.toFirestore());
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to update user profile',
        code: e.code,
        originalException: e,
      );
    }
  }

  // UPDATE USER ONLINE STATUS
  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'isOnline': isOnline,
        'lastSeenAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to update online status',
        code: e.code,
        originalException: e,
      );
    }
  }

  // GET USER STREAM
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return UserModel.fromFirestore(doc);
        });
  }

  // SEARCH USERS
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + 'z')
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to search users',
        code: e.code,
        originalException: e,
      );
    }
  }
}