import 'package:flutter/material.dart';
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
  TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _friendsList = [
    {'name': 'Alice', 'phone': '1234567890'},
    {'name': 'Bob', 'phone': '9876543210'},
    {'name': 'Charlie', 'phone': '5678901234'},
    // Add more friends as needed
  ];
  List<Map<String, String>> _filteredFriendsList = [];

  @override
  void initState() {
    super.initState();
    _filteredFriendsList = _friendsList;
  }

  void _filterFriendsList() {
    setState(() {
      _filteredFriendsList = _friendsList
          .where((friend) =>
          friend['name']!.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _navigateToFriendGiftList(String friendName) {
    // Navigate to the gift list page for the selected friend
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyPledgedGiftsPage(), // You can pass friendName if needed
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text('Hedieaty Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to Create Event/List Page
            },
          ),
        ],
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
                  title: Text(friend['name']!),
                  subtitle: Text('Upcoming Events for ${friend['name']}'),
                  onTap: () => _navigateToFriendGiftList(friend['name']!),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement the logic to add friends manually or from the contact list
          // You might need a package like 'contacts_service' for accessing the contact list
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Friend',
      ),
    );
  }
}