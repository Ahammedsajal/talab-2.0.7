// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:Talab/data/cubits/auth/authentication_cubit.dart';
import 'package:Talab/data/repositories/auth_repository.dart';
import 'package:Talab/utils/api.dart';
import 'package:Talab/utils/hive_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginSuccess extends LoginState {
  final bool isProfileCompleted;
  final UserCredential credential;
  final Map<String, dynamic> apiResponse;

  LoginSuccess({
    required this.isProfileCompleted,
    required this.credential,
    required this.apiResponse,
  });
}

class LoginFailure extends LoginState {
  final dynamic errorMessage;

  LoginFailure(this.errorMessage);
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final AuthRepository _authRepository = AuthRepository();

  Future<String?> getDeviceToken() async {
    String? token;
    if (Platform.isIOS) {
      token = await FirebaseMessaging.instance.getAPNSToken();
    } else {
      token = await FirebaseMessaging.instance.getToken();
    }
    return token;
  }

  void login({
  String? phoneNumber,
  required String firebaseUserId,
  required String type,
  required UserCredential credential,
  String? countryCode,
}) async {
  try {
    emit(LoginInProgress());
    print("LoginCubit: Starting login for user $firebaseUserId, type: $type");

    String? token = await () async {
      try {
        return await FirebaseMessaging.instance.getToken();
      } catch (_) {
        return '';
      }
    }();
    print("LoginCubit: FCM token: $token");

    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    User? updatedUser;
    if (type == AuthenticationType.apple.name) {
      updatedUser = firebaseAuth.currentUser;
      if (updatedUser != null) {
        print("LoginCubit: Updated Display Name: ${updatedUser.displayName}");
        await updatedUser.reload();
        updatedUser = firebaseAuth.currentUser; // Refresh user after reload
      } else {
        print("LoginCubit: No current user found after Apple Sign-In");
        throw Exception("User not found after Apple Sign-In");
      }
    }

    // Handle null values for Apple Sign-In
    String? email = credential.user != null && credential.user!.providerData.isNotEmpty
        ? credential.user!.providerData[0].email
        : (type == AuthenticationType.apple.name
            ? 'apple_private_${firebaseUserId}@example.com' // Fallback for Apple Sign-In
            : '');
    String? phone = phoneNumber ??
        (credential.user != null && credential.user!.providerData.isNotEmpty
            ? credential.user!.providerData[0].phoneNumber
            : '');
    String? photoUrl = credential.user != null && credential.user!.providerData.isNotEmpty
        ? credential.user!.providerData[0].photoURL
        : '';
    String? displayName = type == AuthenticationType.apple.name
        ? updatedUser?.displayName ??
            (credential.user?.displayName ??
                (credential.user != null && credential.user!.providerData.isNotEmpty
                    ? credential.user!.providerData[0].displayName
                    : ''))
        : (credential.user != null && credential.user!.providerData.isNotEmpty
            ? credential.user!.providerData[0].displayName
            : '');

    print("LoginCubit: Email: $email, Phone: $phone, Name: $displayName, Photo: $photoUrl");

    Map<String, dynamic> result = await _authRepository.numberLoginWithApi(
      phone: phone,
      type: type,
      uid: firebaseUserId,
      fcmId: token,
      email: email,
      name: displayName,
      profile: photoUrl,
      countryCode: countryCode,
    );

    print("LoginCubit: API response: $result");

    // Storing data to local database {HIVE}
    HiveUtils.setJWT(result['token']);

    if ((result['data']['name'] == "" || result['data']['name'] == null) ||
        (result['data']['email'] == "" || result['data']['email'] == null)) {
      HiveUtils.setProfileNotCompleted();
      var data = result['data'];
      HiveUtils.setUserData(data);
      emit(LoginSuccess(
        apiResponse: Map<String, dynamic>.from(result['data']),
        isProfileCompleted: false,
        credential: credential,
      ));
    } else {
      var data = result['data'];
      HiveUtils.setUserData(data);
      emit(LoginSuccess(
        apiResponse: Map<String, dynamic>.from(result['data']),
        isProfileCompleted: true,
        credential: credential,
      ));
    }
  } catch (e) {
    print("LoginCubit: Error during login: $e");
    if (e is ApiException) {
      print("LoginCubit: API Exception: ${e.errorMessage}"); // Use errorMessage instead of message
    } else {
      print("LoginCubit: Non-API Exception: $e");
    }
    emit(LoginFailure(e));
  }
}
}