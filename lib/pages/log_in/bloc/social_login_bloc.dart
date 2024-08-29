import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/response_model/create_profile_response_model.dart';
import 'package:ridealike/pages/log_in/request_service/social_logIn.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:rxdart/rxdart.dart';

import '../request_service/sign_in_google.dart';

class SocialLogInBloc extends BaseBloc {
  //progressIndicator//
  final _progressIndicatorController = BehaviorSubject<int>();

  final storage = new FlutterSecureStorage();

  Function(int) get changedProgressIndicator =>
      _progressIndicatorController.sink.add;

  Stream<int> get progressIndicator => _progressIndicatorController.stream;

  @override
  void dispose() {
    _progressIndicatorController.close();
  }

  /*socialLogWithAppleId() async {
    var appleLogInCompleter = Completer<CreateProfileResponse>();
    String firstName;
    String lastName;
    String code;

    var credential = null;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
    } catch (e) {}

    if (credential == null) {
      Future.delayed(Duration.zero, () {
        appleLogInCompleter.complete(null);
      });
    } else {
      print('AppleCredentials $credential');
      if (credential.givenName != null) firstName = credential.givenName;
      if (credential.familyName != null) lastName = credential.familyName;
      code = credential.authorizationCode;
      print(lastName);

      await appleSocialLogin(code, firstName, lastName, 'Apple', 'Ios')
          .then((res) async {
        if (res.statusCode == 200) {
          AppEventsUtils.logEvent("user_login",
              params: {"login_type": "apple"});
          var arguments = CreateProfileResponse.fromJson(json.decode(res.body));
          if (arguments != null && arguments.user != null) {
            await storage.delete(key: 'profile_id');
            await storage.delete(key: 'user_id');
            // await storage.delete(key: 'user_emailId');
            await storage.write(key: 'jwt', value: arguments.jWT);
          }
          appleLogInCompleter.complete(arguments);
        } else {
          // appleLogInCompleter.complete(null);
          var arguments = CreateProfileResponse.fromJson(json.decode(res.body));
          appleLogInCompleter.complete(arguments);
        }
        // TODO:: Show error message
      });
    }

    return appleLogInCompleter.future;
  }

  socialLogWithFacebook() async {
    var socialLogInCompleter = Completer<CreateProfileResponse>();
    signInWitFacebook().then((fLoginRes) async {
      if (fLoginRes.status == 'success') {
        await socialLogin(
          fLoginRes.facebookUser.idToken,
          'Facebook',
        ).then((res) async {
          if (res.statusCode == 200) {
            AppEventsUtils.logEvent("user_login",
                params: {"login_type": "facebook"});
            var arguments =
                CreateProfileResponse.fromJson(json.decode(res.body));
            if (arguments != null && arguments.user != null) {
              await storage.delete(key: 'profile_id');
              await storage.delete(key: 'user_id');
              // await storage.delete(key: 'user_emailId');
              await storage.write(key: 'jwt', value: arguments.jWT);
            }

            socialLogInCompleter.complete(arguments);
            //loader false//
          } else {
            var arguments =
                CreateProfileResponse.fromJson(json.decode(res.body));
            socialLogInCompleter.complete(arguments);
          }
        });
      } else {
        socialLogInCompleter.complete(null);
      }
    });
    return socialLogInCompleter.future;
  }*/

  Future<CreateProfileResponse?> socialLogWithGoogle() async {
    var googleLogInCompleter = Completer<CreateProfileResponse?>();
    signInWithGoogle().then((gLoginRes) async {
      debugPrint("signInWithGoogle");
      if (gLoginRes != null && gLoginRes.status == 'success') {
        debugPrint("signInWithGoogle if");
        await socialLogin(
          gLoginRes.googleUser.idToken,
          'Google',
        ).then((res) async {
          debugPrint("socialLogin then");
          if (res.statusCode == 200) {
            AppEventsUtils.logEvent("user_login",
                params: {"login_type": "google"});
            var arguments =
            CreateProfileResponse.fromJson(json.decode(res.body!));
            if (arguments.user != null) {
              await storage.delete(key: 'profile_id');
              await storage.delete(key: 'user_id');
              // await storage.delete(key: 'user_emailId');
              await storage.write(key: 'jwt', value: arguments.jWT);
            }
            googleLogInCompleter.complete(arguments);
          } else {
            var arguments =
            CreateProfileResponse.fromJson(json.decode(res.body!));
            googleLogInCompleter.complete(arguments);
          }
        });
      } else {
        googleLogInCompleter.complete(null);
      }
      // googleLogInCompleter.complete(null);
      // TODO:: Show error message
    });
    return googleLogInCompleter.future;
  }
}
