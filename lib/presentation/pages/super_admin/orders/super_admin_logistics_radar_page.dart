import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/customer_provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/data/services/logistics_analytics_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/pages/customer/order_tracking/live_order_tracking_page.dart';

class SuperAdminLogisticsRadarPage extends StatefulWidget {
  const SuperAdminLogisticsRadarPage({super.key});

  @override
  State<SuperAdminLogisticsRadarPage> createState() => _SuperAdminLogisticsRadarPageState();
}

class _SuperAdminLogisticsRadarPageState extends State<SuperAdminLogisticsRadarPage> {
  final String _filterCity = 'all';
  String _filterStatus = 'active';

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

  Future<void> _launchMapRoute(String originQuery, String destinationQuery) async {
    final originEncoded = Uri.encodeComponent(originQuery);
    final destEncoded = Uri.encodeComponent(destinationQuery);
    final url = 'https://www.google.com/maps/dir/?api=1&origin=$originEncoded&destination=$destEncoded';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderProvider = context.watch<OrderProvider>();
    final allOrders = orderProvider.allOrders;

    final kpis = LogisticsAnalyticsService.calculateLogisticsKPIs(allOrders);

    final filteredOrders = allOrders.where((order) {
      if (_filterStatus == 'active') {
        if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) {
          return false;
        }
      } else if (_filterStatus == 'delivered') {
        if (order.status != OrderStatus.delivered) return false;
      }

      if (_filterCity != 'all') {
        final address = order.shippingAddressSnapshot;
        if (address == null || !address.city.get(context).toLowerCase().contains(_filterCity.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Cards
            _buildRadarKPIs(context, kpis),

            const SizedBox(height: 20),

            // Filter and Title Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.radar_rounded, color: theme.primaryColor, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'رادار مسارات الشحنات الحية (Origin ➔ Destination)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'مراقبة فورية لمصدر كل طلبية ووجهة العميل والمندوب المسؤول',
                          style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'active', label: Text('نشطة حالياً')),
                        ButtonSegment(value: 'all', label: Text('كافة الطلبات')),
                        ButtonSegment(value: 'delivered', label: Text('المكتملة')),
                      ],
                      selected: {_filterStatus},
                      onSelectionChanged: (val) => setState(() => _filterStatus = val.first),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (filteredOrders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 60, color: Colors.green.shade400),
                    const SizedBox(height: 12),
                    const Text('لا توجد شحنات نشطة مطابقة للفلتر حالياً', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredOrders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return _buildShipmentRadarCard(context, filteredOrders[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarKPIs(BuildContext context, Map<String, dynamic> kpis) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildKpiCard(
              title: 'الطلبيات النشطة في الميدان',
              value: '${kpis['totalActiveOrders']}',
              icon: Icons.two_wheeler_rounded,
              color: Colors.blue,
              width: isMobile ? double.infinity : 220,
            ),
            _buildKpiCard(
              title: 'تنبيهات الاختناق والتأخير',
              value: '${kpis['bottlenecksCount']}',
              icon: Icons.warning_amber_rounded,
              color: (kpis['bottlenecksCount'] as int) > 0 ? Colors.red : Colors.green,
              width: isMobile ? double.infinity : 220,
            ),
            _buildKpiCard(
              title: 'معدل الالتزام بالوقت (SLA)',
              value: '${(kpis['onTimeRate'] as double).toStringAsFixed(1)}%',
              icon: Icons.speed_rounded,
              color: Colors.teal,
              width: isMobile ? double.infinity : 220,
            ),
            _buildKpiCard(
              title: 'متوسط زمن إنجاز الطلب',
              value: '${(kpis['avgFulfillmentMinutes'] as double).toStringAsFixed(0)} دقيقة',
              icon: Icons.timer_outlined,
              color: Colors.purple,
              width: isMobile ? double.infinity : 220,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentRadarCard(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    final business = context.watch<BusinessProvider>().getBusinessById(order.businessId);
    final customer = context.watch<CustomerProvider>().getCustomerById(order.customerId);

    final storeName = business?.localization.name.get(context) ?? 'المتجر #${order.businessId}';
    final storePhone = business?.ownerPhone ?? '';
    final storeAddress = 'مقر المتجر الرئيسي';

    final customerName = customer?.name ?? order.shippingAddressSnapshot?.title ?? 'العميل';
    final customerPhone = customer?.phone ?? '';
    final customerAddress = order.shippingAddressSnapshot?.getFormattedAddress() ?? 'العنوان غير محدد';

    final driverName = order.deliveryDriverName ?? 'لم يتم التعيين بعد';
    final driverPhone = order.deliveryDriverPhone ?? '';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Order ID, Status, Amount, Live Tracking
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'طلب #${order.id.substring(0, order.id.length.clamp(0, 8))}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    _buildStatusChip(order.status),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${order.storeTotal} ر.س',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.track_changes_rounded, size: 16),
                      label: const Text('تتبع حي', style: TextStyle(fontSize: 12)),
                      onPressed: () => changeScreen(
                        context,
                        LiveOrderTrackingPage(orderId: order.id, initialOrder: order),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Route Visualizer: [Origin Store] ➔ [Driver Hub] ➔ [Destination Customer]
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  // Origin Store
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.storefront_rounded, size: 16, color: Colors.blue),
                            const SizedBox(width: 6),
                            const Text('المصدر (المتجر)', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                        Text(storeAddress, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (storePhone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              InkWell(
                                onTap: () => _launchCaller(storePhone),
                                child: const Icon(Icons.phone, size: 14, color: Colors.blue),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _launchWhatsApp(storePhone),
                                child: const Icon(Icons.chat, size: 14, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Middle Arrow
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                        IconButton(
                          tooltip: 'فتح خط السير في Google Maps',
                          icon: const Icon(Icons.map_rounded, color: Colors.teal, size: 20),
                          onPressed: () => _launchMapRoute(storeAddress, customerAddress),
                        ),
                      ],
                    ),
                  ),

                  // Destination Customer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: Colors.green),
                            const SizedBox(width: 6),
                            const Text('الوجهة (العميل)', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                        Text(customerAddress, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (customerPhone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              InkWell(
                                onTap: () => _launchCaller(customerPhone),
                                child: const Icon(Icons.phone, size: 14, color: Colors.blue),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _launchWhatsApp(customerPhone),
                                child: const Icon(Icons.chat, size: 14, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Driver Assignment Status & Payment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      order.deliveryId != null ? Icons.two_wheeler_rounded : Icons.person_off_rounded,
                      size: 16,
                      color: order.deliveryId != null ? Colors.blue : Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'المندوب: $driverName',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: order.deliveryId != null ? Colors.blue : Colors.orange,
                      ),
                    ),
                    if (driverPhone.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _launchCaller(driverPhone),
                        child: const Icon(Icons.phone, size: 14, color: Colors.blue),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _launchWhatsApp(driverPhone),
                        child: const Icon(Icons.chat, size: 14, color: Colors.green),
                      ),
                    ],
                  ],
                ),
                Text(
                  order.paymentMethod == PaymentMethod.cashOnDelivery
                      ? '💵 تحصيل كاش (COD)'
                      : '💳 مدفوع إلكترونياً',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: order.paymentMethod == PaymentMethod.cashOnDelivery ? Colors.amber.shade900 : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String label;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.amber;
        label = 'بانتظار قبول المتجر';
        break;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        color = Colors.blue;
        label = 'قيد التجهيز';
        break;
      case OrderStatus.ready:
        color = Colors.teal;
        label = 'جاهز للاستلام';
        break;
      case OrderStatus.shipped:
        color = Colors.purple;
        label = 'في الطريق مع المندوب';
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        label = 'تم التسليم';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        label = 'ملغي';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
