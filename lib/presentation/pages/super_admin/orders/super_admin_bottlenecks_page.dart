import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/customer_provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/data/services/logistics_analytics_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/pages/customer/order_tracking/live_order_tracking_page.dart';

class SuperAdminBottlenecksPage extends StatefulWidget {
  const SuperAdminBottlenecksPage({super.key});

  @override
  State<SuperAdminBottlenecksPage> createState() => _SuperAdminBottlenecksPageState();
}

class _SuperAdminBottlenecksPageState extends State<SuperAdminBottlenecksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  void _showDirectAssignDriverDialog(BuildContext context, OrderModel order) {
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
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flash_on_rounded, color: Colors.red, size: 22),
              ),
              const SizedBox(width: 10),
              const Text('تدخل سريع: إسناد مندوب توصيل فورياً', style: TextStyle(fontSize: 16)),
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
                    'اختر مندوباً متاحاً لإنهاء حالة التأخير والإسناد للطلب:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  if (deliveries.isEmpty)
                    const Text('لا يوجد مناديب مسجلين في المنصة', style: TextStyle(color: Colors.grey))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: deliveries.length,
                      separatorBuilder: (context, index) => const Divider(height: 10),
                      itemBuilder: (context, index) {
                        final delivery = deliveries[index];
                        final isOnline = delivery.isOnline;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: isOnline ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                            child: Icon(
                              delivery.type == DeliveryEntityType.company ? Icons.local_shipping : Icons.two_wheeler,
                              color: isOnline ? Colors.green : Colors.grey,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(delivery.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isOnline ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isOnline ? 'متاح أونلاين 🟢' : 'أوفلاين',
                                  style: TextStyle(
                                    color: isOnline ? Colors.green : Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text('${delivery.phone} • رسوم التوصيل: ${delivery.baseFee} ر.س'),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
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
                              // If order is ready, mark it assigned
                              if (order.status == OrderStatus.preparing || order.status == OrderStatus.confirmed) {
                                await context.read<OrderProvider>().updateOrderStatus(order.id, OrderStatus.ready);
                              }
                              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تم إسناد الطلب لـ ${delivery.name} بنجاح وحل الاختناق! ⚡'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            child: const Text('إسناد فوري'),
                          ),
                        );
                      },
                    ),
                  const Divider(height: 24),
                  const Text('أو تعيين مندوب يدوياً بالاسم ورقم الهاتف:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: customNameController,
                    decoration: const InputDecoration(labelText: 'اسم المندوب'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: customPhoneController,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      if (customNameController.text.trim().isEmpty) return;
                      await context.read<OrderProvider>().updateOrderDelivery(
                            order.id,
                            'custom_driver',
                            driverName: customNameController.text.trim(),
                            driverPhone: customPhoneController.text.trim(),
                          );
                      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                    },
                    child: const Text('حفظ المندوب وإسناد الطلب'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  void _showResolutionDialog(BuildContext context, OrderModel order) {
    final noteController = TextEditingController();

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
                  color: Colors.purple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.gavel_rounded, color: Colors.purple, size: 22),
              ),
              const SizedBox(width: 10),
              const Text('معالجة وحسم حالة الطلب إدارياً', style: TextStyle(fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'في حال وصول الشحنة مع تعذر تأكيد العميل، أو وجود خلاف، يمكنك حسم النتيجة وتوثيق السبب:',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات وتوثيق القرار الإداري',
                    hintText: 'مثال: تم التواصل مع العميل والمندوب وتأكيد استلام الطرد بنجاح...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('اعتماد التسليم إدارياً ✅'),
                        onPressed: () async {
                          await context.read<OrderProvider>().updateOrderStatus(
                                order.id,
                                OrderStatus.delivered,
                                deliveryNotes: noteController.text.trim().isNotEmpty
                                    ? noteController.text.trim()
                                    : 'تم اعتماد وتأكيد التسليم بقرار إداري من السوبر أدمن.',
                              );
                          if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم اعتماد التسليم بنجاح وإغلاق الطلب! 🎉'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.assignment_return_rounded, size: 18),
                        label: const Text('إعادة الشحنة للمتجر وإلغاء الطلب ↩️'),
                        onPressed: () async {
                          await context.read<OrderProvider>().updateOrderStatus(
                                order.id,
                                OrderStatus.cancelled,
                                deliveryNotes: noteController.text.trim().isNotEmpty
                                    ? noteController.text.trim()
                                    : 'تعذر التسليم وتمت إعادة الطرد للمتجر بقرار إداري.',
                              );
                          if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تمت إعادة الطلب للمتجر وتحديث السجل بنجاح.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
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
    final allOrders = orderProvider.allOrders;

    final bottlenecks = LogisticsAnalyticsService.detectBottlenecks(allOrders);

    final delayBottlenecks = bottlenecks.where((b) => b.delayType != DelayType.unconfirmedDelivery).toList();
    final unconfirmedBottlenecks = bottlenecks.where((b) => b.delayType == DelayType.unconfirmedDelivery).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: theme.cardColor,
          child: TabBar(
            controller: _tabController,
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.textTheme.bodySmall?.color,
            indicatorColor: theme.primaryColor,
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text('تنبيهات التأخير والاختناق الميداني', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (delayBottlenecks.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _buildCountBadge(delayBottlenecks.length, Colors.red),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.help_outline_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text('طلبات عالقة / غير مؤكدة الاستلام', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (unconfirmedBottlenecks.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _buildCountBadge(unconfirmedBottlenecks.length, Colors.purple),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBottlenecksList(context, delayBottlenecks, isUnconfirmedTab: false),
          _buildBottlenecksList(context, unconfirmedBottlenecks, isUnconfirmedTab: true),
        ],
      ),
    );
  }

  Widget _buildCountBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBottlenecksList(
    BuildContext context,
    List<OrderDelayInfo> list, {
    required bool isUnconfirmedTab,
  }) {
    final theme = Theme.of(context);

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnconfirmedTab ? Icons.verified_rounded : Icons.check_circle_rounded,
              size: 64,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 14),
            Text(
              isUnconfirmedTab ? 'لا توجد طلبات عالقة أو متنازع عليها حالياً' : 'ممتاز! لا توجد اختناقات أو تأخيرات في مسارات العمليات',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              isUnconfirmedTab ? 'كافة الشحنات تم تسليمها وتأكيدها بصورة سليمة.' : 'كافة المتاجر والمناديب يعملون وفق معايير الوقت المحددة.',
              style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _buildBottleneckCard(context, list[index], isUnconfirmedTab: isUnconfirmedTab);
      },
    );
  }

  Widget _buildBottleneckCard(
    BuildContext context,
    OrderDelayInfo info, {
    required bool isUnconfirmedTab,
  }) {
    final theme = Theme.of(context);
    final order = info.order;
    final business = context.watch<BusinessProvider>().getBusinessById(order.businessId);
    final customer = context.watch<CustomerProvider>().getCustomerById(order.customerId);

    final storeName = business?.localization.name.get(context) ?? 'المتجر #${order.businessId}';
    final storePhone = business?.ownerPhone ?? '';
    final customerName = customer?.name ?? order.shippingAddressSnapshot?.title ?? 'العميل';
    final customerPhone = customer?.phone ?? '';
    final driverName = order.deliveryDriverName ?? 'لم يُسند بعد';
    final driverPhone = order.deliveryDriverPhone ?? '';

    Color severityColor = info.severity == 3 ? Colors.red : Colors.orange;
    if (isUnconfirmedTab) severityColor = Colors.purple;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: severityColor.withOpacity(0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Alert Bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        info.severity == 3 ? Icons.error_outline_rounded : Icons.timer_outlined,
                        color: severityColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'تأخير ${info.elapsedDuration.inMinutes} دقيقة',
                        style: TextStyle(color: severityColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    info.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Text(
                  'طلب #${order.id.substring(0, order.id.length.clamp(0, 8))}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.primaryColor),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              info.description,
              style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الإجراء الموصى به: ${info.recommendedAction}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Contacts of all 3 parties
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildContactChip('المتجر: $storeName', storePhone),
                _buildContactChip('المندوب: $driverName', driverPhone),
                _buildContactChip('العميل: $customerName', customerPhone),
              ],
            ),

            const Divider(height: 24),

            // Super Admin Intervention Buttons
            Row(
              children: [
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

                // Assign/Reassign Driver Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: Text(order.deliveryId != null ? 'إعادة إسناد مندوب' : 'إسناد مندوب فوراً ⚡'),
                  onPressed: () => _showDirectAssignDriverDialog(context, order),
                ),

                const SizedBox(width: 8),

                // Resolve / Force Confirmation Dialog
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.gavel_rounded, size: 18),
                  label: const Text('حسم إداري للطلب 🛡️'),
                  onPressed: () => _showResolutionDialog(context, order),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactChip(String label, String phone) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        if (phone.isNotEmpty) ...[
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _launchCaller(phone),
            child: const Icon(Icons.phone, size: 14, color: Colors.blue),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _launchWhatsApp(phone),
            child: const Icon(Icons.chat, size: 14, color: Colors.green),
          ),
        ],
      ],
    );
  }
}
