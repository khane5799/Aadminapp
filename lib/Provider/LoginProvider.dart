import 'package:adminapp/Routes/routes.dart';
import 'package:adminapp/Widgets/FlutterToast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Check if admin is already logged in
  Future<void> checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isAdminLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, Routes.DashboardScreen);
    }
  }

  /// Login function
  Future<void> loginAdmin(
      BuildContext context, String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      FlushbarHelper.showError("Email and password are required", context);
      return;
    }

    _setLoading(true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("AdminLogin")
          .where("email", isEqualTo: email.trim())
          .where("password", isEqualTo: password.trim())
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Save login status in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAdminLoggedIn', true);

        FlushbarHelper.showSuccess("Login successful", context);
        Navigator.pushReplacementNamed(context, Routes.DashboardScreen);
      } else {
        FlushbarHelper.showError("Invalid email or password", context);
      }
    } catch (e) {
      FlushbarHelper.showError("Error: $e", context);
    }

    _setLoading(false);
  }

  /// Logout function (optional)
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAdminLoggedIn', false);
    Navigator.pushReplacementNamed(context, Routes.login);
  }
}
