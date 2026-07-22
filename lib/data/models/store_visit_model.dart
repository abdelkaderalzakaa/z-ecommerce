class StoreVisitModel {
  final String storeId;
  int visitCount;
  DateTime firstVisitDate;
  DateTime lastVisitDate;
  int orderCount;
  double totalOrdersValue;
  List<String> favoriteProducts;

  StoreVisitModel({
    required this.storeId,
    this.visitCount = 1,
    required this.firstVisitDate,
    required this.lastVisitDate,
    this.orderCount = 0,
    this.totalOrdersValue = 0.0,
    this.favoriteProducts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'visitCount': visitCount,
      'firstVisitDate': firstVisitDate.toIso8601String(),
      'lastVisitDate': lastVisitDate.toIso8601String(),
      'orderCount': orderCount,
      'totalOrdersValue': totalOrdersValue,
      'favoriteProducts': favoriteProducts,
    };
  }

  factory StoreVisitModel.fromMap(Map<String, dynamic> map) {
    return StoreVisitModel(
      storeId: map['storeId'] ?? '',
      visitCount: map['visitCount'] ?? 1,
      firstVisitDate: DateTime.tryParse(map['firstVisitDate'] ?? '') ?? DateTime.now(),
      lastVisitDate: DateTime.tryParse(map['lastVisitDate'] ?? '') ?? DateTime.now(),
      orderCount: map['orderCount'] ?? 0,
      totalOrdersValue: (map['totalOrdersValue'] ?? 0.0).toDouble(),
      favoriteProducts: List<String>.from(map['favoriteProducts'] ?? []),
    );
  }
}
