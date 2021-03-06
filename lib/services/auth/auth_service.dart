import 'package:oktava/services/auth/auth_provider.dart';
import 'package:oktava/services/auth/auth_user.dart';
import 'package:oktava/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
    String? userName,
    String? userProfileImage,
  }) =>
      provider.createUser(
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<AuthUser> logIn({required String email, required String password}) =>
      provider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);

  @override
  Future<AuthUser> getAlreadyAuthUser({required String userId}) =>
      provider.getAlreadyAuthUser(userId: userId);

  @override
  Future<void> updateAuthUSer(
          {required String userId,
          String? userName,
          bool? isVerified,
          String? userProfileImage}) =>
      provider.updateAuthUSer(
        userId: userId,
        userName: userName,
        isVerified: isVerified,
        userProfileImage: userProfileImage,
      );
}
