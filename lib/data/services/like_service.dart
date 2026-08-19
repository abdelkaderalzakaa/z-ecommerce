import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/shared/like_model.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'likes';

  /// Toggle Like (Add or Remove)
  Future<bool> toggleLike(LikeModel like) async {
    try {
      // Check if already liked by this user for this target
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .where('userId', isEqualTo: like.userId)
          .where('targetId', isEqualTo: like.targetId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Already liked, so we unlike (delete)
        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
        return false; // Indicates it was unliked
      } else {
        // Not liked yet, so we add
        final docRef = _firestore.collection(collectionPath).doc();
        final newLike = like.copyWith(id: docRef.id);
        await docRef.set(newLike.toMap());
        return true; // Indicates it was liked
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling like: $e');
      }
      rethrow;
    }
  }

  /// Get likes for a specific user (My Wishlist)
  Stream<List<LikeModel>> streamUserLikes(String userId) {
    return _firestore
        .collection(collectionPath)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LikeModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get likes count for a specific target (Product/Store)
  Stream<int> streamTargetLikesCount(String targetId) {
    return _firestore
        .collection(collectionPath)
        .where('targetId', isEqualTo: targetId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
