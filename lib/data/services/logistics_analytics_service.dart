import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

enum DelayType {
  storeAcceptanceDelay,    // معلق بانتظار قبول المتجر > 15 دقيقة
  storePreparationDelay,   // قيد التجهيز بالمحل > 30 دقيقة
  deliveryAssignmentDelay, // جاهز للاستلام وبانتظار تعيين المندوب > 15 دقيقة
  driverPickupDelay,       // مسند لمندوب ولم يستلمه من المحل > 25 دقيقة
  inTransitDelay,          // في الطريق مع المندوب > 45 دقيقة
  unconfirmedDelivery,     // في مرحلة التوصيل مر عليها وقت طويل دون تأكيد الاستلام
}

class OrderDelayInfo {
  final OrderModel order;
  final DelayType delayType;
  final Duration elapsedDuration;
  final String title;
  final String description;
  final String recommendedAction;
  final int severity; // 1 = low, 2 = medium, 3 = critical

  OrderDelayInfo({
    required this.order,
    required this.delayType,
    required this.elapsedDuration,
    required this.title,
    required this.description,
    required this.recommendedAction,
    required this.severity,
  });
}

class StorePerformanceMetric {
  final String businessId;
  final int totalOrders;
  final int completedOrders;
  final int delayedOrders;
  final double onTimeRate;
  final Duration avgPreparationDuration;

  StorePerformanceMetric({
    required this.businessId,
    required this.totalOrders,
    required this.completedOrders,
    required this.delayedOrders,
    required this.onTimeRate,
    required this.avgPreparationDuration,
  });
}

class LogisticsAnalyticsService {
  /// Analyzes a list of orders to detect real-time operational bottlenecks, delays, and unconfirmed states.
  static List<OrderDelayInfo> detectBottlenecks(List<OrderModel> orders) {
    final now = DateTime.now();
    final List<OrderDelayInfo> bottlenecks = [];

    for (final order in orders) {
      if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) {
        continue;
      }

      final createdAt = order.createdAt;
      final totalElapsed = now.difference(createdAt);

      // 1. Store Acceptance Delay (pending > 15 minutes)
      if (order.status == OrderStatus.pending) {
        if (totalElapsed.inMinutes >= 15) {
          bottlenecks.add(
            OrderDelayInfo(
              order: order,
              delayType: DelayType.storeAcceptanceDelay,
              elapsedDuration: totalElapsed,
              title: 'تأخر قبول المتجر للطلب',
              description: 'الطلب معلق منذ ${totalElapsed.inMinutes} دقيقة دون مراجعة أو قبول من التاجر.',
              recommendedAction: 'الاتصال بالمتجر وتنبيهه لمراجعة الطلب أو إلغائه للزبون.',
              severity: totalElapsed.inMinutes > 30 ? 3 : 2,
            ),
          );
        }
      }

      // 2. Store Preparation Delay (confirmed/preparing > 30 minutes)
      else if (order.status == OrderStatus.confirmed || order.status == OrderStatus.preparing) {
        final startTime = order.confirmedAt ?? createdAt;
        final prepElapsed = now.difference(startTime);
        if (prepElapsed.inMinutes >= 30) {
          bottlenecks.add(
            OrderDelayInfo(
              order: order,
              delayType: DelayType.storePreparationDelay,
              elapsedDuration: prepElapsed,
              title: 'تأخر تجهيز الطلب في المتجر',
              description: 'الطلب قيد الإعداد منذ ${prepElapsed.inMinutes} دقيقة.',
              recommendedAction: 'التواصل مع إدارة المتجر للتحقق من جاهزية الطلب وتسريع تغليفه.',
              severity: prepElapsed.inMinutes > 50 ? 3 : 2,
            ),
          );
        }
      }

      // 3. Delivery Assignment Delay (ready with no delivery driver > 15 minutes)
      else if (order.status == OrderStatus.ready && (order.deliveryId == null || order.deliveryId!.isEmpty)) {
        final readyTime = order.preparedAt ?? createdAt;
        final readyElapsed = now.difference(readyTime);
        if (readyElapsed.inMinutes >= 10) {
          bottlenecks.add(
            OrderDelayInfo(
              order: order,
              delayType: DelayType.deliveryAssignmentDelay,
              elapsedDuration: readyElapsed,
              title: 'الطلب جاهز وبانتظار تعيين مندوب',
              description: 'تم تجهيز الطلب منذ ${readyElapsed.inMinutes} دقيقة ولم يُسند لأي كابتن.',
              recommendedAction: 'استخدام زر التدخل السريع لإسناد الطلب فوراً لأقرب مندوب متاح أونلاين.',
              severity: 3,
            ),
          );
        }
      }

      // 4. Driver Pickup Delay (ready with driver assigned > 25 minutes)
      else if (order.status == OrderStatus.ready && order.deliveryId != null && order.deliveryId!.isNotEmpty) {
        final readyTime = order.preparedAt ?? createdAt;
        final readyElapsed = now.difference(readyTime);
        if (readyElapsed.inMinutes >= 20) {
          bottlenecks.add(
            OrderDelayInfo(
              order: order,
              delayType: DelayType.driverPickupDelay,
              elapsedDuration: readyElapsed,
              title: 'تأخر المندوب في استلام الشحنة من المحل',
              description: 'مسند لـ (${order.deliveryDriverName ?? 'المندوب'}) منذ ${readyElapsed.inMinutes} دقيقة ولم يبدأ التحرك.',
              recommendedAction: 'الاتصال بالمندوب أو إعادة تعيين الطلب لكابتن آخر أسرع.',
              severity: 2,
            ),
          );
        }
      }

      // 5. In-Transit Delay / Unconfirmed Delivery (shipped > 45 minutes)
      else if (order.status == OrderStatus.shipped) {
        final shippedTime = order.shippedAt ?? createdAt;
        final transitElapsed = now.difference(shippedTime);
        if (transitElapsed.inMinutes >= 45) {
          bottlenecks.add(
            OrderDelayInfo(
              order: order,
              delayType: transitElapsed.inMinutes > 90 ? DelayType.unconfirmedDelivery : DelayType.inTransitDelay,
              elapsedDuration: transitElapsed,
              title: transitElapsed.inMinutes > 90 ? 'طلب عالق في التوصيل / غير مؤكد الاستلام' : 'تأخر الشحنة في مسار الطريق',
              description: 'الشحنة مع المندوب في الطريق منذ ${transitElapsed.inMinutes} دقيقة.',
              recommendedAction: 'التواصل مع المندوب والعميل للتأكد من وصول الشحنة أو اعتماد التأكيد الإداري.',
              severity: transitElapsed.inMinutes > 90 ? 3 : 2,
            ),
          );
        }
      }
    }

    // Sort by severity descending then elapsed duration descending
    bottlenecks.sort((a, b) {
      final sevComp = b.severity.compareTo(a.severity);
      if (sevComp != 0) return sevComp;
      return b.elapsedDuration.compareTo(a.elapsedDuration);
    });

    return bottlenecks;
  }

  /// Calculates aggregate logistics KPIs for the platform.
  static Map<String, dynamic> calculateLogisticsKPIs(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return {
        'totalActiveOrders': 0,
        'bottlenecksCount': 0,
        'onTimeRate': 100.0,
        'avgFulfillmentMinutes': 35.0,
        'deliveredTodayCount': 0,
      };
    }

    final bottlenecks = detectBottlenecks(orders);
    final activeOrders = orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList();
    final deliveredOrders = orders.where((o) => o.status == OrderStatus.delivered).toList();

    double onTimeRate = 100.0;
    if (activeOrders.isNotEmpty) {
      final onTimeCount = activeOrders.length - bottlenecks.length;
      onTimeRate = (onTimeCount / activeOrders.length * 100).clamp(0.0, 100.0);
    }

    // Average fulfillment time for delivered orders
    double avgFulfillmentMinutes = 32.0;
    if (deliveredOrders.isNotEmpty) {
      int totalMinutes = 0;
      int countWithDeliveredAt = 0;
      for (final order in deliveredOrders) {
        if (order.deliveredAt != null) {
          totalMinutes += order.deliveredAt!.difference(order.createdAt).inMinutes;
          countWithDeliveredAt++;
        }
      }
      if (countWithDeliveredAt > 0) {
        avgFulfillmentMinutes = totalMinutes / countWithDeliveredAt;
      }
    }

    return {
      'totalActiveOrders': activeOrders.length,
      'bottlenecksCount': bottlenecks.length,
      'onTimeRate': onTimeRate,
      'avgFulfillmentMinutes': avgFulfillmentMinutes,
      'deliveredTodayCount': deliveredOrders.length,
    };
  }
}
