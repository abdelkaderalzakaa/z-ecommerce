import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/pages/business/settings/store_manage_delivery_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/orders/order_details_page.dart';

class StoreDeliveryManagementPage extends StatelessWidget {
  final String businessId;

  const StoreDeliveryManagementPage({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final business = context.watch<BusinessProvider>().selectedBusiness;
    final deliveryProvider = context.watch<DeliveryProvider>();
    final orderProvider = context.watch<OrderProvider>();

    final assignedDeliveries = deliveryProvider.deliveries.where((d) {
      return business.assignedDeliveryIds.contains(d.id);
    }).toList();

    final deliveryOrders = orderProvider.businessOrders.where((o) {
      return o.deliveryId != null && o.deliveryId!.isNotEmpty;
    }).toList();

    final isPlatform = business.deliveryHandling == DeliveryHandlingType.platform;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إدارة التوصيل والمناديب',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'متابعة وإدارة جهات التوصيل والطلبات المسندة لهم',
                      style: TextStyle(fontSize: 14, color: theme.textTheme.bodySmall?.color),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    changeScreen(context, StoreManageDeliveryPage(store: business));
                  },
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  label: const Text('إعدادات التوصيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Metrics Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context: context,
                    title: 'نموذج التوصيل',
                    value: isPlatform ? 'شبكة المنصة' : 'خاص بالمتجر',
                    icon: isPlatform ? Icons.hub_rounded : Icons.storefront_rounded,
                    iconColor: isPlatform ? Colors.blue : Colors.teal,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMetricCard(
                    context: context,
                    title: 'المناديب المعتمدون لمتجرك',
                    value: isPlatform ? '${assignedDeliveries.length} جهة' : 'فريق المتجر',
                    icon: Icons.local_shipping_rounded,
                    iconColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMetricCard(
                    context: context,
                    title: 'الطلبات المسندة للتوصيل',
                    value: '${deliveryOrders.length} طلب',
                    icon: Icons.assignment_turned_in_rounded,
                    iconColor: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Main Content: Assigned Deliveries
            if (isPlatform) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'جهات التوصيل المرتبطة بالمتجر',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (assignedDeliveries.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        changeScreen(context, StoreManageDeliveryPage(store: business));
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة أو تعديل المناديب'),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (assignedDeliveries.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.delivery_dining_outlined, size: 60, color: theme.primaryColor.withOpacity(0.6)),
                      const SizedBox(height: 14),
                      const Text(
                        'لم تقم بربط أي جهة توصيل بمتجرك بعد',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'قم باختيار مناديب أو شركات التوصيل المعتمدة على المنصة لتمكين إسناد الطلبات لهم.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          changeScreen(context, StoreManageDeliveryPage(store: business));
                        },
                        icon: const Icon(Icons.add_link),
                        label: const Text('اختيار وربط جهات التوصيل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: assignedDeliveries.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final delivery = assignedDeliveries[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: theme.primaryColor.withOpacity(0.1),
                              backgroundImage: delivery.logo != null && delivery.logo!.isNotEmpty
                                  ? NetworkImage(delivery.logo!)
                                  : null,
                              child: delivery.logo == null || delivery.logo!.isEmpty
                                  ? Icon(
                                      delivery.type == DeliveryEntityType.company
                                          ? Icons.business_rounded
                                          : Icons.person_rounded,
                                      color: theme.primaryColor,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        delivery.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      if (delivery.isPlatformApproved) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.amber.shade600, width: 0.8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.verified, size: 12, color: Colors.amber),
                                              SizedBox(width: 3),
                                              Text(
                                                'معتمد',
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'الهاتف: ${delivery.phone} • الرسوم الأساسية: \$${delivery.baseFee.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'إلغاء الربط',
                              icon: const Icon(Icons.link_off, color: Colors.redAccent),
                              onPressed: () {
                                final updatedList = List<String>.from(business.assignedDeliveryIds)..remove(delivery.id);
                                context.read<BusinessProvider>().saveBusiness(
                                  business.copyWith(assignedDeliveryIds: updatedList),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ] else ...[
              // Own Delivery Active Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.storefront_rounded, color: Colors.teal, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'التوصيل الخاص بالمتجر مفعل',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'أنت تعتمد حالياً على فريق التوصيل الخاص بمتجرك لتوصيل جميع الطلبات للعملاء مباشرة.',
                      style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        changeScreen(context, StoreManageDeliveryPage(store: business));
                      },
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: const Text('التبديل إلى شبكة توصيل المنصة'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // 4. Assigned Delivery Orders Table
            const Text(
              'الطلبات الجارية والمرتبطة بالتوصيل',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (deliveryOrders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      'لا توجد طلبات مسندة للتوصيل حالياً',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              )
            else
              AppDataTable<OrderModel>(
                items: deliveryOrders,
                columns: [
                  AppTableColumn<OrderModel>(
                    title: 'رقم الطلب',
                    width: 140,
                    cellBuilder: (order) => TableTextCell(
                      title: '#${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',
                      isBold: true,
                    ),
                  ),
                  AppTableColumn<OrderModel>(
                    title: 'جهة التوصيل',
                    width: 180,
                    cellBuilder: (order) {
                      final del = deliveryProvider.getDeliveryById(order.deliveryId ?? '');
                      return Text(del?.name ?? order.deliveryId ?? 'غير محدد');
                    },
                  ),
                  AppTableColumn<OrderModel>(
                    title: 'الإجمالي',
                    width: 120,
                    cellBuilder: (order) => Text(
                      '\$${order.storeTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  AppTableColumn<OrderModel>(
                    title: 'الحالة',
                    width: 140,
                    cellBuilder: (order) => TableStatusBadge.fromStatus(order.status.name),
                  ),
                ],
                onRowTap: (order) {
                  changeScreen(context, OrderDetailsPage(orderId: order.id));
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
