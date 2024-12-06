import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  final AuthModel authModel = AuthModel();

  @override
  Widget build(BuildContext context) {
    User? currentUser = authModel.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: currentUser != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${currentUser.email}'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                authModel.signOut();
                Navigator.pop(context);
              },
              child: Text('Sign Out'),
            ),
          ],
        ),
      )
          : Center(child: Text('No user is logged in')),
    );
  }
}
