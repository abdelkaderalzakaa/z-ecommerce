class FollowersStore {
  final String id;
  final String userId;        // المعرف الفريد للمستخدم المتابع
  final String? userName;     // اسم المتابع
  final String? userAvatar;   // صورة المتابع الشخصية
  final DateTime followedAt;  // تاريخ بدء المتابعة

  FollowersStore({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.followedAt,
  });

  factory FollowersStore.fromMap(Map<String, dynamic> map) {
    return FollowersStore(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'],
      userAvatar: map['userAvatar'],
      followedAt: map['followedAt'] != null
          ? DateTime.parse(map['followedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'followedAt': followedAt.toIso8601String(),
    };
  }
}