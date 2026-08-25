import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/services/order_geo_tracking_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:provider/provider.dart';

class OrderTrackerWidget extends StatelessWidget {
  final OrderModel? order;
  final OrderStatus currentStatus;
  final bool isMobile;
  final AddressModel? storeAddress;

  const OrderTrackerWidget({
    super.key,
    this.order,
    required this.currentStatus,
    this.isMobile = false,
    this.storeAddress,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LocaleProvider>().locale.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveOrder = order ??
        OrderModel.empty().copyWith(
          status: currentStatus,
        );

    final analysis = OrderGeoTrackingService().analyzeOrderRoute(
      order: effectiveOrder,
      storeAddress: storeAddress,
    );

    if (currentStatus == OrderStatus.cancelled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.cancel_outlined, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              isAr ? 'تم إلغاء هذا الطلب' : 'This order was cancelled',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAr ? 'تم إيقاف مسار وتتبع هذه الطلبية.' : 'Tracking is stopped for this order.',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // 🚀 1. Live Radar Top Header (ETA & Distance Dashboard)
          // ==========================================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [analysis.stageColor.withOpacity(0.2), theme.cardColor]
                    : [analysis.stageColor.withOpacity(0.12), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: analysis.stageColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(analysis.stageIcon, color: analysis.stageColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? analysis.statusSummaryAr : analysis.statusSummaryEn,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              isAr ? 'تتبع لحظي بالـ GPS' : 'Live GPS Tracking',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // ETA Badge
                    if (currentStatus != OrderStatus.delivered)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: analysis.stageColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: analysis.stageColor.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              OrderGeoTrackingService.formatEta(analysis.estimatedMinutes, isAr: isAr),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Detailed Stage Description Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isAr ? analysis.stageDescriptionAr : analysis.stageDescriptionEn,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // 🗺️ 2. Tri-Point Visual Route Flow (Store -> Driver -> Customer)
          // ==========================================
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'مسار الرحلة والنقاط الجغرافية' : 'Live Route & Geo Points',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTriPointRoute(context, isAr, analysis, effectiveOrder),
                const SizedBox(height: 20),

                // ==========================================
                // 📊 3. Metric KPI Cards (Distances & Locations)
                // ==========================================
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildMetricCard(
                      context,
                      icon: Icons.storefront_outlined,
                      title: isAr ? 'المسافة الكلية' : 'Total Distance',
                      value: OrderGeoTrackingService.formatDistance(
                        analysis.storeToCustomerDistanceKm,
                        isAr: isAr,
                      ),
                      color: Colors.blue,
                    ),
                    if (analysis.driverToCustomerDistanceKm != null && currentStatus == OrderStatus.shipped)
                      _buildMetricCard(
                        context,
                        icon: Icons.delivery_dining_outlined,
                        title: isAr ? 'مسافة السائق عنك' : 'Driver Distance',
                        value: OrderGeoTrackingService.formatDistance(
                          analysis.driverToCustomerDistanceKm,
                          isAr: isAr,
                        ),
                        color: const Color(0xFFF59E0B),
                      ),
                    _buildMetricCard(
                      context,
                      icon: Icons.place_outlined,
                      title: isAr ? 'وجهة التسليم' : 'Destination',
                      value: effectiveOrder.shippingAddressSnapshot != null
                          ? effectiveOrder.shippingAddressSnapshot!.town.get(context)
                          : (isAr ? 'موقع الزبون' : 'Customer Location'),
                      color: const Color(0xFF10B981),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 20),

                // ==========================================
                // 🪜 4. Step-by-Step Timeline
                // ==========================================
                Text(
                  isAr ? 'مراحل الطلبية' : 'Order Stages',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTimeline(context, isAr, analysis.currentStageIndex),

                // ==========================================
                // 📞 5. Direct Driver & Store Contact Actions
                // ==========================================
                if (effectiveOrder.deliveryDriverPhone != null && effectiveOrder.deliveryDriverPhone!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFFF59E0B),
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                effectiveOrder.deliveryDriverName ?? (isAr ? 'مندوب التوصيل' : 'Delivery Driver'),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                effectiveOrder.deliveryDriverPhone!,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone, color: Color(0xFF10B981)),
                          onPressed: () => _callPhone(effectiveOrder.deliveryDriverPhone!),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 بناء المخطط البصري للمسار الثلاثي
  Widget _buildTriPointRoute(
    BuildContext context,
    bool isAr,
    OrderLiveRouteAnalysis analysis,
    OrderModel effectiveOrder,
  ) {
    final theme = Theme.of(context);
    final isShipped = currentStatus == OrderStatus.shipped;
    final isDelivered = currentStatus == OrderStatus.delivered;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Store Node
              _buildRouteNode(
                icon: Icons.storefront,
                title: isAr ? 'المتجر' : 'Store',
                subtitle: OrderGeoTrackingService.formatDistance(analysis.driverToStoreDistanceKm, isAr: isAr),
                isActive: true,
                color: Colors.blue,
              ),

              // Progress Connector 1
              Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: (isShipped || isDelivered) ? const Color(0xFFF59E0B) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Driver Node
              _buildRouteNode(
                icon: Icons.delivery_dining,
                title: isAr ? 'السائق' : 'Driver',
                subtitle: isShipped
                    ? (isAr ? 'في الطريق' : 'En route')
                    : (isDelivered ? (isAr ? 'تم التسليم' : 'Done') : (isAr ? 'بانتظار الاستلام' : 'Waiting')),
                isActive: isShipped || isDelivered,
                color: const Color(0xFFF59E0B),
              ),

              // Progress Connector 2
              Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDelivered ? const Color(0xFF10B981) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Customer Node
              _buildRouteNode(
                icon: Icons.home_rounded,
                title: isAr ? 'موقعك' : 'You',
                subtitle: OrderGeoTrackingService.formatDistance(analysis.driverToCustomerDistanceKm, isAr: isAr),
                isActive: isDelivered,
                color: const Color(0xFF10B981),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteNode({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? color : Colors.grey.shade300,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: isActive ? color : Colors.grey,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, bool isAr, int currentStageIndex) {
    final stages = [
      {'titleAr': 'تم إرسال الطلب', 'titleEn': 'Order Placed', 'icon': Icons.assignment_turned_in_outlined},
      {'titleAr': 'تأكيد المتجر', 'titleEn': 'Confirmed', 'icon': Icons.check_circle_outline},
      {'titleAr': 'التجهيز والتغليف', 'titleEn': 'Preparing', 'icon': Icons.soup_kitchen_outlined},
      {'titleAr': 'في الطريق للتسليم', 'titleEn': 'Out for Delivery', 'icon': Icons.delivery_dining_outlined},
      {'titleAr': 'تم الاستلام بنجاح', 'titleEn': 'Delivered', 'icon': Icons.task_alt_outlined},
    ];

    return Column(
      children: List.generate(stages.length, (index) {
        final isCompleted = index <= currentStageIndex;
        final isCurrent = index == currentStageIndex;
        final isLast = index == stages.length - 1;
        final stage = stages[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? (isCurrent ? const Color(0xFFF59E0B) : const Color(0xFF10B981))
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    stage['icon'] as IconData,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 24,
                    color: isCompleted ? const Color(0xFF10B981) : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isAr ? stage['titleAr'] as String : stage['titleEn'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? (isCurrent ? const Color(0xFFF59E0B) : const Color(0xFF10B981)) : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
