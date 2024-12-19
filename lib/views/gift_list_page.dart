import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/controllers/firestore_service.dart';

class GiftListPage extends StatefulWidget {
  final String eventTitle;

  const GiftListPage({super.key, required this.eventTitle});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final List<Map<String, dynamic>> gifts = [];

  @override
  void initState() {
    super.initState();
    _fetchGifts();
  }

  Future<void> _fetchGifts() async {
    final fetchedGifts = await _firestoreService.getGifts(currentUserId, widget.eventTitle);
    setState(() {
      gifts.clear();
      gifts.addAll(fetchedGifts);
    });
  }

  Future<void> _addGift(String giftName) async {
    await _firestoreService.addGift(currentUserId, widget.eventTitle, giftName);
    _fetchGifts();
  }

  void _showAddGiftDialog(BuildContext context) {
    final TextEditingController giftController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Gift'),
          content: TextField(
            controller: giftController,
            decoration: const InputDecoration(
              hintText: 'Enter gift name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final giftName = giftController.text.trim();

                if (giftName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gift name cannot be empty')),
                  );
                } else {
                  await _addGift(giftName); // Add gift to Firestore and fetch updated list
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$giftName added successfully!')),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _togglePledgedStatus(String giftId, bool currentStatus) async {
    await _firestoreService.updateGiftPledgedStatus(
        currentUserId, widget.eventTitle, giftId, !currentStatus);
    _fetchGifts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Gifts for ${widget.eventTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddGiftDialog(context);
            },
          ),
        ],
      ),
      body: gifts.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No gifts added yet.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 5),
            Text('Tap the + icon to add a gift.', style: TextStyle(fontSize: 14)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(
                gift['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(
                gift['isPledged'] ? Icons.check_circle : Icons.check_circle_outline,
                color: gift['isPledged'] ? Colors.green : Colors.grey,
              ),
              onTap: () => _togglePledgedStatus(gift['id'], gift['isPledged']),
            ),
          );
        },
      ),
    );
  }
}
