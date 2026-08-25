import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/customer_provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/currency_helper.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/pages/delivery/delivery_order_details_page.dart';

class DeliveryDashboardOverviewPage extends StatelessWidget {
  final VoidCallback onNavigateToOrders;

  const DeliveryDashboardOverviewPage({
    super.key,
    required this.onNavigateToOrders,
  });

  Future<void> _launchCaller(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    if (phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMap(String addressQuery, {double? lat, double? lng}) async {
    Uri uri;
    if (lat != null && lng != null) {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    } else {
      final encoded = Uri.encodeComponent(addressQuery);
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deliveryProvider = context.watch<DeliveryProvider>();
    final delivery = deliveryProvider.currentDelivery;

    final pendingCount = deliveryProvider.pendingPickupOrders.length;
    final inTransitCount = deliveryProvider.inTransitOrders.length;
    final todayEarnings = deliveryProvider.todayDeliveredEarnings;

    final inTransitOrders = deliveryProvider.inTransitOrders;
    final pendingOrders = deliveryProvider.pendingPickupOrders;

    // Nearest urgent mission
    final currentMission = inTransitOrders.isNotEmpty
        ? inTransitOrders.first
        : pendingOrders.isNotEmpty
            ? pendingOrders.first
            : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entity Profile & Rating Overview Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.primaryColor.withOpacity(0.12),
                    child: Icon(
                      delivery.type == DeliveryEntityType.company
                          ? Icons.local_shipping_rounded
                          : Icons.two_wheeler_rounded,
                      color: theme.primaryColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery.name.isNotEmpty ? delivery.name : 'كابتن التوصيل',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          delivery.vehicleDetails?.isNotEmpty == true
                              ? delivery.vehicleDetails!
                              : (delivery.type == DeliveryEntityType.company ? 'أسطول شحن معتمد' : 'دراجة نارية / مركبة توصيل'),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          delivery.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Top Urgent Mission Banner (If any active order)
            if (currentMission != null) ...[
              _buildUrgentMissionCard(context, currentMission),
              const SizedBox(height: 18),
            ],

            // KPI Quick Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildSmallKpi(
                    context,
                    title: 'بانتظار الاستلام',
                    value: '$pendingCount',
                    icon: Icons.storefront_rounded,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSmallKpi(
                    context,
                    title: 'في الطريق',
                    value: '$inTransitCount',
                    icon: Icons.directions_bike_rounded,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSmallKpi(
                    context,
                    title: 'أرباح اليوم',
                    value: AppCurrencyHelper.formatUSD(todayEarnings),
                    icon: Icons.account_balance_wallet_rounded,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Active Orders Quick Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'قائمة المهام والطلبات الحالية',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: onNavigateToOrders,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('كل الطلبات'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (pendingOrders.isEmpty && inTransitOrders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 52, color: Colors.green.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      'أحسنت! لا توجد طلبات جارية الآن',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'أنت على استعداد لاستلام أي طلبات جديدة فور إسنادها لك',
                      style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ([...inTransitOrders, ...pendingOrders]).length.clamp(0, 4),
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final order = ([...inTransitOrders, ...pendingOrders])[index];
                  final business = context.watch<BusinessProvider>().getBusinessById(order.businessId);
                  final businessName = business?.localization.name.get(context) ?? 'المتجر';
                  final isInTransit = order.status == OrderStatus.shipped;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isInTransit ? Colors.blue.shade300 : theme.dividerColor.withOpacity(0.12),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      leading: CircleAvatar(
                        backgroundColor: isInTransit
                            ? Colors.blue.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.15),
                        child: Icon(
                          isInTransit ? Icons.directions_bike_rounded : Icons.storefront_rounded,
                          color: isInTransit ? Colors.blue : Colors.orange,
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            'طلب #${order.id.substring(0, order.id.length.clamp(0, 8))}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const Spacer(),
                          Text(
                            '+${AppCurrencyHelper.formatDual(order.shippingCost, isArabic: true)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'من: $businessName • إلى: ${order.shippingAddressSnapshot?.city.get(context) ?? 'العنوان'}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => changeScreen(context, DeliveryOrderDetailsPage(order: order)),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentMissionCard(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    final isInTransit = order.status == OrderStatus.shipped;
    final business = context.watch<BusinessProvider>().getBusinessById(order.businessId);
    final businessName = business?.localization.name.get(context) ?? 'المتجر';
    final businessPhone = business?.ownerPhone ?? '';
    final businessAddress = businessName;

    final customer = context.watch<CustomerProvider>().getCustomerById(order.customerId);
    final customerPhone = customer?.phone ?? '';
    final address = order.shippingAddressSnapshot;
    final customerAddressText = address != null ? address.getFormattedAddress() : 'العنوان';

    final targetName = isInTransit ? (customer?.name ?? 'العميل') : businessName;
    final targetPhone = isInTransit ? customerPhone : businessPhone;
    final targetAddress = isInTransit ? customerAddressText : businessAddress;
    final actionHeadline = isInTransit ? '🚗 مهمتك الحالية: توصيل للعميل' : '📦 مهمتك الحالية: استلام من المتجر';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isInTransit
            ? (theme.brightness == Brightness.dark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF))
            : (theme.brightness == Brightness.dark ? const Color(0xFF78350F) : const Color(0xFFFFFBEB)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isInTransit ? Colors.blue.shade400 : Colors.amber.shade500,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isInTransit ? Colors.blue : Colors.amber).withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isInTransit ? Colors.blue : Colors.amber.shade800),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  actionHeadline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'طلب #${order.id.substring(0, order.id.length.clamp(0, 8))}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            targetName,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  targetAddress,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Big Quick Buttons
          Row(
            children: [
              if (targetPhone.isNotEmpty) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: const Text('اتصال سريع', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _launchCaller(targetPhone),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(Icons.chat_rounded, size: 20),
                  tooltip: 'واتساب',
                  onPressed: () => _launchWhatsApp(targetPhone),
                ),
                const SizedBox(width: 8),
              ],
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(Icons.navigation_rounded, size: 20),
                tooltip: 'خرائط جوجل',
                onPressed: () => _openMap(
                  targetAddress,
                  lat: isInTransit ? address?.latitude : null,
                  lng: isInTransit ? address?.longitude : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Complete Mission Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isInTransit ? Colors.green.shade700 : Colors.blue.shade800,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(isInTransit ? Icons.check_circle_rounded : Icons.inventory_2_rounded, size: 20),
            label: Text(
              isInTransit ? '✅ تم تسليم الطلب للعميل' : '📦 تم استلام الطرد من المتجر',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: () async {
              await context.read<DeliveryProvider>().updateOrderStatus(
                    order.id,
                    isInTransit ? OrderStatus.delivered : OrderStatus.shipped,
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSmallKpi(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 18),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
