import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../views/login_page.dart';
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Logout functionality
              await FirebaseAuth.instance.signOut();
              // Pop all screens until we reach the login page
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture and Name
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/1.jpeg'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'User Name',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'email@example.com',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Update Personal Info and Notification Settings
              const Text(
                'Manage Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Update Personal Information'),
                onTap: () {
                  // Navigate to personal information update page
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notification Settings'),
                onTap: () {
                  // Navigate to notification settings page
                },
              ),
              const Divider(),

              // User's Created Events and Gifts
              const Text(
                'Your Events and Gifts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5, // Replace with actual event count
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.event),
                    title: Text('Event $index'),
                    subtitle: Text('Associated Gift: Gift $index'),
                    onTap: () {
                      // Navigate to event details or edit page
                    },
                  );
                },
              ),
              const Divider(),

              // Link to My Pledged Gifts Page
              ListTile(
                leading: const Icon(Icons.card_giftcard),
                title: const Text('My Pledged Gifts'),
                onTap: () {
                  // Navigate to My Pledged Gifts Page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
