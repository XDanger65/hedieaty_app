import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to fetch user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        print('User data fetched: ${userDoc.data()}');
        return userDoc.data() as Map<String, dynamic>;
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
      // Add event to user's events collection
      await _firestore.collection('users').doc(userId).collection('events').add({
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
      final QuerySnapshot eventQuery =
      await _firestore.collection('users').doc(userId).collection('events').orderBy('createdAt', descending: true).get();

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
      await _firestore.collection('users').doc(uid).update(data);
      print('User data updated successfully');
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data: $e');
    }
  }
}
