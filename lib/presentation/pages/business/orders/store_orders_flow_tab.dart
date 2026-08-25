import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/customer_provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/pages/customer/order_tracking/live_order_tracking_page.dart';

class StoreOrdersFlowTab extends StatefulWidget {
  const StoreOrdersFlowTab({super.key});

  @override
  State<StoreOrdersFlowTab> createState() => _StoreOrdersFlowTabState();
}

class _StoreOrdersFlowTabState extends State<StoreOrdersFlowTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final business = context.read<BusinessProvider>().selectedBusiness;
      if (business.isNotEmpty) {
        context.read<OrderProvider>().listenToBusinessOrders(business.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  void _showAssignDeliveryDialog(BuildContext context, OrderModel order) {
    final deliveryProvider = context.read<DeliveryProvider>();
    final deliveries = deliveryProvider.deliveries;

    final customNameController = TextEditingController(text: order.deliveryDriverName ?? '');
    final customPhoneController = TextEditingController(text: order.deliveryDriverPhone ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.two_wheeler_rounded, color: Colors.blue, size: 22),
              ),
              const SizedBox(width: 10),
              const Text('إسناد الطلب لجهة التوصيل', style: TextStyle(fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختر شركة أو مندوب من قائمة المناديب المعتمدة:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  if (deliveries.isEmpty)
                    const Text('لا توجد جهات توصيل مسجلة حالياً', style: TextStyle(color: Colors.grey))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: deliveries.length,
                      separatorBuilder: (context, index) => const Divider(height: 10),
                      itemBuilder: (context, index) {
                        final delivery = deliveries[index];
                        final isSelected = order.deliveryId == delivery.id;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: delivery.isOnline ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                            child: Icon(
                              delivery.type == DeliveryEntityType.company ? Icons.local_shipping : Icons.two_wheeler,
                              color: delivery.isOnline ? Colors.green : Colors.grey,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(delivery.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: delivery.isOnline ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  delivery.isOnline ? 'متاح' : 'أوفلاين',
                                  style: TextStyle(
                                    color: delivery.isOnline ? Colors.green : Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text('${delivery.phone} • أجرة التوصيل: ${delivery.baseFee} ر.س'),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? Colors.green : Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              await context.read<OrderProvider>().updateOrderDelivery(
                                    order.id,
                                    delivery.id,
                                    driverName: delivery.name,
                                    driverPhone: delivery.phone,
                                  );
                              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تم إسناد الطلب لـ ${delivery.name} بنجاح!'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            child: Text(isSelected ? 'مسند حالياً' : 'إسناد'),
                          ),
                        );
                      },
                    ),
                  const Divider(height: 24),
                  const Text(
                    'أو تعيين مندوب خاص بالمتجر (يدوياً):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: customNameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المندوب الخاص',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: customPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم هاتف المندوب',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      if (customNameController.text.trim().isEmpty) return;
                      await context.read<OrderProvider>().updateOrderDelivery(
                            order.id,
                            'store_own_driver',
                            driverName: customNameController.text.trim(),
                            driverPhone: customPhoneController.text.trim(),
                          );
                      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                    },
                    child: const Text('حفظ وإسناد المندوب الخاص'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.businessOrders;

    final newOrders = orders.where((o) => o.status == OrderStatus.pending).toList();
    final preparingOrders = orders.where((o) => o.status == OrderStatus.confirmed || o.status == OrderStatus.preparing).toList();
    final readyOrders = orders.where((o) => o.status == OrderStatus.ready).toList();
    final inTransitOrders = orders.where((o) => o.status == OrderStatus.shipped).toList();
    final completedOrders = orders.where((o) => o.status == OrderStatus.delivered).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('إدارة وتنفيذ طلبيات المتجر الحية'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.cardColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: theme.textTheme.bodySmall?.color,
          indicatorColor: theme.primaryColor,
          indicatorWeight: 3,
          isScrollable: true,
          tabs: [
            Tab(
              child: Row(
                children: [
                  const Text('طلبات جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (newOrders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(newOrders.length, Colors.red),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Text('قيد التجهيز', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (preparingOrders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(preparingOrders.length, Colors.blue),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Text('جاهزة للإسناد', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (readyOrders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(readyOrders.length, Colors.teal),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Text('قيد التوصيل', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (inTransitOrders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(inTransitOrders.length, Colors.purple),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Text('مكتملة', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (completedOrders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(completedOrders.length, Colors.green),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(context, newOrders, 'لا توجد طلبات جديدة واردة حالياً'),
          _buildOrdersList(context, preparingOrders, 'لا توجد طلبات قيد التجهيز بالمحل'),
          _buildOrdersList(context, readyOrders, 'لا توجد طلبات جاهزة بانتظار الاستلام'),
          _buildOrdersList(context, inTransitOrders, 'لا توجد طلبات في مسار التوصيل'),
          _buildOrdersList(context, completedOrders, 'سجل الطلبات المكتملة فارغ'),
        ],
      ),
    );
  }

  Widget _buildBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    List<OrderModel> orders,
    String emptyMessage,
  ) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(emptyMessage, style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildStoreOrderCard(context, order);
      },
    );
  }

  Widget _buildStoreOrderCard(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    final customer = context.watch<CustomerProvider>().getCustomerById(order.customerId);
    final customerName = customer?.name ?? order.shippingAddressSnapshot?.title ?? 'العميل';
    final customerPhone = customer?.phone ?? '';
    final address = order.shippingAddressSnapshot;

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
            // Order ID & Placed Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'طلب #${order.id.substring(0, order.id.length.clamp(0, 8))}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${order.items.length} منتجات',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primaryColor),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${order.storeTotal} ر.س',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: theme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer Info Bar
            Row(
              children: [
                const Icon(Icons.person_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(customerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(width: 14),
                const Icon(Icons.location_on_rounded, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address != null ? address.getFormattedAddress() : 'العنوان غير محدد',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (customerPhone.isNotEmpty) ...[
                  IconButton(
                    icon: const Icon(Icons.phone_rounded, color: Colors.blue, size: 20),
                    onPressed: () => _launchCaller(customerPhone),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_rounded, color: Colors.green, size: 20),
                    onPressed: () => _launchWhatsApp(customerPhone),
                  ),
                ],
              ],
            ),

            // Driver assignment status badge if assigned
            if (order.deliveryDriverName != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.two_wheeler_rounded, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'المندوب المسند: ${order.deliveryDriverName} (${order.deliveryDriverPhone ?? ''})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 24),

            // Action Buttons by Stage
            Row(
              children: [
                // View Live Tracking Page Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.track_changes_rounded, size: 16),
                  label: const Text('تتبع حي'),
                  onPressed: () => changeScreen(
                    context,
                    LiveOrderTrackingPage(orderId: order.id, initialOrder: order),
                  ),
                ),
                const Spacer(),

                if (order.status == OrderStatus.pending) ...[
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => context.read<OrderProvider>().updateOrderStatus(order.id, OrderStatus.cancelled),
                    child: const Text('رفض'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('قبول وبدء التجهيز'),
                    onPressed: () => context.read<OrderProvider>().updateOrderStatus(order.id, OrderStatus.preparing),
                  ),
                ] else if (order.status == OrderStatus.preparing || order.status == OrderStatus.confirmed) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: const Text('تم التجهيز وجاهز للاستلام 📦'),
                    onPressed: () async {
                      await context.read<OrderProvider>().updateOrderStatus(order.id, OrderStatus.ready);
                      if (context.mounted) {
                        _showAssignDeliveryDialog(context, order);
                      }
                    },
                  ),
                ] else if (order.status == OrderStatus.ready) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: Text(order.deliveryId != null ? 'تغيير المندوب' : 'إسناد لمندوب التوصيل'),
                    onPressed: () => _showAssignDeliveryDialog(context, order),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
