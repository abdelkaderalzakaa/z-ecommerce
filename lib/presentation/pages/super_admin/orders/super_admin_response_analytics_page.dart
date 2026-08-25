import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/data/services/logistics_analytics_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class SuperAdminResponseAnalyticsPage extends StatelessWidget {
  const SuperAdminResponseAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderProvider = context.watch<OrderProvider>();
    final businessProvider = context.watch<BusinessProvider>();
    final allOrders = orderProvider.allOrders;
    final allBusinesses = businessProvider.businesses;

    final kpis = LogisticsAnalyticsService.calculateLogisticsKPIs(allOrders);

    // Group orders by store to calculate store performance
    final Map<String, List<OrderModel>> ordersByStore = {};
    for (final order in allOrders) {
      ordersByStore.putIfAbsent(order.businessId, () => []).add(order);
    }

    final storeMetrics = ordersByStore.entries.map((entry) {
      final bId = entry.key;
      final storeOrders = entry.value;
      final completed = storeOrders.where((o) => o.status == OrderStatus.delivered).length;
      final bottlenecks = LogisticsAnalyticsService.detectBottlenecks(storeOrders);
      final active = storeOrders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).length;
      final onTimeRate = active > 0
          ? ((active - bottlenecks.length) / active * 100).clamp(0.0, 100.0)
          : 100.0;

      return {
        'businessId': bId,
        'total': storeOrders.length,
        'completed': completed,
        'delayed': bottlenecks.length,
        'onTimeRate': onTimeRate,
      };
    }).toList();

    // Sort by total orders descending
    storeMetrics.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Analytics KPIs
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'متوسط زمن التجهيز والتوصيل',
                    value: '${(kpis['avgFulfillmentMinutes'] as double).toStringAsFixed(0)} دقيقة',
                    subtitle: 'من لحظة الطلب حتى باب العميل',
                    icon: Icons.timer_outlined,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'نسبة الالتزام بالمواعيد (SLA)',
                    value: '${(kpis['onTimeRate'] as double).toStringAsFixed(1)}%',
                    subtitle: 'طلبات مكتملة وميدانية دون تأخير',
                    icon: Icons.verified_outlined,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'إجمالي الطلبيات المكتملة',
                    value: '${kpis['deliveredTodayCount']}',
                    subtitle: 'شحنات سلمت بنجاح للعملاء',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'مؤشرات أداء وسرعة استجابة المتاجر (Store Response & Fulfillment SLA)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (storeMetrics.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('لا توجد بيانات متاجر كافية لعرض التحليلات'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: storeMetrics.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final metric = storeMetrics[index];
                  final bId = metric['businessId'] as String;
                  final business = allBusinesses.firstWhere(
                    (b) => b.id == bId,
                    orElse: () => businessProvider.getBusinessById(bId) ?? businessProvider.businesses.first,
                  );
                  final storeName = business.localization.name.get(context);
                  final onTime = metric['onTimeRate'] as double;
                  final delayed = metric['delayed'] as int;
                  final total = metric['total'] as int;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: onTime >= 85 ? Colors.green.withOpacity(0.15) : Colors.amber.withOpacity(0.15),
                            child: Icon(
                              Icons.storefront_rounded,
                              color: onTime >= 85 ? Colors.green : Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  storeName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'إجمالي الطلبات: $total • المكتملة: ${metric['completed']} • التأخيرات الحالية: $delayed',
                                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${onTime.toStringAsFixed(0)}% التزام',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: onTime >= 85 ? Colors.green : (onTime >= 65 ? Colors.amber.shade900 : Colors.red),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 90,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (onTime / 100).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: onTime >= 85 ? Colors.green : Colors.amber.shade800,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              Icon(icon, color: color, size: 22),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
