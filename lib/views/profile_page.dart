import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_model.dart';
import '../controllers/firestore_service.dart';
import '../widgets/loading_indicator.dart';
import '../views/login_page.dart';
import '../views/my_pledged_gifts_page.dart'; // Assuming this is the location of the pledged gifts page.

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthModel _authService = AuthModel();
  final FirestoreService _firestoreService = FirestoreService();

  String? _name;
  String? _email;
  bool _notificationsEnabled = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _userEvents = []; // To store user events and gifts

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        print('Fetching data for UID: ${user.uid}');
        final userData = await _firestoreService.getUserData(user.uid);

        if (userData != null) {
          setState(() {
            _name = userData['name'] ?? 'No Name';
            _email = user.email ?? 'No Email';
            _notificationsEnabled = userData['notificationsEnabled'] ?? false;
           // _photoUrl = userData['photoUrl'];
            _isLoading = false;
          });
          print('User data set in state: $_name, $_email');
        } else {
          print('User data is null for UID: ${user.uid}');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('No authenticated user found.');
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      print('Error in _fetchUserData: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: const AssetImage('assets/1.jpeg'), // Static asset image
            ),
            const SizedBox(height: 10),
            Text(
              _name ?? 'Loading...',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _email ?? 'Loading...',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: _showEditProfileDialog,
            ),
            ListTile(
              leading: Icon(
                _notificationsEnabled ? Icons.notifications : Icons.notifications_off,
              ),
              title: const Text('Notification Settings'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) async {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  await _firestoreService.updateUserData(
                    _authService.currentUser!.uid,
                    {'notificationsEnabled': value},
                  );
                },
              ),
            ),
            const Divider(),
            // List of user's created events and associated gifts
            const ListTile(
              leading: Icon(Icons.event),
              title: Text('Your Created Events'),
            ),
            for (var event in _userEvents)
              ListTile(
                leading: const Icon(Icons.card_giftcard),
                title: Text(event['eventName']),
                subtitle: Text('Gifts: ${event['gifts'].join(', ')}'),
              ),
            const Divider(),
            // Link to My Pledged Gifts Page
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('My Pledged Gifts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPledgedGiftsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final TextEditingController nameController =
    TextEditingController(text: _name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  await _firestoreService.updateUserData(
                    _authService.currentUser!.uid,
                    {'name': newName},
                  );
                  setState(() => _name = newName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
