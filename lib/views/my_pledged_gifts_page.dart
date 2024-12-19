import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  const MyPledgedGiftsPage({super.key});

  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  late FirebaseFirestore _firestore;
  late String userId;

  List<Map<String, String>> pledgedGifts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.uid;
        await _fetchPledgedGifts();
      } else {
        print('User is not authenticated.');
      }
    } catch (e) {
      print('Error initializing user: $e');
    }
  }

  Future<void> _fetchPledgedGifts() async {
    try {
      // Query the gifts for the current user's events
      QuerySnapshot eventSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events') // Assuming gifts are under events
          .get();

      print('Number of events found: ${eventSnapshot.docs.length}'); // Debugging log

      List<Map<String, String>> gifts = [];
      for (var eventDoc in eventSnapshot.docs) {
        // Query gifts under each event
        QuerySnapshot giftSnapshot =
        await eventDoc.reference.collection('gifts').get();

        print('Number of gifts in event ${eventDoc.id}: ${giftSnapshot.docs.length}'); // Debugging log

        for (var giftDoc in giftSnapshot.docs) {
          // Safely cast and convert fields to String
          gifts.add({
            'name': (giftDoc['name'] ?? 'Unnamed gift').toString(),
            'friend': (giftDoc['friend'] ?? 'Unknown friend').toString(),
            'dueDate': (giftDoc['dueDate'] != null)
                ? (giftDoc['dueDate'] as Timestamp).toDate().toString()
                : 'No due date',
          });
        }
      }

      setState(() {
        pledgedGifts = gifts;
        isLoading = false; // Set loading state to false when data is fetched
      });
    } catch (e) {
      print('Error fetching pledged gifts: $e');
      setState(() {
        isLoading = false; // Set loading state to false if an error occurs
      });
    }
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
          ? const Center(child: Text('No pledged gifts available.'))
          : ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          return ListTile(
            title: Text(gift['name']!),
            subtitle: Text(
                'Pledged by: ${gift['friend']} - Due Date: ${gift['dueDate']}'),
          );
        },
      ),
    );
  }
}
