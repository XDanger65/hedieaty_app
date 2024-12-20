import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper: Get user Firestore reference
  DocumentReference getUserRef(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  // Helper: Fetch event document reference
  Future<DocumentReference> _getEventRef(String userId, String eventTitle) async {
    final eventQuery = await getUserRef(userId)
        .collection('events')
        .where('title', isEqualTo: eventTitle)
        .limit(1)
        .get();

    if (eventQuery.docs.isEmpty) {
      throw Exception('Event not found');
    }
    return eventQuery.docs.first.reference;
  }

  // 1. Add Methods
  Future<void> addEvent(String userId, String title, String date) async {
    try {
      await getUserRef(userId).collection('events').add({
        'title': title,
        'date': date,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Event added successfully');
    } catch (e) {
      print('Error adding event: $e');
      throw Exception('Failed to add event: $e');
    }
  }

  Future<void> addGift(String userId, String eventTitle, String giftName) async {
    try {
      final eventRef = await _getEventRef(userId, eventTitle);
      await eventRef.collection('gifts').add({
        'name': giftName,
        'isPledged': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Gift added successfully');
    } catch (e) {
      print('Error adding gift: $e');
      throw Exception('Failed to add gift: $e');
    }
  }

  // 2. Fetch Methods
  Future<List<Map<String, dynamic>>> getUserEvents(String userId) async {
    try {
      final events = await getUserRef(userId)
          .collection('events')
          .orderBy('createdAt', descending: true)
          .get();

      return events.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Failed to fetch events: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getGifts(String userId, String eventTitle) async {
    try {
      final eventRef = await _getEventRef(userId, eventTitle);
      final gifts = await eventRef.collection('gifts').orderBy('createdAt').get();

      return gifts.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      print('Error fetching gifts: $e');
      throw Exception('Failed to fetch gifts: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final userDoc = await getUserRef(uid).get();
      return userDoc.exists ? userDoc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      print('Error fetching user data: $e');
      throw Exception('Failed to fetch user data: $e');
    }
  }

  // 3. Update Methods
  Future<void> updateGiftPledgedStatus(
      String userId, String eventTitle, String giftId, bool isPledged) async {
    try {
      final eventRef = await _getEventRef(userId, eventTitle);
      await eventRef.collection('gifts').doc(giftId).update({'isPledged': isPledged});
      print('Gift pledged status updated successfully');
    } catch (e) {
      print('Error updating gift pledged status: $e');
      throw Exception('Failed to update gift pledged status: $e');
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await getUserRef(uid).update(data);
      print('User data updated successfully');
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data: $e');
    }
  }

  // Helper: Get current user's UID
  Future<String?> getCurrentUserUid() async {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      print('Error fetching current user UID: $e');
      throw Exception('Failed to fetch current user UID: $e');
    }
  }
}
