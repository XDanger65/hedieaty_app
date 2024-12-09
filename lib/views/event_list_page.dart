import 'package:flutter/material.dart';
import 'package:project/views/gift_list_page.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for events
    final List<Map<String, String>> events = [
      {'title': 'Birthday Party', 'date': '2024-12-15'},
      {'title': 'Wedding Reception', 'date': '2024-12-25'},
      {'title': 'Graduation Celebration', 'date': '2025-01-10'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text('Event List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add functionality for adding new events here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature to add new events coming soon!')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text(event['title']!),
            subtitle: Text('Date: ${event['date']}'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to the Gift List Page for this event
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftListPage(eventTitle: event['title']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
