import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift_model.dart';

class GiftController {
  final FirebaseFirestore firestore;

  GiftController({required this.firestore});

  /// Fetches the stream of gifts for a specific user.
  Stream<List<Gift>> getGifts(String userId) {
    try {
      return firestore
          .collection('users')
          .doc(userId)
          .collection('gifts')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Gift.fromMap(doc.id, doc.data()))
            .toList();
      });
    } catch (e) {
      print('Error fetching gifts: $e');
      return const Stream.empty(); // Return an empty stream on error
    }
  }

  /// Adds a new gift for a specific user.
  Future<void> addGift(String eventId, String userId, Map<String, dynamic> giftData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .add(giftData);
      print('Gift added successfully');
    } catch (e) {
      print('Error adding gift: $e');
    }
  }


  /// Updates an existing gift for a specific user.
  Future<void> updateGift(String userId, String giftId, Gift updatedGift) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('gifts')
          .doc(giftId)
          .update(updatedGift.toMap());
      print('Gift updated successfully!');
    } catch (e) {
      print('Error updating gift: $e');
    }
  }

  /// Deletes a gift for a specific user.
  Future<void> deleteGift(String userId, String giftId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('gifts')
          .doc(giftId)
          .delete();
      print('Gift deleted successfully!');
    } catch (e) {
      print('Error deleting gift: $e');
    }
  }
}
