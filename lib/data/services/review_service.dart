import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/shared/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'reviews';

  /// Add a new review
  Future<String?> addReview(ReviewModel review) async {
    try {
      final docRef = _firestore.collection(collectionPath).doc();
      final newReview = review.copyWith(id: docRef.id);
      await docRef.set(newReview.toMap());
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding review: $e');
      }
      return null;
    }
  }

  /// Update an existing review (e.g., to add a store reply)
  Future<bool> updateReview(ReviewModel review) async {
    try {
      await _firestore.collection(collectionPath).doc(review.id).update(review.toMap());
      return true;
    } catch (e) {
      debugPrint('Error updating review: $e');
      return false;
    }
  }

  /// Delete a review (Customer deletes their own, or Super Admin deletes)
  Future<bool> deleteReview(String id) async {
    try {
      await _firestore.collection(collectionPath).doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting review: $e');
      return false;
    }
  }

  /// Stream reviews for a specific product
  Stream<List<ReviewModel>> streamReviewsForProduct(String productId) {
    return _firestore
        .collection(collectionPath)
        .where('targetId', isEqualTo: productId)
        .where('targetType', isEqualTo: 'product')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Stream reviews for a specific store (all products + store itself)
  Stream<List<ReviewModel>> streamReviewsForBusiness(String businessId) {
    return _firestore
        .collection(collectionPath)
        .where('businessId', isEqualTo: businessId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Add a reply from the store admin
  Future<bool> addReplyToReview(String reviewId, String replyText) async {
    try {
      await _firestore.collection(collectionPath).doc(reviewId).update({
        'reply': replyText,
        'repliedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error adding reply: $e');
      return false;
    }
  }

  /// Stream all reported reviews for Super Admin
  Stream<List<ReviewModel>> streamAllReportedReviews() {
    return _firestore
        .collection(collectionPath)
        .where('isReported', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Ignore a reported review (un-report)
  Future<bool> ignoreReport(String reviewId) async {
    try {
      await _firestore.collection(collectionPath).doc(reviewId).update({
        'isReported': false,
        'reportReason': null,
      });
      return true;
    } catch (e) {
      debugPrint('Error ignoring report: $e');
      return false;
    }
  }
}
