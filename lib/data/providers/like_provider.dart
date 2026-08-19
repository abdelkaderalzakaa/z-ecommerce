import 'dart:async';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/shared/like_model.dart';
import 'package:z_ecommerce/data/services/like_service.dart';

class LikeProvider extends ChangeNotifier {
  final LikeService _likeService = LikeService();

  List<LikeModel> _userLikes = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<LikeModel>>? _userLikesSubscription;
  final Map<String, StreamSubscription<int>> _targetLikesCountSubscriptions = {};
  final Map<String, int> _targetLikesCount = {};

  List<LikeModel> get userLikes => _userLikes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get the number of likes for a specific product or store
  int getLikesCount(String targetId) => _targetLikesCount[targetId] ?? 0;

  /// Check if the user has liked a specific target locally
  bool hasLiked(String targetId) {
    return _userLikes.any((like) => like.targetId == targetId);
  }

  /// Listen to the current user's liked items
  void listenToUserLikes(String userId) {
    _isLoading = true;
    notifyListeners();

    _userLikesSubscription?.cancel();
    _userLikesSubscription = _likeService.streamUserLikes(userId).listen(
      (likes) {
        _userLikes = likes;
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

  /// Listen to the number of likes for a specific target
  void listenToTargetLikesCount(String targetId) {
    if (_targetLikesCountSubscriptions.containsKey(targetId)) return;

    _targetLikesCountSubscriptions[targetId] = _likeService.streamTargetLikesCount(targetId).listen(
      (count) {
        _targetLikesCount[targetId] = count;
        notifyListeners();
      },
    );
  }

  Future<void> toggleLike(LikeModel like) async {
    // Optimistic Update
    final isLiking = !hasLiked(like.targetId);
    if (isLiking) {
      _userLikes.insert(0, like);
      _targetLikesCount[like.targetId] = (_targetLikesCount[like.targetId] ?? 0) + 1;
    } else {
      _userLikes.removeWhere((l) => l.targetId == like.targetId);
      final currentCount = _targetLikesCount[like.targetId] ?? 1;
      _targetLikesCount[like.targetId] = currentCount > 0 ? currentCount - 1 : 0;
    }
    notifyListeners();

    try {
      await _likeService.toggleLike(like);
    } catch (e) {
      _errorMessage = e.toString();
      // Revert optimistic update on failure
      if (isLiking) {
        _userLikes.removeWhere((l) => l.targetId == like.targetId);
        final currentCount = _targetLikesCount[like.targetId] ?? 1;
        _targetLikesCount[like.targetId] = currentCount > 0 ? currentCount - 1 : 0;
      } else {
        _userLikes.insert(0, like);
        _targetLikesCount[like.targetId] = (_targetLikesCount[like.targetId] ?? 0) + 1;
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userLikesSubscription?.cancel();
    for (var sub in _targetLikesCountSubscriptions.values) {
      sub.cancel();
    }
    super.dispose();
  }
}
