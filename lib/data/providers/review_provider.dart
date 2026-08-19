import 'dart:async';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/shared/review_model.dart';
import 'package:z_ecommerce/data/services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  List<ReviewModel> _productReviews = [];
  List<ReviewModel> _businessReviews = [];
  List<ReviewModel> _reportedReviews = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<ReviewModel>>? _productReviewsSubscription;
  StreamSubscription<List<ReviewModel>>? _businessReviewsSubscription;
  StreamSubscription<List<ReviewModel>>? _reportedReviewsSubscription;

  List<ReviewModel> get productReviews => _productReviews;
  List<ReviewModel> get businessReviews => _businessReviews;
  List<ReviewModel> get reportedReviews => _reportedReviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Stream reviews for a specific product
  void listenToProductReviews(String productId) {
    _isLoading = true;
    notifyListeners();

    _productReviewsSubscription?.cancel();
    _productReviewsSubscription = _reviewService.streamReviewsForProduct(productId).listen(
      (reviews) {
        _productReviews = reviews;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Stream all reviews for a store
  void listenToBusinessReviews(String businessId) {
    _isLoading = true;
    notifyListeners();

    _businessReviewsSubscription?.cancel();
    _businessReviewsSubscription = _reviewService.streamReviewsForBusiness(businessId).listen(
      (reviews) {
        _businessReviews = reviews;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Stream all reported reviews for super admin
  void listenToAllReportedReviews() {
    _isLoading = true;
    notifyListeners();

    _reportedReviewsSubscription?.cancel();
    _reportedReviewsSubscription = _reviewService.streamAllReportedReviews().listen(
      (reviews) {
        _reportedReviews = reviews;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> addReview(ReviewModel review) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final id = await _reviewService.addReview(review);
    
    _isLoading = false;
    if (id != null) {
      // NOTE: We don't manually add to the list because we are listening to the stream
      // which will automatically update the list and notify listeners.
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Failed to add review';
      notifyListeners();
      return false;
    }
  }

  Future<bool> replyToReview(String reviewId, String replyText) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _reviewService.addReplyToReview(reviewId, replyText);
    
    _isLoading = false;
    if (!success) {
      _errorMessage = 'Failed to add reply';
    }
    notifyListeners();
    return success;
  }

  Future<bool> ignoreReport(String reviewId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _reviewService.ignoreReport(reviewId);
    
    _isLoading = false;
    if (!success) {
      _errorMessage = 'Failed to ignore report';
    }
    notifyListeners();
    return success;
  }

  Future<bool> deleteReview(String reviewId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _reviewService.deleteReview(reviewId);
    
    _isLoading = false;
    if (!success) {
      _errorMessage = 'Failed to delete review';
    }
    notifyListeners();
    return success;
  }

  @override
  void dispose() {
    _productReviewsSubscription?.cancel();
    _businessReviewsSubscription?.cancel();
    _reportedReviewsSubscription?.cancel();
    super.dispose();
  }
}
