import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['title'] ?? 'Event Title',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Date: ${event['date'] ?? 'No Date'}'),
            const SizedBox(height: 20),
            Text('Event Details:', style: const TextStyle(fontSize: 18)),
            // You can add more details here if available, such as event description, gifts, etc.
            // Example:
            Text('Created at: ${event['createdAt']}'),
          ],
        ),
      ),
    );
  }
}
