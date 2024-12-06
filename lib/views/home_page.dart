import 'package:flutter/material.dart';
import 'package:project/views/profile_page.dart';

class HomePage extends StatelessWidget {
  final List<Friend> friendsList = [
    Friend(name: 'Ali', profilePictureUrl: 'https://example.com/ali.jpg', upcomingEvents: 1),
    Friend(name: 'Sara', profilePictureUrl: 'https://example.com/sara.jpg', upcomingEvents: 0),
    Friend(name: 'John', profilePictureUrl: 'https://example.com/john.jpg', upcomingEvents: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hedieaty'),
        leading: IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Open search functionality
            },
          ),
        ],
      ),
      body: friendsList.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No friends yet! Add friends to start sharing gifts.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: friendsList.length,
        itemBuilder: (context, index) {
          final friend = friendsList[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(friend.profilePictureUrl),
            ),
            title: Text(friend.name),
            subtitle: Text(
              friend.upcomingEvents > 0
                  ? 'Upcoming Events: ${friend.upcomingEvents}'
                  : 'No Upcoming Events',
            ),
            trailing: friend.upcomingEvents > 0
                ? Chip(
              label: Text('${friend.upcomingEvents}'),
              backgroundColor: Colors.green,
              labelStyle: TextStyle(color: Colors.white),
            )
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftListScreen(friend: friend),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the Create Event/List screen
        },
        child: Icon(Icons.add),
        tooltip: 'Create Your Own Event/List',
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: Icon(Icons.person_add),
          label: Text('Add Friends'),
          onPressed: () {
            // Show options for adding friends
          },
        ),
      ),
    );
  }
}

class Friend {
  final String name;
  final String profilePictureUrl;
  final int upcomingEvents;

  Friend({
    required this.name,
    required this.profilePictureUrl,
    required this.upcomingEvents,
  });
}

class GiftListScreen extends StatelessWidget {
  final Friend friend;

  GiftListScreen({required this.friend});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${friend.name}\'s Gift List'),
      ),
      body: Center(
        child: Text('Gift list for ${friend.name} will be displayed here.'),
      ),
    );
  }
}
