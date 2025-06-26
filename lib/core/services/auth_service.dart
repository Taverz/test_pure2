import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final String idCLi =
      "871004286975-5bngk9s3mqnaelvr3o378srm9fvgks8h.apps.googleusercontent.com";

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(clientId: idCLi);
      final googleSignInAccount = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleSignInAccount.authentication;

      if (googleAuth.idToken == null || googleAuth.idToken == null) {
        log('Не получены необходимые токены');
        return null;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user != null) {
        _createOrUpdateUserInFirestore(user).timeout(Duration(seconds: 3)).onError((_,__){});
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      log('Ошибка Firebase Auth: ${e.code} - ${e.message}');
      return null;
    } on PlatformException catch (e) {
      log('Платформенная ошибка: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      log('Неизвестная ошибка: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Stream<User?> get user => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> _createOrUpdateUserInFirestore(User user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
