import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/customer_provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/currency_helper.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/pages/delivery/delivery_order_details_page.dart';

class DeliveryOrdersPage extends StatefulWidget {
  const DeliveryOrdersPage({super.key});

  @override
  State<DeliveryOrdersPage> createState() => _DeliveryOrdersPageState();
}

class _DeliveryOrdersPageState extends State<DeliveryOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isTableView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

  Future<void> _quickUpdateStatus(BuildContext context, OrderModel order, OrderStatus newStatus) async {
    try {
      await context.read<DeliveryProvider>().updateOrderStatus(order.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(newStatus == OrderStatus.shipped
                    ? 'تم استلام الطرد بنجاح وبدء التوصيل 🚀'
                    : 'تم تأكيد تسليم الطلب بنجاح ✅'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ أثناء التحديث: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = context.watch<LocaleProvider>().locale.languageCode == 'ar';
    final deliveryProvider = context.watch<DeliveryProvider>();

    final pending = deliveryProvider.pendingPickupOrders;
    final inTransit = deliveryProvider.inTransitOrders;
    final delivered = deliveryProvider.deliveredOrders;
    final cancelled = deliveryProvider.cancelledOrders;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header Card Matching Admin Standards
            Container(
              width: double.infinity,
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.inventory_2_rounded, color: theme.primaryColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'مهام وشحنات التوصيل' : 'Delivery Orders & Missions',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAr
                              ? 'إدارة ومتابعة الشحنات اللحظية، استلام الطرود، والتسليم للعملاء'
                              : 'Manage active deliveries, package pickup, and customer drop-offs',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    icon: Icon(_isTableView ? Icons.grid_view_rounded : Icons.table_chart_rounded, size: 18),
                    label: Text(_isTableView ? (isAr ? 'عرض البطاقات' : 'Card View') : (isAr ? 'عرض الجدول' : 'Table View')),
                    onPressed: () => setState(() => _isTableView = !_isTableView),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Styled Segmented Tab Bar Container
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: theme.primaryColor,
                labelColor: theme.primaryColor,
                unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isAr ? 'بانتظار الاستلام' : 'Pending Pickup'),
                        if (pending.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _buildTabBadge(pending.length, Colors.orange),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isAr ? 'في الطريق' : 'In Transit'),
                        if (inTransit.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _buildTabBadge(inTransit.length, Colors.blue),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isAr ? 'تم التسليم' : 'Delivered'),
                        if (delivered.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _buildTabBadge(delivered.length, Colors.green),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isAr ? 'ملغية' : 'Cancelled'),
                        if (cancelled.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _buildTabBadge(cancelled.length, Colors.red),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Main Tab View Area (Cards or Data Table)
            Expanded(
              child: deliveryProvider.isOrdersLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTabContent(context, pending, 'لا توجد شحنات بانتظار الاستلام حالياً'),
                        _buildTabContent(context, inTransit, 'لا توجد شحنات في الطريق حالياً'),
                        _buildTabContent(context, delivered, 'لا توجد شحنات مكتملة حتى الآن'),
                        _buildTabContent(context, cancelled, 'سجل الطلبات الملغية فارغ'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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

  Widget _buildTabContent(BuildContext context, List<OrderModel> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (_isTableView) {
      return _buildOrdersDataTable(context, orders);
    }

    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (ctx, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildDriverOrderCard(context, orders[index]);
      },
    );
  }

  Widget _buildOrdersDataTable(BuildContext context, List<OrderModel> orders) {
    final isAr = context.watch<LocaleProvider>().locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return AppDataTable<OrderModel>(
      items: orders,
      selectable: false,
      showIndexColumn: true,
      searchMatcher: (order, query) {
        final driverName = order.deliveryDriverName?.toLowerCase() ?? '';
        final city = order.shippingAddressSnapshot?.city.get(context).toLowerCase() ?? '';
        return order.id.toLowerCase().contains(query) ||
            driverName.contains(query) ||
            city.contains(query);
      },
      columns: [
        AppTableColumn<OrderModel>(
          title: isAr ? 'رقم الطلب' : 'Order ID',
          width: 140,
          cellBuilder: (order) => Text(
            '#${order.id.substring(0, order.id.length.clamp(0, 8))}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        AppTableColumn<OrderModel>(
          title: isAr ? 'المتجر (الاستلام)' : 'Store (Pickup)',
          width: 200,
          cellBuilder: (order) {
            final business = context.watch<BusinessProvider>().getBusinessById(order.businessId);
            final name = business?.localization.name.get(context) ?? 'المتجر';
            final phone = business?.ownerPhone ?? '';
            return TableImageTextCell(
              title: name,
              subtitle: phone,
              fallbackIcon: Icons.storefront_rounded,
            );
          },
        ),
        AppTableColumn<OrderModel>(
          title: isAr ? 'العميل (التسليم)' : 'Customer (Drop-off)',
          width: 200,
          cellBuilder: (order) {
            final customer = context.watch<CustomerProvider>().getCustomerById(order.customerId);
            final name = customer?.name ?? 'العميل';
            final city = order.shippingAddressSnapshot?.city.get(context) ?? 'العنوان';
            return TableImageTextCell(
              title: name,
              subtitle: city,
              fallbackIcon: Icons.person_pin_circle_rounded,
            );
          },
        ),
        AppTableColumn<OrderModel>(
          title: isAr ? 'أجرة التوصيل' : 'Fee',
          width: 150,
          cellBuilder: (order) => Text(
            AppCurrencyHelper.formatDual(order.shippingCost, isArabic: isAr),
            style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 12),
          ),
        ),
        AppTableColumn<OrderModel>(
          title: isAr ? 'الدفع والتحصيل' : 'Payment',
          width: 160,
          cellBuilder: (order) => Text(
            order.paymentMethod == PaymentMethod.cashOnDelivery
                ? 'COD: ${AppCurrencyHelper.formatUSD(order.storeTotal)}'
                : 'مدفوع إلكترونياً ✅',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: order.paymentMethod == PaymentMethod.cashOnDelivery ? Colors.amber.shade900 : Colors.green,
            ),
          ),
        ),
        AppTableColumn<OrderModel>(
          title: isAr ? 'الحالة' : 'Status',
          width: 130,
          cellBuilder: (order) => TableStatusBadge.fromStatus(order.status.name),
        ),
        AppTableColumn<OrderModel>(
          title: isAr ? 'التفاصيل' : 'Details',
          width: 110,
          cellBuilder: (order) => IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, size: 20),
            onPressed: () => changeScreen(context, DeliveryOrderDetailsPage(order: order)),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverOrderCard(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    final isAr = context.watch<LocaleProvider>().locale.languageCode == 'ar';
    final business = context.watch<BusinessProvider>().getBusinessById(order.businessId);
    final businessName = business?.localization.name.get(context) ?? 'المتجر';
    final businessPhone = business?.ownerPhone ?? '';

    final customer = context.watch<CustomerProvider>().getCustomerById(order.customerId);
    final customerPhone = customer?.phone ?? '';
    final address = order.shippingAddressSnapshot;
    final customerAddressText = address != null ? address.getFormattedAddress() : 'العنوان غير محدد';

    final isPendingPickup = order.status == OrderStatus.pending ||
        order.status == OrderStatus.confirmed ||
        order.status == OrderStatus.preparing ||
        order.status == OrderStatus.ready;
    final isInTransit = order.status == OrderStatus.shipped;
    final isCod = order.paymentMethod == PaymentMethod.cashOnDelivery;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isInTransit
              ? Colors.blue.shade300
              : isPendingPickup
                  ? Colors.orange.shade300
                  : theme.dividerColor.withOpacity(0.12),
          width: isInTransit || isPendingPickup ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getStatusIcon(order.status),
                        color: _getStatusColor(order.status),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طلب #${order.id.substring(0, order.id.length.clamp(0, 8))}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          _getStatusLabel(order.status),
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${AppCurrencyHelper.formatDual(order.shippingCost, isArabic: isAr)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            if (isCod) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: Row(
                  children: [
                    Icon(Icons.payments_rounded, color: Colors.amber.shade900, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'تحصيل نقدي عند التسليم (COD): ${AppCurrencyHelper.formatDual(order.storeTotal, isArabic: true)}'
                            : 'Cash On Delivery (COD): ${AppCurrencyHelper.formatDual(order.storeTotal, isArabic: false)}',
                        style: const TextStyle(
                          color: Color(0xFF78350F),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Store & Customer Points
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFE0F2FE),
                          child: Icon(Icons.storefront_rounded, size: 16, color: Colors.blue),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('المتجر', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text(
                                businessName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (businessPhone.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.phone_rounded, color: Colors.blue, size: 18),
                            onPressed: () => _launchCaller(businessPhone),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFDCFCE7),
                          child: Icon(Icons.person_pin_circle_rounded, size: 16, color: Colors.green),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('العميل', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text(
                                customerAddressText,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (customerPhone.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.phone_rounded, color: Colors.green, size: 18),
                            onPressed: () => _launchCaller(customerPhone),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    icon: const Icon(Icons.visibility_rounded, size: 16),
                    label: const Text('تفاصيل الشحنة'),
                    onPressed: () => changeScreen(context, DeliveryOrderDetailsPage(order: order)),
                  ),
                ),
                const SizedBox(width: 10),
                if (isPendingPickup) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      icon: const Icon(Icons.inventory_2_rounded, size: 16),
                      label: const Text('استلام الطرد'),
                      onPressed: () => _quickUpdateStatus(context, order, OrderStatus.shipped),
                    ),
                  ),
                ] else if (isInTransit) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: const Text('تأكيد التسليم'),
                      onPressed: () => _quickUpdateStatus(context, order, OrderStatus.delivered),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
      case OrderStatus.ready:
        return Colors.orange;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
      case OrderStatus.ready:
        return Icons.storefront_rounded;
      case OrderStatus.shipped:
        return Icons.directions_bike_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return 'مؤكد (بانتظار التجهيز)';
      case OrderStatus.preparing:
        return 'جاري التجهيز في المتجر';
      case OrderStatus.ready:
        return 'جاهز للاستلام الفوري ⚡';
      case OrderStatus.shipped:
        return 'تم الاستلام - في الطريق للعميل 🚀';
      case OrderStatus.delivered:
        return 'تم التسليم بنجاح ✅';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }
}
