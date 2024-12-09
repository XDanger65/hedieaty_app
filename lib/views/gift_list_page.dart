import 'package:flutter/material.dart';

class GiftListPage extends StatelessWidget {
  final String eventTitle;

  const GiftListPage({Key? key, required this.eventTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for gifts
    final List<String> gifts = ['Gift 1', 'Gift 2', 'Gift 3'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text('Gifts for $eventTitle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add functionality for adding new gifts here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature to add new gifts coming soon!')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(gifts[index]),
            trailing: const Icon(Icons.check_circle_outline),
            onTap: () {
              // Add functionality to mark gift as pledged or for more details
            },
          );
        },
      ),
    );
  }
}
