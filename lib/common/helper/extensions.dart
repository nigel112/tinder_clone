import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zimdate/common/helper/show_alert_dialog.dart';

extension AsyncValueUI on AsyncValue {
  void showDialogOnError(BuildContext context) {
    if (!isRefreshing && hasError && !isLoading) {
          showAlertDialog(context: context, message: error.toString());
        }
  }
}