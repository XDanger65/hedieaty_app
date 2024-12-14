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


  // Example method to fetch user events
  Future<List<Map<String, dynamic>>> getUserEvents(String uid) async {
    try {
      final QuerySnapshot eventQuery =
      await _firestore.collection('users').doc(uid).collection('events').get();

      return eventQuery.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user events: $e');
    }
  }

  // Method to update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }
}
