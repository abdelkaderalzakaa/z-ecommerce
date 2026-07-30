class CurrencyStore {
  final String id;
  final String code;         // كود العملة العالمي (USD, LBP, SAR...)
  final String symbol;       // رمز العملة ($, ل.ل, ر.س...)
  final String name;         // اسم العملة (دولار أمريكي, ليرة لبنانية...)
  final double exchangeRate; // سعر الصرف مقارنة بالعملة الأساسية
  final bool isPrimary;      // هل هي العملة الأساسية للبزنس

  CurrencyStore({
    required this.id,
    required this.code,
    required this.symbol,
    required this.name,
    this.exchangeRate = 1.0,
    this.isPrimary = false,
  });

  factory CurrencyStore.fromMap(Map<String, dynamic> map) {
    return CurrencyStore(
      id: map['id'] ?? '',
      code: map['code'] ?? map['currency'] ?? 'USD',
      symbol: map['symbol'] ?? '\$',
      name: map['name'] ?? '',
      exchangeRate: (map['exchangeRate'] ?? map['rateConvert'] ?? 1.0).toDouble(),
      isPrimary: map['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'symbol': symbol,
      'name': name,
      'exchangeRate': exchangeRate,
      'isPrimary': isPrimary,
    };
  }
}