import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/profile_page.dart';
import '../views/event_list_page.dart';
import '../views/my_pledged_gifts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(), // Home Page
    const EventListPage(), // Event List Page
    const MyPledgedGiftsPage(), // My Pledged Gifts Page
    const ProfilePage(), // Profile Page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index < _pages.length) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event, color: Colors.black),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard, color: Colors.black),
            label: 'My Gifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _friendsList = [];
  List<Map<String, dynamic>> _filteredFriendsList = [];

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    final QuerySnapshot snapshot = await _firestore.collection('friends').get();

    setState(() {
      _friendsList.clear();
      _friendsList.addAll(snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>));
      _filteredFriendsList = _friendsList;
    });
  }

  void _filterFriendsList() {
    setState(() {
      _filteredFriendsList = _friendsList
          .where((friend) =>
          friend['name']!.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _addFriend(String name, String phone, String email) async {
    try {
      // Query Firestore to check for existing phone or email
      final QuerySnapshot existingFriends = await _firestore
          .collection('friends')
          .where('phone', isEqualTo: phone)
          .get();

      final QuerySnapshot existingEmails = await _firestore
          .collection('friends')
          .where('email', isEqualTo: email)
          .get();

      if (existingFriends.docs.isNotEmpty || existingEmails.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(existingFriends.docs.isNotEmpty
                ? 'A friend with this phone number already exists!'
                : 'A friend with this email address already exists!'),
          ),
        );
        return;
      }

      // If no conflicts, proceed to add the friend
      final friendData = {
        'name': name,
        'phone': phone,
        'email': email,
        'upcomingEvents': 0,
      };

      await _firestore.collection('friends').add(friendData);

      setState(() {
        _friendsList.add(friendData);
        _filteredFriendsList = _friendsList;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding friend: $e')),
      );
    }
  }

  void _showAddFriendDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Friend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                final email = emailController.text.trim();

                if (name.isEmpty || phone.isEmpty || email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields must be filled')),
                  );
                  return;
                }

                _addFriend(name, phone, email);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Hedieaty Home'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _filterFriendsList(),
              decoration: const InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFriendsList.length,
              itemBuilder: (context, index) {
                final friend = _filteredFriendsList[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/sample.png'),
                  ),
                  title: Text(friend['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone: ${friend['phone']}'),
                      Text('Email: ${friend['email']}'),
                      Text(friend['upcomingEvents'] > 0
                          ? 'Upcoming Events: ${friend['upcomingEvents']}'
                          : 'No Upcoming Events'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        child: const Icon(Icons.person_add),
        tooltip: 'Add Friend',
      ),
    );
  }
}