import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [
    'openid',
    'email',
    'profile',
  ],
);

/*Future<GoogleLoginResponse?> signInWithGoogle() async {
  GoogleUser? googleUser;
  var completer = Completer<GoogleLoginResponse?>();
  try {
    await googleSignIn.signOut();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    googleUser = GoogleUser(
      displayName: googleSignInAccount.displayName!,
      id: googleSignInAccount.id,
      email: googleSignInAccount.email,
      idToken: googleSignInAuthentication.idToken!,
    );
    var user = GoogleLoginResponse(
        googleUser: googleUser,
        message: 'Logged in successfully',
        status: 'success');
    completer.complete(user);
  } catch (e) {
    print(e);
    completer.complete(null);
    print('${e.toString()}');
  }
  return completer.future;
}*/

Future<GoogleLoginResponse?> signInWithGoogle() async {
  GoogleUser? googleUser;
  var completer = Completer<GoogleLoginResponse?>();
  try {
    await googleSignIn.signOut();
    debugPrint("signout");
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    debugPrint("signin");
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    debugPrint("authentication");
    googleUser = GoogleUser(
      displayName: googleSignInAccount.displayName!,
      id: googleSignInAccount.id,
      email: googleSignInAccount.email,
      idToken: googleSignInAuthentication.idToken!,
    );
    debugPrint("googleUser");
    var user = GoogleLoginResponse(
        googleUser: googleUser,
        message: 'Logged in successfully',
        status: 'success');
    completer.complete(user);
  } catch (e) {
    print(e);
    completer.complete(null);
    print('${e.toString()}');
  }
  return completer.future;
}

void signOutGoogle() async {
  await googleSignIn.signOut();

  print("User Sign Out");
}

class GoogleLoginResponse {
  GoogleUser googleUser;
  String message;
  String status;

  GoogleLoginResponse({
    required this.googleUser,
    required this.message,
    required this.status,
  });
}

class GoogleUser {
  String email;
  String displayName;
  String id;
  String idToken;

  GoogleUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.idToken,
  });
}
