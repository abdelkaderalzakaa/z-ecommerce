import 'dart:math';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class OrderLiveRouteAnalysis {
  final double? storeToCustomerDistanceKm;
  final double? driverToCustomerDistanceKm;
  final double? driverToStoreDistanceKm;
  final int estimatedMinutes;
  final double progressPercentage; // 0.0 to 1.0
  final String statusSummaryAr;
  final String statusSummaryEn;
  final String stageDescriptionAr;
  final String stageDescriptionEn;
  final int currentStageIndex; // 0: Pending, 1: Confirmed, 2: Preparing, 3: Shipped, 4: Delivered
  final Color stageColor;
  final IconData stageIcon;

  const OrderLiveRouteAnalysis({
    this.storeToCustomerDistanceKm,
    this.driverToCustomerDistanceKm,
    this.driverToStoreDistanceKm,
    required this.estimatedMinutes,
    required this.progressPercentage,
    required this.statusSummaryAr,
    required this.statusSummaryEn,
    required this.stageDescriptionAr,
    required this.stageDescriptionEn,
    required this.currentStageIndex,
    required this.stageColor,
    required this.stageIcon,
  });
}

class OrderGeoTrackingService {
  static final OrderGeoTrackingService _instance = OrderGeoTrackingService._internal();
  factory OrderGeoTrackingService() => _instance;
  OrderGeoTrackingService._internal();

  /// 🔹 تحويل الدرجات إلى راديان
  static double _degToRad(double deg) => deg * (pi / 180.0);

  /// 🔹 حساب المسافة الكروية بدقة عالية بالكيلومترات (Haversine Formula)
  static double calculateDistanceInKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadiusKm * c;

    return (distance * 100).roundToDouble() / 100.0; // تقريب لأقرب منزلتين
  }

  /// 🔹 تنسيق المسافة نصياً (كم أو متر)
  static String formatDistance(double? distanceKm, {bool isAr = true}) {
    if (distanceKm == null || distanceKm <= 0) {
      return isAr ? 'غير محدد' : 'Unknown';
    }

    if (distanceKm < 1.0) {
      final meters = (distanceKm * 1000).round();
      return isAr ? '$meters متر' : '$meters m';
    }

    return isAr ? '${distanceKm.toStringAsFixed(1)} كم' : '${distanceKm.toStringAsFixed(1)} km';
  }

  /// 🔹 تنسيق الوقت المتوقع للوصول نصياً (ETA)
  static String formatEta(int minutes, {bool isAr = true}) {
    if (minutes <= 0) {
      return isAr ? 'تم الوصول الآن' : 'Arrived now';
    }
    if (minutes < 60) {
      return isAr ? '~ $minutes دقيقة' : '~ $minutes mins';
    }
    final hours = minutes ~/ 60;
    final remainingMins = minutes % 60;
    if (remainingMins == 0) {
      return isAr ? '~ $hours ساعة' : '~ $hours hrs';
    }
    return isAr ? '~ $hours س و $remainingMins د' : '~ ${hours}h ${remainingMins}m';
  }

  /// 🔹 التحليل الشامل لمسار وحالة الطلبية بين الزبون والمتجر والسائق
  OrderLiveRouteAnalysis analyzeOrderRoute({
    required OrderModel order,
    AddressModel? storeAddress,
    double? liveDriverLat,
    double? liveDriverLng,
  }) {
    // 1. استخراج إحداثيات الزبون
    final double? custLat = order.shippingAddressSnapshot?.latitude;
    final double? custLng = order.shippingAddressSnapshot?.longitude;

    // 2. استخراج إحداثيات المتجر (من العنوان المخزن في الطلب أو الممرر)
    final double? storeLat = order.storeAddressSnapshot?.latitude ?? storeAddress?.latitude;
    final double? storeLng = order.storeAddressSnapshot?.longitude ?? storeAddress?.longitude;

    // 3. استخراج إحداثيات السائق اللحظية
    final double? driverLat = liveDriverLat ?? order.driverLatitude;
    final double? driverLng = liveDriverLng ?? order.driverLongitude;

    // 4. حساب المسافات
    double? storeToCustomerKm;
    if (custLat != null && custLng != null && storeLat != null && storeLng != null) {
      storeToCustomerKm = calculateDistanceInKm(
        lat1: storeLat,
        lon1: storeLng,
        lat2: custLat,
        lon2: custLng,
      );
    }

    double? driverToCustomerKm;
    if (driverLat != null && driverLng != null && custLat != null && custLng != null) {
      driverToCustomerKm = calculateDistanceInKm(
        lat1: driverLat,
        lon1: driverLng,
        lat2: custLat,
        lon2: custLng,
      );
    }

    double? driverToStoreKm;
    if (driverLat != null && driverLng != null && storeLat != null && storeLng != null) {
      driverToStoreKm = calculateDistanceInKm(
        lat1: driverLat,
        lon1: driverLng,
        lat2: storeLat,
        lon2: storeLng,
      );
    }

    // 5. حساب الوقت التقديري ونسبة التقدم وحالة المرحلة
    int estimatedMinutes = 0;
    double progress = 0.0;
    int stageIndex = 0;
    String statusAr = 'قيد الانتظار';
    String statusEn = 'Pending';
    String descAr = 'الطلب بانتظار التأكيد والمراجعة من المتجر.';
    String descEn = 'Order is awaiting store confirmation.';
    Color color = Colors.orange;
    IconData icon = Icons.hourglass_top_rounded;

    final double effectiveDistKm = driverToCustomerKm ?? storeToCustomerKm ?? 5.0;

    switch (order.status) {
      case OrderStatus.pending:
        stageIndex = 0;
        progress = 0.15;
        // مسافة المتجر + 15 دقيقة تجهيز
        estimatedMinutes = ((effectiveDistKm / 30.0) * 60.0).round() + 15;
        statusAr = 'قيد الانتظار والتأكيد';
        statusEn = 'Pending Confirmation';
        descAr = 'تم إرسال طلبك وبانتظار موافقة وتأكيد المتجر.';
        descEn = 'Order placed, awaiting confirmation from the store.';
        color = Colors.orange;
        icon = Icons.access_time_rounded;
        break;

      case OrderStatus.confirmed:
        stageIndex = 1;
        progress = 0.35;
        estimatedMinutes = ((effectiveDistKm / 30.0) * 60.0).round() + 12;
        statusAr = 'تم تأكيد الطلب';
        statusEn = 'Order Confirmed';
        descAr = 'قام المتجر بتأكيد طلبك وجاري إحالته للمطبخ والتجهيز.';
        descEn = 'The store confirmed your order and will start preparation.';
        color = Colors.blue;
        icon = Icons.check_circle_outline_rounded;
        break;

      case OrderStatus.preparing:
        stageIndex = 2;
        progress = 0.60;
        estimatedMinutes = ((effectiveDistKm / 30.0) * 60.0).round() + 8;
        statusAr = 'جاري التجهيز والتغليف';
        statusEn = 'Preparing Order';
        descAr = 'الطلب قيد التحضير والتغليف بعناية في الفرع.';
        descEn = 'Your order is being carefully prepared and packed.';
        color = Colors.indigo;
        icon = Icons.soup_kitchen_rounded;
        break;

      case OrderStatus.ready:
        stageIndex = 2;
        progress = 0.70;
        estimatedMinutes = ((effectiveDistKm / 30.0) * 60.0).round() + 5;
        statusAr = 'جاهز للتسليم للسائق';
        statusEn = 'Ready for Pickup';
        descAr = 'الطلب جاهز تماماً وبانتظار استلام السائق للشحنة.';
        descEn = 'Order is packed and ready for delivery driver pickup.';
        color = Colors.teal;
        icon = Icons.inventory_2_rounded;
        break;

      case OrderStatus.shipped:
        stageIndex = 3;
        progress = 0.85;
        // السائق استلم وهو في الطريق للزبون
        estimatedMinutes = ((effectiveDistKm / 30.0) * 60.0).round() + 3;
        statusAr = 'السائق في الطريق إليك';
        statusEn = 'Out for Delivery';
        descAr = 'استلم مندوب التوصيل طلبك وهو متجه الآن إلى موقعك.';
        descEn = 'Delivery driver picked up your order and is en route to your location.';
        color = const Color(0xFFF59E0B);
        icon = Icons.delivery_dining_rounded;
        break;

      case OrderStatus.delivered:
        stageIndex = 4;
        progress = 1.0;
        estimatedMinutes = 0;
        statusAr = 'تم تسليم الطلب بنجاح';
        statusEn = 'Delivered Successfully';
        descAr = 'تم تسليم الطلبية بنجاح. نتمنى لك تجربة ممتعة!';
        descEn = 'Order delivered successfully. Enjoy your purchase!';
        color = const Color(0xFF10B981);
        icon = Icons.task_alt_rounded;
        break;

      case OrderStatus.cancelled:
        stageIndex = 0;
        progress = 0.0;
        estimatedMinutes = 0;
        statusAr = 'تم إلغاء الطلب';
        statusEn = 'Order Cancelled';
        descAr = 'تم إلغاء هذه الطلبية.';
        descEn = 'This order has been cancelled.';
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
    }

    return OrderLiveRouteAnalysis(
      storeToCustomerDistanceKm: storeToCustomerKm,
      driverToCustomerDistanceKm: driverToCustomerKm,
      driverToStoreDistanceKm: driverToStoreKm,
      estimatedMinutes: max(0, estimatedMinutes),
      progressPercentage: progress,
      statusSummaryAr: statusAr,
      statusSummaryEn: statusEn,
      stageDescriptionAr: descAr,
      stageDescriptionEn: descEn,
      currentStageIndex: stageIndex,
      stageColor: color,
      stageIcon: icon,
    );
  }
}
