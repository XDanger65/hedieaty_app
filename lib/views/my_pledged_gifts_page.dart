import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  const MyPledgedGiftsPage({super.key});

  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<Map<String, dynamic>> pledgedGifts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPledgedGifts();
  }

  Future<void> _fetchPledgedGifts() async {
    try {
      if (currentUserId.isEmpty) {
        print('User ID is null. Unable to fetch pledged gifts.');
        return;
      }

      final eventSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('events')
          .get();

      List<Map<String, dynamic>> gifts = [];
      for (var eventDoc in eventSnapshot.docs) {
        final giftSnapshot =
        await eventDoc.reference.collection('gifts').where('isPledged', isEqualTo: true).get();

        for (var giftDoc in giftSnapshot.docs) {
          final data = giftDoc.data();
          gifts.add({
            'name': data['name']?.toString() ?? 'Unnamed gift',
            'friend': data['friend']?.toString() ?? 'Unknown friend',
            'dueDate': (data['dueDate'] != null)
                ? (data['dueDate'] as Timestamp).toDate().toString()
                : 'No due date',
          });
        }
      }

      setState(() {
        pledgedGifts = gifts;
      });
    } catch (e) {
      print('Error fetching pledged gifts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load pledged gifts. Please try again.')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_giftcard, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            'No pledged gifts yet.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 5),
          Text(
            'Start pledging gifts to see them here.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftList() {
    return ListView.builder(
      itemCount: pledgedGifts.length,
      itemBuilder: (context, index) {
        final gift = pledgedGifts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(
              gift['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Pledged by: ${gift['friend']} - Due Date: ${gift['dueDate']}',
            ),
            leading: const Icon(
              Icons.card_giftcard,
              color: Colors.teal,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('My Pledged Gifts'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pledgedGifts.isEmpty
          ? _buildEmptyState()
          : _buildGiftList(),
    );
  }
}
