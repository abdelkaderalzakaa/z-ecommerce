class FollowerModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String businessId;
  final DateTime followedAt;

  FollowerModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.businessId,
    required this.followedAt,
  });

  factory FollowerModel.fromMap(Map<String, dynamic> map, String docId) {
    return FollowerModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'],
      businessId: map['businessId'] ?? '',
      followedAt: map['followedAt'] != null ? DateTime.parse(map['followedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'businessId': businessId,
      'followedAt': followedAt.toIso8601String(),
    };
  }

  FollowerModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? businessId,
    DateTime? followedAt,
  }) {
    return FollowerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      businessId: businessId ?? this.businessId,
      followedAt: followedAt ?? this.followedAt,
    );
  }
}
