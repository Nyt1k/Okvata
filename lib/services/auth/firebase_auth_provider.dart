import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:oktava/firebase_options.dart';
import 'package:oktava/services/auth/auth_exception.dart';
import 'package:oktava/services/auth/auth_provider.dart';
import 'package:oktava/services/auth/auth_user.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<AuthUser> createUser(
      {required String email,
      required String password,
      String? userName,
      String? userProfileImage}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        await createAlreadyAuthUser(
          userId: currentUser!.id,
          email: user.email,
          isVerified: user.isEmailVerified,
          userName: userName,
          userProfileImage: userProfileImage,
        );
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeekPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        case 'firebase_auth/user-not-found':
          throw UserNotFoundException();
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  // storage AuthUser

  final FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;

  Future<void> createAlreadyAuthUser(
      {required String userId,
      required String email,
      required bool isVerified,
      String? userName,
      String? userProfileImage}) async {
    await firebaseInstance.collection('users').doc(userId).set({
      'email': email,
      'isVerified': isVerified,
      'userName': userName,
      'userProfileImage': userProfileImage,
    });
  }

  @override
  Future<AuthUser> getAlreadyAuthUser({required String userId}) async {
    var user = await firebaseInstance.collection('users').doc(userId).get();
    AuthUser currentUser = AuthUser.fromSnapshot(user);
    return currentUser;
  }

  @override
  Future<void> updateAuthUSer({
    required String userId,
    String? userName,
    bool? isVerified,
    String? userProfileImage,
  }) async {
    if (isVerified != null && userName != null && userProfileImage != null) {
      await firebaseInstance.collection('users').doc(userId).update({
        'isVerified': isVerified,
        'userName': userName,
        'userProfileImage': userProfileImage,
      });
    } else if (isVerified != null && userName != null) {
      await firebaseInstance.collection('users').doc(userId).update({
        'isVerified': isVerified,
        'userName': userName,
      });
    } else if (userName != null && userProfileImage != null) {
      await firebaseInstance.collection('users').doc(userId).update({
        'userName': userName,
        'userProfileImage': userProfileImage,
      });
    } else if (userProfileImage != null && isVerified != null) {
      await firebaseInstance.collection('users').doc(userId).update({
        'isVerified': isVerified,
        'userProfileImage': userProfileImage,
      });
    } else if (userName != null) {
      await firebaseInstance.collection('users').doc(userId).update({
        'userName': userName,
      });
    } else if (isVerified != null) {
      await firebaseInstance.collection('users').doc(userId).update({
        'isVerified': isVerified,
      });
    } else {
      await firebaseInstance.collection('users').doc(userId).update({
        'userProfileImage': userProfileImage,
      });
    }
  }
}
