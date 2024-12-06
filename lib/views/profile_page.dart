import 'package:flutter/material.dart';
import 'package:project/views/login_page.dart';
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
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(currentUser.photoURL ?? 'https://example.com/default-avatar.jpg'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    currentUser.displayName ?? 'User Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    currentUser.email ?? 'No Email',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Update Personal Information'),
              onTap: () {
                // Navigate to update personal information screen
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notification Settings'),
              onTap: () {
                // Navigate to notification settings screen
              },
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'Your Events',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Created Events'),
              onTap: () {
                // Navigate to user’s created events screen
              },
            ),
            ListTile(
              leading: Icon(Icons.card_giftcard),
              title: Text('My Pledged Gifts'),
              onTap: () {
                // Navigate to My Pledged Gifts Page
              },
            ),
            Divider(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  authModel.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage(),
                  settings: RouteSettings(
                  arguments: {'removeLeading': true},
                  ),
                  ),
                  );
                },
                child: Text('Sign Out'),
              ),
            ),
          ],
        ),
      )
          : Center(
        child: Text('No user is logged in'),
      ),
    );
  }
}




