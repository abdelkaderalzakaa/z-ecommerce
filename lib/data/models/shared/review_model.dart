import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String targetId; // productId or businessId
  final String targetType; // 'product' or 'store'
  final String businessId; // Store reference to easily query all store's reviews
  final double rating;
  final String? comment;
  final List<String> images;
  final String? reply;
  final DateTime? repliedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerifiedPurchase;
  final bool isReported;
  final String? reportReason;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.targetId,
    required this.targetType,
    required this.businessId,
    required this.rating,
    this.comment,
    this.images = const [],
    this.reply,
    this.repliedAt,
    required this.createdAt,
    this.updatedAt,
    this.isVerifiedPurchase = false,
    this.isReported = false,
    this.reportReason,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReviewModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'],
      targetId: map['targetId'] ?? '',
      targetType: map['targetType'] ?? 'product',
      businessId: map['businessId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      images: List<String>.from(map['images'] ?? []),
      reply: map['reply'],
      repliedAt: map['repliedAt'] != null ? DateTime.parse(map['repliedAt']) : null,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isVerifiedPurchase: map['isVerifiedPurchase'] ?? false,
      isReported: map['isReported'] ?? false,
      reportReason: map['reportReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'targetId': targetId,
      'targetType': targetType,
      'businessId': businessId,
      'rating': rating,
      'comment': comment,
      'images': images,
      'reply': reply,
      'repliedAt': repliedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isVerifiedPurchase': isVerifiedPurchase,
      'isReported': isReported,
      'reportReason': reportReason,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? targetId,
    String? targetType,
    String? businessId,
    double? rating,
    String? comment,
    List<String>? images,
    String? reply,
    DateTime? repliedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerifiedPurchase,
    bool? isReported,
    String? reportReason,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      businessId: businessId ?? this.businessId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      reply: reply ?? this.reply,
      repliedAt: repliedAt ?? this.repliedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      isReported: isReported ?? this.isReported,
      reportReason: reportReason ?? this.reportReason,
    );
  }
}
