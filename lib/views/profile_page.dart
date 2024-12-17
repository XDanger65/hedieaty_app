import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/auth_model.dart';
import '../controllers/firestore_service.dart';
import '../widgets/loading_indicator.dart';
import '../views/login_page.dart';
import '../views/EventDetailPage.dart';

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
  List<Map<String, dynamic>> _userEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _firestoreService.getUserData(user.uid);
        if (userData != null) {
          final userEvents = await _firestoreService.getUserEvents(user.uid);
          setState(() {
            _name = userData['name'] ?? 'No Name';
            _email = user.email ?? 'No Email';
            _notificationsEnabled = userData['notificationsEnabled'] ?? false;
            _userEvents = userEvents;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
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
        backgroundColor: Colors.teal,
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
            // Profile Header
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: const AssetImage('assets/1.jpeg'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _name ?? 'Loading...',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _email ?? 'Loading...',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Notification Settings
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              leading: Icon(
                _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                color: Colors.teal,
              ),
              title: Text(
                'Notifications',
                style: GoogleFonts.poppins(fontSize: 18),
              ),
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
            const Divider(height: 30),
            // Edit Profile Button
            ElevatedButton.icon(
              onPressed: _showEditProfileDialog,
              icon: const Icon(Icons.edit, color: Colors.white),
              label: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            const SizedBox(height: 20),
            // Events List
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Events',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            _userEvents.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userEvents.length,
              itemBuilder: (context, index) {
                final event = _userEvents[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: const Icon(Icons.event, color: Colors.teal),
                    title: Text(event['title'], style: GoogleFonts.poppins(fontSize: 16)),
                    subtitle: Text(
                      'Date: ${event['date']}',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailPage(event: event),
                        ),
                      );
                    },
                  ),
                );
              },
            )
                : const Text('No events found.'),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(text: _name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Edit Profile'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
