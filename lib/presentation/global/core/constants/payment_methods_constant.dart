import '../../translate/localized_string.dart';

/// 1. الـ Enum يمثل كافة وسائل الدفع المدعومة في التطبيق
enum PaymentMethodType {
  cashOnDelivery,
  wishMoney,
  omt,
  creditCard,
  paypal,
  bankTransfer;

  /// تحويل من String قادم من قواعد البيانات (Json) إلى Enum
  static PaymentMethodType fromString(String value) {
    return PaymentMethodType.values.firstWhere(
      (e) => e.name == value || e.id == value,
      orElse: () => PaymentMethodType.cashOnDelivery,
    );
  }

  /// المعرّف المباشر لكل وسيلة (مفيد للـ JSON أو التعامل مع الـ Backend)
  String get id {
    switch (this) {
      case PaymentMethodType.cashOnDelivery:
        return 'cod';
      case PaymentMethodType.wishMoney:
        return 'wish';
      case PaymentMethodType.omt:
        return 'omt';
      case PaymentMethodType.creditCard:
        return 'credit_card';
      case PaymentMethodType.paypal:
        return 'paypal';
      case PaymentMethodType.bankTransfer:
        return 'bank_transfer';
    }
  }
}

/// 2. كلاس تفاصيل وسيلة الدفع (PaymentMethodModel)
class PaymentMethodModel {
  final String id;
  final PaymentMethodType type;
  final LocalizedString title;
  final String icon;
  final LocalizedString? description;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.title,
    required this.icon,
    this.description,
  });

  /// القائمة الجاهزة لوسائل الدفع المدعومة في التطبيق
  static final List<PaymentMethodModel> availableMethods = [
    const PaymentMethodModel(
      id: 'cod',
      type: PaymentMethodType.cashOnDelivery,
      title: LocalizedString(ar: 'الدفع عند الاستلام', en: 'Cash on Delivery'),
      icon: 'assets/images/cod.png',
      description: LocalizedString(
        ar: 'الدفع نقداً عند استلام الطلب',
        en: 'Pay in cash upon delivery',
      ),
    ),
    const PaymentMethodModel(
      id: 'wish',
      type: PaymentMethodType.wishMoney,
      title: LocalizedString(ar: 'تحويل عبر ويش', en: 'Wish Money'),
      icon: 'assets/images/wish.png',
      description: LocalizedString(
        ar: 'تحويل الأموال عبر تطبيق Wish Money',
        en: 'Transfer funds via Wish Money app',
      ),
    ),
    const PaymentMethodModel(
      id: 'omt',
      type: PaymentMethodType.omt,
      title: LocalizedString(ar: 'تحويل عبر OMT', en: 'OMT Transfer'),
      icon: 'assets/images/omt.png',
      description: LocalizedString(
        ar: 'تحويل الأموال عبر شركة OMT',
        en: 'Money transfer via OMT',
      ),
    ),
    const PaymentMethodModel(
      id: 'credit_card',
      type: PaymentMethodType.creditCard,
      title: LocalizedString(ar: 'بطاقة ائتمان', en: 'Credit Card'),
      icon: 'assets/images/credit_card.png',
      description: LocalizedString(
        ar: 'الدفع الإلكتروني الآمن عبر البطاقات',
        en: 'Secure payment via Credit/Debit card',
      ),
    ),
    const PaymentMethodModel(
      id: 'paypal',
      type: PaymentMethodType.paypal,
      title: LocalizedString(ar: 'باي بال', en: 'PayPal'),
      icon: 'assets/images/paypal.png',
      description: LocalizedString(
        ar: 'الدفع عبر حساب باي بال',
        en: 'Pay securely using PayPal account',
      ),
    ),
    const PaymentMethodModel(
      id: 'bank_transfer',
      type: PaymentMethodType.bankTransfer,
      title: LocalizedString(ar: 'تحويل بنكي', en: 'Bank Transfer'),
      icon: 'assets/images/bank_transfer.png',
      description: LocalizedString(
        ar: 'الدفع عن طريق تحويل بنكي مباشر',
        en: 'Direct bank transfer payment',
      ),
    ),
  ];
}