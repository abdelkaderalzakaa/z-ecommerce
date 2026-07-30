class ActivityCustomerInBusiness {
  final String businessId;
  final int visitsCount;       // عدد مرات دخول البزنس
  final int ordersCount;        // عدد الطلبيات في هذا البزنس
  final int timeSpentSeconds;   // كم ثانية قضاها داخل هذا البزنس
  final DateTime createdAt;     // أول مرة دخل فيها البزنس
  final DateTime lastSeen;      // آخر مرة دخل فيها البزنس

  ActivityCustomerInBusiness({
    required this.businessId,
    this.visitsCount = 0,
    this.ordersCount = 0,
    this.timeSpentSeconds = 0,
    required this.createdAt,
    required this.lastSeen,
  });

  factory ActivityCustomerInBusiness.fromMap(Map<String, dynamic> map) {
    return ActivityCustomerInBusiness(
      businessId: map['businessId'] ?? '',
      visitsCount: map['visitsCount'] ?? 0,
      ordersCount: map['ordersCount'] ?? 0,
      timeSpentSeconds: map['timeSpentSeconds'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastSeen: map['lastSeen'] != null
          ? DateTime.parse(map['lastSeen'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessId': businessId,
      'visitsCount': visitsCount,
      'ordersCount': ordersCount,
      'timeSpentSeconds': timeSpentSeconds,
      'createdAt': createdAt.toIso8601String(),
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  ActivityCustomerInBusiness copyWith({
    String? businessId,
    int? visitsCount,
    int? ordersCount,
    int? timeSpentSeconds,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return ActivityCustomerInBusiness(
      businessId: businessId ?? this.businessId,
      visitsCount: visitsCount ?? this.visitsCount,
      ordersCount: ordersCount ?? this.ordersCount,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}