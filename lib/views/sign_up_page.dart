import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController photoUrlController = TextEditingController();
  final AuthModel authModel = AuthModel();

  // Add a variable to store validation errors
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Email input field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),

            // Password input field with validation error message
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _passwordError, // Show error message here
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),

            // Name input field
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 10),

            // Profile Photo URL input field
            TextField(
              controller: photoUrlController,
              decoration: const InputDecoration(labelText: 'Profile Photo URL (optional)'),
            ),
            const SizedBox(height: 20),

            // Sign Up button
            ElevatedButton(
              onPressed: () async {
                // Validate password
                if (passwordController.text.length < 6) {
                  setState(() {
                    _passwordError = 'Password should be at least 6 characters';
                  });
                  return;
                }

                // Reset error message if password is valid
                setState(() {
                  _passwordError = null;
                });

                // Attempt to sign up with email and password, and update the profile
                User? user = await authModel.signUp(
                  emailController.text,
                  passwordController.text,
                  name: nameController.text,
                  photoUrl: photoUrlController.text.isNotEmpty
                      ? photoUrlController.text
                      : null,
                );

                // Check if the user was successfully created
                if (user != null) {
                  // Navigate to the Home Page after sign-up
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sign up failed')),
                  );
                }
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
