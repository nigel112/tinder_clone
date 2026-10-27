import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/errors/errors.dart';

/// How long Firebase should attempt automatic SMS retrieval before giving up.
const Duration kAutoRetrievalTimeout = Duration(seconds: 60);

final authRepositoryProvider = Provider((ref) => AuthRepository(
    auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));

final authStateChangeProvider = StreamProvider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChange;
});

/// Turns a Firebase Auth error into something a user or developer can act on.
///
/// Firebase's own message is already localised, but the codes that are pure
/// project misconfiguration get an explicit explanation, because
/// "operation-not-allowed" (SMS region not enabled / billing not enabled) is
/// the most common login blocker and is impossible to guess from the UI.
ErrorLoginPhone _mapAuthFailure(FirebaseAuthException e) {
  String message;
  switch (e.code) {
    case 'operation-not-allowed':
      message = "error_sms_not_allowed".tr();
      break;
    case 'invalid-phone-number':
      message = "error_invalid_phone_number".tr();
      break;
    case 'too-many-requests':
      message = "error_too_many_requests".tr();
      break;
    case 'quota-exceeded':
      message = "error_sms_quota".tr();
      break;
    case 'app-not-authorized':
      message = "error_app_not_authorized".tr();
      break;
    case 'billing-not-enabled':
      message = "error_billing_required".tr();
      break;
    case 'network-request-failed':
      message = "error_network".tr();
      break;
    case 'invalid-verification-code':
      message = "invalid_code".tr();
      break;
    case 'session-expired':
      message = "error_code_expired".tr();
      break;
    default:
      final own = e.message;
      message = (own != null && own.isNotEmpty)
          ? own
          : "${"error_sms_generic".tr()} (${e.code})";
  }
  return ErrorLoginPhone(message, code: e.code);
}

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  Future<void> signInWithPhone(String phoneNumber) async {
    final completer = Completer<AuthCredential>();

    await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: kAutoRetrievalTimeout,
        verificationCompleted: (PhoneAuthCredential credential) {
          if (!completer.isCompleted) completer.complete(credential);
        },
        verificationFailed: (e) {
          final failure = e is FirebaseAuthException
              ? _mapAuthFailure(e)
              : ErrorLoginPhone("error_sms_generic".tr(), code: e.toString());
          if (!completer.isCompleted) completer.completeError(failure);
        },
        codeSent: (String verificationId, int? resendingToken) {
          // Not a failure for the user: they just have to type the code.
          if (!completer.isCompleted) {
            completer.completeError(
                NotAutomaticRetrieved(verificationId, "Code sent"));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Without this the Completer would stay pending forever if codeSent
          // never fired, leaving the user stuck on a spinner.
          if (!completer.isCompleted) {
            completer.completeError(NotAutomaticRetrieved(
                verificationId, "Auto-retrieval timed out"));
          }
        });

    final credential = await completer.future;
    await auth.signInWithCredential(credential);
  }

  Future<void> verifyCode(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      await auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthFailure(e);
    }
  }

  Stream<User?> get authStateChange => auth.authStateChanges();

  String? get authUserUid => auth.currentUser?.uid;
}
