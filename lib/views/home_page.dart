import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/profile_page.dart';
import '../views/event_list_page.dart';
import '../views/my_pledged_gifts_page.dart';
import '../views/gift_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _mounted = true;

  final List<Widget> _pages = [
    const HomePageContent(),
    const EventListPage(),
    const MyPledgedGiftsPage(),
    const ProfilePage(),
  ];

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (!_mounted) return;
    if (index < _pages.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'My Gifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _friendsList = [];
  List<Map<String, dynamic>> _filteredFriendsList = [];
  bool _mounted = true;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  @override
  void dispose() {
    _mounted = false;
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFriends() async {
    if (!_mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final QuerySnapshot snapshot = await _firestore.collection('friends').get();

      if (!_mounted) return;

      setState(() {
        _friendsList.clear();
        _friendsList.addAll(snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            ...data,
            'id': doc.id, // Store the document ID
          };
        }));
        _filteredFriendsList = List.from(_friendsList);
        _isLoading = false;
      });
    } catch (e) {
      if (!_mounted) return;
      setState(() {
        _error = 'Failed to load friends: $e';
        _isLoading = false;
      });
    }
  }

  void _filterFriendsList(String query) {
    if (!_mounted) return;

    setState(() {
      _filteredFriendsList = _friendsList
          .where((friend) =>
      friend['name']?.toString().toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList();
    });
  }

  Future<void> _addFriend(String name, String phone, String email) async {
    if (!_mounted) return;

    try {
      // Check for existing friend
      final existingFriends = await Future.wait([
        _firestore.collection('friends').where('phone', isEqualTo: phone).get(),
        _firestore.collection('friends').where('email', isEqualTo: email).get(),
      ]);

      if (existingFriends[0].docs.isNotEmpty || existingFriends[1].docs.isNotEmpty) {
        _showSnackBar(
          existingFriends[0].docs.isNotEmpty
              ? 'A friend with this phone number already exists!'
              : 'A friend with this email address already exists!',
        );
        return;
      }

      // Add new friend
      final friendData = {
        'name': name,
        'phone': phone,
        'email': email,
        'upcomingEvents': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('friends').add(friendData);

      if (!_mounted) return;

      setState(() {
        _friendsList.add({...friendData, 'id': docRef.id});
        _filteredFriendsList = List.from(_friendsList);
      });

      _showSnackBar('Friend added successfully!');
    } catch (e) {
      _showSnackBar('Error adding friend: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!_mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAddFriendDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Friend'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              final email = emailController.text.trim();

              if (name.isEmpty || phone.isEmpty || email.isEmpty) {
                _showSnackBar('All fields must be filled');
                return;
              }

              _addFriend(name, phone, email);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Hedieaty Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchFriends,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterFriendsList,
              decoration: const InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : RefreshIndicator(
              onRefresh: _fetchFriends,
              child: _filteredFriendsList.isEmpty
                  ? const Center(child: Text('No friends found'))
                  : ListView.builder(
                itemCount: _filteredFriendsList.length,
                itemBuilder: (context, index) {
                  final friend = _filteredFriendsList[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        friend['name'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(friend['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone: ${friend['phone']}'),
                        Text('Email: ${friend['email']}'),
                        Text(
                          friend['upcomingEvents'] > 0
                              ? 'Upcoming Events: ${friend['upcomingEvents']}'
                              : 'No Upcoming Events',
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftListPage(
                          eventTitle: friend['name'],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}