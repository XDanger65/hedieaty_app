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
  final _formKey = GlobalKey<FormState>();
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header with icon and title
              Column(
                children: [
                  Icon(Icons.person_add, size: 80, color: Colors.teal),
                  SizedBox(height: 10),
                  Text(
                    'Create Your Account',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email input field
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Password input field
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        errorText: _passwordError,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password should be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Name input field
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Profile Photo URL input field
                    TextFormField(
                      controller: photoUrlController,
                      decoration: InputDecoration(
                        labelText: 'Profile Photo URL (optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Sign Up button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _passwordError = null);

                    User? user = await authModel.signUp(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      name: nameController.text.trim(),
                      photoUrl: photoUrlController.text.trim().isNotEmpty
                          ? photoUrlController.text.trim()
                          : null,
                    );

                    if (user != null) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sign up failed')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),

              // Sign In navigation
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Already have an account? Sign In',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
