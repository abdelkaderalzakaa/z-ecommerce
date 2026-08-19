class LikeModel {
  final String id;
  final String userId;
  final String targetId; // productId or businessId
  final String targetType; // 'product' or 'store'
  final DateTime createdAt;

  LikeModel({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.createdAt,
  });

  factory LikeModel.fromMap(Map<String, dynamic> map, String docId) {
    return LikeModel(
      id: docId,
      userId: map['userId'] ?? '',
      targetId: map['targetId'] ?? '',
      targetType: map['targetType'] ?? 'product',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'targetId': targetId,
      'targetType': targetType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  LikeModel copyWith({
    String? id,
    String? userId,
    String? targetId,
    String? targetType,
    DateTime? createdAt,
  }) {
    return LikeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
