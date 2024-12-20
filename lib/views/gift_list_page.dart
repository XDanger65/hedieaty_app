import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/controllers/firestore_service.dart';
import 'package:project/views/gift_details_page.dart';
import 'package:project/views/my_pledged_gifts_page.dart';
import 'package:project/firebase_api.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  final FirebaseApi _firebaseApi = FirebaseApi();

  @override
  void initState() {
    super.initState();
    _fetchGifts();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _firebaseApi.initNotification();
  }

  Future<void> _fetchGifts() async {
    try {
      final fetchedGifts = await _firestoreService.getGifts(currentUserId, widget.eventTitle);
      setState(() {
        gifts.clear();
        gifts.addAll(fetchedGifts);
      });
    } catch (e) {
      print('Error fetching gifts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load gifts. Please try again.')),
        );
      }
    }
  }

  Future<void> _addGift(String giftName) async {
    try {
      await _firestoreService.addGift(currentUserId, widget.eventTitle, giftName);
      await _fetchGifts();
    } catch (e) {
      print('Error adding gift: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add gift. Please try again.')),
        );
      }
    }
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
                  await _addGift(giftName);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$giftName added successfully!')),
                    );
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendPledgeNotification(String giftName, bool isPledging) async {
    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'gift_pledge_channel',
        'Gift Pledges',
        channelDescription: 'Notifications for gift pledges',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        0,
        'Gift ${isPledging ? 'Pledged' : 'Unpledged'}',
        '${isPledging ? 'You have pledged' : 'You have unpledged'} the gift: $giftName',
        platformChannelSpecifics,
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  void _togglePledgedStatus(String giftId, bool currentStatus, String giftName) async {
    try {
      await _firestoreService.updateGiftPledgedStatus(
        currentUserId,
        widget.eventTitle,
        giftId,
        !currentStatus,
      );

      await _sendPledgeNotification(giftName, !currentStatus);
      await _fetchGifts();
    } catch (e) {
      print('Error toggling pledge status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update gift status. Please try again.')),
        );
      }
    }
  }

  void _viewPledgedGifts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyPledgedGiftsPage(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
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
          Text(
            'Tap the + icon to add a gift.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftList() {
    return ListView.builder(
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
            leading: IconButton(
              icon: Icon(
                gift['isPledged'] ? Icons.check_circle : Icons.check_circle_outline,
                color: gift['isPledged'] ? Colors.green : Colors.grey,
              ),
              onPressed: () => _togglePledgedStatus(
                gift['id'],
                gift['isPledged'],
                gift['name'],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftDetailsPage(
                    giftName: gift['name'],
                    initialStatus: gift['isPledged'] ? 'Pledged' : 'Available',
                  ),
                ),
              );
            },
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
        title: Text('Gifts for ${widget.eventTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddGiftDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: _viewPledgedGifts,
          ),
        ],
      ),
      body: gifts.isEmpty ? _buildEmptyState() : _buildGiftList(),
    );
  }
}