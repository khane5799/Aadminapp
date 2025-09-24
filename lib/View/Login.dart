import 'package:adminapp/Constents/Colors.dart';
import 'package:adminapp/Provider/LoginProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  @override
  void initState() {
    super.initState();
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    loginProvider.checkLoginStatus(context);
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primerycolor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline,
                      size: 100, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    "Login to Community Points System",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.email, color: Colors.white),
                            hintText: "Email",
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email";
                            }
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return "Please enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.white),
                            hintText: "Password",
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your password";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: loginProvider.isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      loginProvider.loginAdmin(
                                        context,
                                        _emailController.text,
                                        _passwordController.text,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: loginProvider.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Login",
                                    style: TextStyle(color: primerycolor),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
