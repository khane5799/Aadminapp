import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Tween animation for bouncing effect
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Check login status after a short delay (simulate loading)
    Future.delayed(const Duration(seconds: 2), () {
      checkLoginStatus(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Check login status and navigate
  Future<void> checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isAdminLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(
        context,
        Routes.DashboardScreen,
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        Routes.login,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primerycolor,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                "Community Points System",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 40),
              // Loading indicator
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
