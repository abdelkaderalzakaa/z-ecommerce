import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/shared/follower_model.dart';

class FollowerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'followers';

  /// Toggle Follow (Follow or Unfollow)
  Future<bool> toggleFollow(FollowerModel follower) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .where('userId', isEqualTo: follower.userId)
          .where('businessId', isEqualTo: follower.businessId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Unfollow
        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
        return false;
      } else {
        // Follow
        final docRef = _firestore.collection(collectionPath).doc();
        final newFollower = follower.copyWith(id: docRef.id);
        await docRef.set(newFollower.toMap());
        
        // 
        
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling follow: $e');
      }
      rethrow;
    }
  }

  /// Get followers for a specific store (Business Admin Analytics)
  Stream<List<FollowerModel>> streamStoreFollowers(String businessId) {
    return _firestore
        .collection(collectionPath)
        .where('businessId', isEqualTo: businessId)
        .orderBy('followedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FollowerModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get stores followed by a specific user (My Following List)
  Stream<List<FollowerModel>> streamUserFollowing(String userId) {
    return _firestore
        .collection(collectionPath)
        .where('userId', isEqualTo: userId)
        .orderBy('followedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FollowerModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
