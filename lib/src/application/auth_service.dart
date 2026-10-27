import 'package:easy_localization/easy_localization.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zimdate/common/errors/errors.dart';
import 'package:zimdate/src/data/auth_repository.dart';
import 'package:zimdate/src/data/user_repository.dart';

import '../../common/repositories/common_messaging_repository.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthService(ref, authRepository);
});

class AuthService {
  AuthService(this.ref, this.authRepository);
  final Ref ref;
  final AuthRepository authRepository;

  Future<Either<Failture, void>> signInWithPhone(String phoneNumber) async {
    try {
      return Right(await authRepository.signInWithPhone(phoneNumber));
    } on Failture catch (e) {
      // Keep the real reason: NotAutomaticRetrieved, or the Firebase error
      // mapped in AuthRepository. Flattening everything into one generic
      // string is what made login failures impossible to diagnose.
      return Left(e);
    } catch (e) {
      return Left(ErrorLoginPhone("phone_login_error".tr()));
    }
  }

  Future<Either<Failture, bool>> verifyCode(
      String verificationId, String smsCode) async {
    try {
      await authRepository.verifyCode(verificationId, smsCode);
      return Right(await _updateUserOrNextStep());
    } on Failture catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ErrorLoginPhone("invalid_code".tr()));
    }
  }

  Future<bool> _updateUserOrNextStep() async {
    String uid = authRepository.authUserUid!;
    bool isUserExists =
        await ref.read(userRepositoryProvider).isUserExists(uid);

    if (isUserExists) {
      String? token = await MessagingApi().getToken();
      await ref.read(userRepositoryProvider).updateUserFcmToken(uid, token);

      return true;
    } else {
      return false;
    }
  }
}
