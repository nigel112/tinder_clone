import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zimdate/common/errors/errors.dart';
import 'package:zimdate/common/utils/phone_utils.dart';
import 'package:zimdate/src/application/auth_service.dart';

import '../screens/code_screen.dart';
import '../screens/home_screen.dart';


final phoneLoginScreenProvider = AsyncNotifierProvider<PhoneLoginScreenNotifier, String>(PhoneLoginScreenNotifier.new);


class PhoneLoginScreenNotifier extends AsyncNotifier<String>{

  ProviderSubscription? subscription;

  @override
  FutureOr<String> build() {
    return "";
  }

  Future<void> loginWithPhoneNumber(BuildContext context, String rawCountryCode, String rawPhoneNumber) async{
    // Normalise first so that "0771 234 567" with country code "263" becomes
    // +263771234567 rather than the invalid +2630771234567.
    final number = PhoneUtils.build(
      countryCode: rawCountryCode,
      phoneNumber: rawPhoneNumber,
    );

    final problem = PhoneUtils.validate(number);
    if (problem != null) {
      state = AsyncValue.error(_messageFor(problem), StackTrace.empty);
      return;
    }

    state = const AsyncLoading();

    final authService = ref.read(authServiceProvider);

    var result = await authService.signInWithPhone(number.e164);

    result.fold((left) {
      if(left is NotAutomaticRetrieved){
        // Stop listening before leaving, otherwise an error dialog could pop
        // on a screen that is no longer visible.
        subscription?.close();
        state = const AsyncValue.data("");
        Navigator.pushNamed(context, CodeScreen.routeName,
              arguments: left.verificationId);
      }else{
        state = AsyncValue.error(left.message, StackTrace.empty);
      }
    }, (right){
      state = const AsyncValue.data("");
      subscription?.close();
      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
    });
  }

  void setSub(ProviderSubscription subscription){
    this.subscription = subscription;
  }

  String _messageFor(PhoneNumberProblem problem){
    switch(problem){
      case PhoneNumberProblem.empty:
        return "please_enter_your_phone_number".tr();
      case PhoneNumberProblem.tooShort:
        return "phone_number_short".tr();
      case PhoneNumberProblem.tooLong:
        return "phone_number_long".tr();
      case PhoneNumberProblem.badCountryCode:
        return "country_code_long".tr();
    }
  }
}
