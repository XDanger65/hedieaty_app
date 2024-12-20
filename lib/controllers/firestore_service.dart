import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method to get the Firestore reference for user data
  DocumentReference getUserRef(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  // Method to fetch user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final DocumentSnapshot userDoc = await getUserRef(uid).get();

      if (userDoc.exists) {
        print('User data fetched: ${userDoc.data()}');
        return userDoc.data() as Map<String, dynamic>?;
      } else {
        print('No user document found for UID: $uid');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw Exception('Failed to fetch user data: $e');
    }
  }

  // Method to add an event
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

  // Method to fetch events for a user
  Future<List<Map<String, dynamic>>> getUserEvents(String userId) async {
    try {
      final QuerySnapshot eventQuery = await getUserRef(userId)
          .collection('events')
          .orderBy('createdAt', descending: true)
          .get();

      return eventQuery.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Failed to fetch events: $e');
    }
  }

  // Method to update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await getUserRef(uid).update(data);
      print('User data updated successfully');
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data: $e');
    }
  }

  // Method to add a gift to an event
  Future<void> addGift(String userId, String eventId, String giftName) async {
    try {
      await getUserRef(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .add({
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

  // Method to fetch gifts for a specific event
  Future<List<Map<String, dynamic>>> getGifts(String userId, String eventId) async {
    try {
      final QuerySnapshot giftQuery = await getUserRef(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .orderBy('createdAt')
          .get();

      return giftQuery.docs
          .map((doc) => {
        'id': doc.id,
        'name': doc['name'],
        'isPledged': doc['isPledged'],
      })
          .toList();
    } catch (e) {
      print('Error fetching gifts: $e');
      throw Exception('Failed to fetch gifts: $e');
    }
  }

  // Method to update pledged status of a gift
  Future<void> updateGiftPledgedStatus(String userId, String eventId, String giftId, bool isPledged) async {
    try {
      final giftDoc = getUserRef(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId);

      await giftDoc.update({'isPledged': isPledged});
      print('Gift pledged status updated successfully');
    } catch (e) {
      print('Error updating gift pledged status: $e');
      throw Exception('Failed to update gift pledged status: $e');
    }
  }

  // Helper method to get the current authenticated user's UID
  Future<String?> getCurrentUserUid() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return user.uid;
      } else {
        print('No user authenticated');
        return null;
      }
    } catch (e) {
      print('Error fetching current user UID: $e');
      throw Exception('Failed to fetch current user UID: $e');
    }
  }
}
