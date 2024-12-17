import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/controllers/firestore_service.dart';
import 'package:project/views/gift_list_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final List<Map<String, String>> _events = [];
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
  }

  void _fetchUserEvents() async {
    final events = await _firestoreService.getUserEvents(currentUserId);
    setState(() {
      _events.clear();
      // Convert Map<String, dynamic> to Map<String, String>
      _events.addAll(events.map((e) => {
        'title': e['title']?.toString() ?? '',  // Safely convert to String
        'date': e['date']?.toString() ?? '',    // Safely convert to String
      }).toList());
    });
  }





  void _showAddEventDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Event Date (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final date = dateController.text.trim();

                if (title.isEmpty || date.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title and date cannot be empty')),
                  );
                  return;
                }

                // Add event to Firestore
                await _firestoreService.addEvent(currentUserId, title, date);
                _fetchUserEvents();

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
        title: const Text('Event List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddEventDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return ListTile(
            title: Text(event['title']!),
            subtitle: Text('Date: ${event['date']}'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
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
