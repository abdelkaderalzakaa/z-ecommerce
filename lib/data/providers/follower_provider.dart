import 'dart:async';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/shared/follower_model.dart';
import 'package:z_ecommerce/data/services/follower_service.dart';

class FollowerProvider extends ChangeNotifier {
  final FollowerService _followerService = FollowerService();

  List<FollowerModel> _storeFollowers = [];
  List<FollowerModel> _userFollowing = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<FollowerModel>>? _storeFollowersSubscription;
  StreamSubscription<List<FollowerModel>>? _userFollowingSubscription;

  List<FollowerModel> get storeFollowers => _storeFollowers;
  List<FollowerModel> get userFollowing => _userFollowing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Check if current user is following a specific store
  bool isFollowing(String businessId) {
    return _userFollowing.any((f) => f.businessId == businessId);
  }

  /// Listen to followers of a specific store (for Business Admin Dashboard)
  void listenToStoreFollowers(String businessId) {
    _isLoading = true;
    notifyListeners();

    _storeFollowersSubscription?.cancel();
    _storeFollowersSubscription = _followerService.streamStoreFollowers(businessId).listen(
      (followers) {
        _storeFollowers = followers;
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

  /// Listen to stores followed by the current user
  void listenToUserFollowing(String userId) {
    _isLoading = true;
    notifyListeners();

    _userFollowingSubscription?.cancel();
    _userFollowingSubscription = _followerService.streamUserFollowing(userId).listen(
      (following) {
        _userFollowing = following;
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

  Future<void> toggleFollow(FollowerModel follower) async {
    final following = !isFollowing(follower.businessId);
    
    // Optimistic Update
    if (following) {
      _userFollowing.insert(0, follower);
    } else {
      _userFollowing.removeWhere((f) => f.businessId == follower.businessId);
    }
    notifyListeners();

    try {
      await _followerService.toggleFollow(follower);
    } catch (e) {
      _errorMessage = e.toString();
      // Revert on error
      if (following) {
        _userFollowing.removeWhere((f) => f.businessId == follower.businessId);
      } else {
        _userFollowing.insert(0, follower);
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _storeFollowersSubscription?.cancel();
    _userFollowingSubscription?.cancel();
    super.dispose();
  }
}
