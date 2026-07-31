class RatedUser {
  final String id;
  final String userId; // معرف صاحب التقييم
  final String userName; // اسم صاحب التقييم
  final String? userAvatar; // صورته الشخصية
  final double rating; // التقييم من 1 إلى 5 (مثلاً 4.5)
  final String? comment; // الملاحظة أو التعليق
  final DateTime createdAt; // تاريخ التقييم

  RatedUser({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory RatedUser.fromMap(Map<String, dynamic> map) {
    return RatedUser(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// إنشاء كائن RatedUser فارغ بقيم افتراضية
  factory RatedUser.empty() {
    return RatedUser(
      id: '',
      userId: '',
      rating: 5.0,
      createdAt: DateTime.now(),
      userName: '',
    );
  }
}
