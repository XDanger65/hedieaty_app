import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_model.dart';
import '../controllers/firestore_service.dart';
import '../controllers/image_service.dart';
import '../widgets/loading_indicator.dart';
import '../views/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthModel _authService = AuthModel();
  final FirestoreService _firestoreService = FirestoreService();
  final ImageService _imageService = ImageService();

  String? _name;
  String? _email;
  File? _localPhoto;
  bool _isLoading = true;

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

        final localImage = await _imageService.getLocalImage();
        setState(() {
          _name = userData?['name'] ?? 'No Name';
          _email = user.email ?? 'No Email';
          _localPhoto = localImage;
          _isLoading = false;
        });

        if (_localPhoto == null && userData?['photoUrl'] != null) {
          final savedPath = await _imageService.saveImageLocally(userData!['photoUrl']);
          setState(() {
            _localPhoto = File(savedPath);
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        Navigator.popUntil(context, (route) => route.isFirst);
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
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();  // Sign the user out
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),  // Navigate to LoginPage
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
              backgroundImage: _localPhoto != null
                  ? FileImage(_localPhoto!)
                  : const AssetImage('assets/1.jpeg') as ImageProvider,
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
