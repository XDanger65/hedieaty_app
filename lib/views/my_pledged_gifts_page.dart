import 'package:flutter/material.dart';

class MyPledgedGiftsPage extends StatelessWidget {
  const MyPledgedGiftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for pledged gifts; replace with actual data retrieval logic
    List<Map<String, String>> pledgedGifts = [
      {'name': 'Gift 1', 'friend': 'Alice', 'dueDate': '2024-12-15'},
      {'name': 'Gift 2', 'friend': 'Bob', 'dueDate': '2024-12-25'},
      {'name': 'Gift 3', 'friend': 'Eslam', 'dueDate': '2024-11-22'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('My Pledged Gifts'),
      ),
      body: ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          return ListTile(
            title: Text(gift['name']!),
            subtitle: Text('Pledged by: ${gift['friend']} - Due Date: ${gift['dueDate']}'),
          );
        },
      ),
    );
  }
}
