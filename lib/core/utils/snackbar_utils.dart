import 'package:flutter/material.dart';

class SnackbarUtils {
  static void showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showInfo(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.blue.shade600,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
