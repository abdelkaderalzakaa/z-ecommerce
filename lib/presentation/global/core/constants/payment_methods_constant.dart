import '../../../../../data/models/localized_string.dart';

class ModelPaymenttype {
  final String id;
  final LocalizedString title;
  final String icon;
  final String? description;

  const ModelPaymenttype({
    required this.id,
    required this.title,
    required this.icon,
    this.description,
  });

  static const List<ModelPaymenttype> availableMethods = [
    ModelPaymenttype(
      id: 'cod',
      title: LocalizedString(ar: 'الدفع عند الاستلام', en: 'Cash on Delivery'),
      icon: 'assets/images/cod.png',
      description: 'الدفع نقداً عند استلام الطلب',
    ),
    ModelPaymenttype(
      id: 'wish',
      title: LocalizedString(ar: 'تحويل عبر ويش', en: 'Wish Transfer'),
      icon: 'assets/images/wish.png',
      description: 'تحويل الأموال عبر شركة ويش',
    ),
    ModelPaymenttype(
      id: 'omt',
      title: LocalizedString(ar: 'تحويل عبر OMT', en: 'OMT Transfer'),
      icon: 'assets/images/omt.png',
      description: 'تحويل الأموال عبر شركة OMT',
    ),
    ModelPaymenttype(
      id: 'creditCard',
      title: LocalizedString(ar: 'بطاقة ائتمان', en: 'Credit Card'),
      icon: 'assets/images/credit_card.png',
      description: 'الدفع عبر البطاقة الائتمانية',
    ),
    ModelPaymenttype(
      id: 'paypal',
      title: LocalizedString(ar: 'باي بال', en: 'PayPal'),
      icon: 'assets/images/paypal.png',
      description: 'الدفع عبر حساب باي بال',
    ),
  ];
}

enum PaymentMethodType {
  /// نقدي عند الاستلام 
  cod,
  /// تحويل عبر ويش 
  wish,
  /// تحويل عبر omt 
  omt,
  /// visa card
  creditCard,
  /// paypal
  paypal,
}
