import 'package:Talab/utils/login/lib/login_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:Talab/utils/login/lib/login_system.dart';

class AppleLogin extends LoginSystem {
  OAuthCredential? credential;
  OAuthProvider? oAuthProvider;

  @override
  void init() async {}

  Future<UserCredential?> login() async {
    print("Starting Apple Sign-In process...");
    try {
      emit(MProgress());
      print("Emitted MProgress");

      print("Fetching Apple ID credential...");
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      print("Apple ID credential fetched: Token=${appleIdCredential.identityToken}, Code=${appleIdCredential.authorizationCode}");

      if (appleIdCredential.identityToken == null) {
        print("Missing Apple token or code");
        emit(MFail("Missing Apple token or code"));
        return null;
      }

      print("Creating OAuth credential...");
      oAuthProvider = OAuthProvider('apple.com');
      credential = oAuthProvider!.credential(
        idToken: appleIdCredential.identityToken!,
        accessToken: appleIdCredential.authorizationCode,
      );
      print("OAuth credential created");

      print("Signing in with Firebase...");
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential!);
      print("Firebase sign-in successful: User UID=${userCredential.user?.uid}, Email=${userCredential.user?.email}");

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        try {
          final displayName = "${appleIdCredential.givenName ?? ''} ${appleIdCredential.familyName ?? ''}".trim();
          if (displayName.isNotEmpty) {
            print("Updating user display name to: $displayName");
            await userCredential.user?.updateDisplayName(displayName);
            await userCredential.user?.reload();
            print("User profile updated to: $displayName");
          }
        } catch (updateError) {
          print("Failed to update user profile: $updateError");
        }
      }

      emit(MSuccess());
      print("Emitted MSuccess");
      return userCredential;
    } catch (e) {
      print("Apple login error caught: $e");
      if (e is FirebaseAuthException) {
        print("Firebase error details: Code=${e.code}, Message=${e.message}");
      }
      emit(MFail(e.toString()));
      print("Emitted MFail with error: $e");
      return null;
    }
  }

  @override
  void onEvent(MLoginState state) {
    print("Login state event: $state");
  }
}