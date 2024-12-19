import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_model.dart';

class HomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch friends and their event counts
  Future<List<Friend>> fetchFriends(String userId) async {
    try {
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      final List<dynamic> friendIds = userDoc['friends'] ?? [];

      List<Friend> friends = [];
      for (String friendId in friendIds) {
        final friendDoc = await _firestore.collection('users').doc(friendId).get();
        final friendData = friendDoc.data() as Map<String, dynamic>;

        final QuerySnapshot eventsSnapshot = await _firestore
            .collection('users')
            .doc(friendId)
            .collection('events')
            .where('date', isGreaterThanOrEqualTo: DateTime.now())
            .get();

        friends.add(Friend(
          id: friendId,
          name: friendData['name'] ?? 'Unknown',
          profilePicture: friendData['profilePicture'] ?? 'assets/images/default.png',
          upcomingEvents: eventsSnapshot.docs.length,
        ));
      }
      return friends;
    } catch (e) {
      print('Error fetching friends: $e');
      throw Exception('Failed to fetch friends');
    }
  }

  // Add a friend by their email
  Future<void> addFriend(String userId, String friendEmail) async {
    try {
      final QuerySnapshot friendQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: friendEmail)
          .get();

      if (friendQuery.docs.isEmpty) {
        throw Exception('No user found with that email');
      }

      final friendDoc = friendQuery.docs.first;
      final friendId = friendDoc.id;

      // Update the current user's friends list
      await _firestore.collection('users').doc(userId).update({
        'friends': FieldValue.arrayUnion([friendId]),
      });

      print('Friend added successfully');
    } catch (e) {
      print('Error adding friend: $e');
      throw Exception('Failed to add friend');
    }
  }
}
