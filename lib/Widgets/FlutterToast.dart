import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';

class FlushbarHelper {
  static void showSuccess(String message, BuildContext context) {
    showFlushbar(
      context: context,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.easeInOut,
        reverseAnimationCurve: Curves.easeInOut,
        borderRadius: BorderRadius.circular(8),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        flushbarPosition: FlushbarPosition.BOTTOM,
        message: message,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        positionOffset: 20,
        title: "Success",
        icon: const Icon(Icons.check_circle, color: Colors.white),
        messageColor: Colors.white,
      )..show(context),
    );
  }

  static void showError(String message, BuildContext context) {
    showFlushbar(
      context: context,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.easeInOut,
        reverseAnimationCurve: Curves.easeInOut,
        borderRadius: BorderRadius.circular(8),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        flushbarPosition: FlushbarPosition.BOTTOM,
        message: message,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        positionOffset: 20,
        title: "Error",
        icon: const Icon(Icons.error, color: Colors.white),
        messageColor: Colors.white,
      )..show(context),
    );
  }
}
