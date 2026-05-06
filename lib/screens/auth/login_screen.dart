import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final AuthService _authService =
      AuthService();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool loading = false;

  // EMAIL LOGIN
  Future<void> login() async {
    try {
      setState(() {
        loading = true;
      });

      await _authService.login(
        email:
            emailController.text.trim(),
        password:
            passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Login Successful'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  // GOOGLE LOGIN
  Future<void> googleLogin() async {
    try {
      await _authService
          .signInWithGoogle();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Google Login Successful',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twoदो'),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [

            // EMAIL
            TextField(
              controller:
                  emailController,

              decoration:
                  const InputDecoration(
                hintText: 'Email',
              ),
            ),

            const SizedBox(height: 20),

            // PASSWORD
            TextField(
              controller:
                  passwordController,

              obscureText: true,

              decoration:
                  const InputDecoration(
                hintText: 'Password',
              ),
            ),

            const SizedBox(height: 30),

            // LOGIN BUTTON
            ElevatedButton(
              onPressed:
                  loading ? null : login,

              child: loading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Login',
                    ),
            ),

            const SizedBox(height: 20),

            // GOOGLE BUTTON
            ElevatedButton(
              onPressed: googleLogin,

              child: const Text(
                'Continue with Google',
              ),
            ),

            const SizedBox(height: 20),

            // SIGNUP
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const SignupScreen(),
                  ),
                );
              },

              child: const Text(
                'Create Account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}