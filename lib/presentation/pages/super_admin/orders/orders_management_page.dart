import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/data/services/logistics_analytics_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/orders/order_details_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/common/status_dialogs.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/orders/super_admin_logistics_radar_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/orders/super_admin_bottlenecks_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/orders/super_admin_response_analytics_page.dart';

class OrdersManagementPage extends StatefulWidget {
  const OrdersManagementPage({super.key});

  @override
  State<OrdersManagementPage> createState() => _OrdersManagementPageState();
}

class _OrdersManagementPageState extends State<OrdersManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().listenToAllOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderProvider = context.watch<OrderProvider>();
    final allOrders = orderProvider.allOrders;

    final bottlenecks = LogisticsAnalyticsService.detectBottlenecks(allOrders);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.hub_rounded, color: theme.primaryColor, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'مركز العمليات واللوجستيات الذكي (Logistics & Operations Hub)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
            const Tab(
              child: Row(
                children: [
                  Icon(Icons.radar_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('رادار المسارات الحية 🛰️', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18),
                  const SizedBox(width: 6),
                  const Text('غرفة كشف التأخير والتدخل 🚨', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (bottlenecks.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${bottlenecks.length}',
                        style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(
              child: Row(
                children: [
                  Icon(Icons.analytics_outlined, size: 18),
                  SizedBox(width: 6),
                  Text('تحليلات الاستجابة وSLA 📊', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Tab(
              child: Row(
                children: [
                  Icon(Icons.table_chart_outlined, size: 18),
                  SizedBox(width: 6),
                  Text('جدول كافة الطلبيات 📋', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const SuperAdminLogisticsRadarPage(),
          const SuperAdminBottlenecksPage(),
          const SuperAdminResponseAnalyticsPage(),
          _buildOrdersTableView(context, allOrders),
        ],
      ),
    );
  }

  Widget _buildOrdersTableView(BuildContext context, List<OrderModel> allOrders) {
    final filteredOrders = allOrders.where((order) {
      final matchesStatus =
          _selectedStatusFilter == 'all' ||
          order.status.name.toLowerCase() == _selectedStatusFilter.toLowerCase();
      return matchesStatus;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: AppDataTable<OrderModel>(
        items: filteredOrders,
        selectable: true,
        showIndexColumn: true,
        onBulkDelete: (selected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${TranslationKeys.deleteSelected.tr(context)} (${selected.length})',
              ),
              backgroundColor: Colors.red,
            ),
          );
        },
        searchMatcher: (order, q) =>
            order.id.toLowerCase().contains(q) ||
            order.businessId.toLowerCase().contains(q) ||
            (order.deliveryDriverName?.toLowerCase().contains(q) ?? false),
        onFilterTap: () => _showFilterDialog(context),
        emptyMessage: TranslationKeys.noDataAvailable.tr(context),
        onRowTap: (order) => changeScreen(
          context,
          OrderDetailsPage(orderId: order.id),
        ),
        columns: [
          AppTableColumn<OrderModel>(
            title: TranslationKeys.orderId.tr(context),
            flex: 1,
            sortable: true,
            sortKey: (order) => order.id,
            cellBuilder: (order) => TableTextCell(
              title: '#${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',
              isBold: true,
            ),
          ),
          AppTableColumn<OrderModel>(
            title: TranslationKeys.store.tr(context),
            flex: 1,
            sortable: true,
            sortKey: (order) => order.businessId,
            cellBuilder: (order) => TableImageTextCell(
              title: '${TranslationKeys.store.tr(context)} ${order.businessId}',
              fallbackIcon: Icons.storefront_rounded,
            ),
          ),
          AppTableColumn<OrderModel>(
            title: 'المندوب',
            flex: 1,
            cellBuilder: (order) => TableTextCell(
              title: order.deliveryDriverName ?? 'غير مسند',
              subtitle: order.deliveryDriverPhone ?? '',
            ),
          ),
          AppTableColumn<OrderModel>(
            title: TranslationKeys.total.tr(context),
            flex: 1,
            sortable: true,
            sortKey: (order) => order.storeTotal,
            cellBuilder: (order) => TableTextCell(
              title: '${order.storeTotal.toStringAsFixed(2)} ر.س',
              isBold: true,
            ),
          ),
          AppTableColumn<OrderModel>(
            title: 'الحالة',
            flex: 1,
            cellBuilder: (order) => TableStatusBadge.fromStatus(order.status.name),
          ),
          AppTableColumn<OrderModel>(
            title: TranslationKeys.actions.tr(context),
            flex: 1,
            cellBuilder: (order) => TablePopupMenuActions(
              onView: () => changeScreen(
                context,
                OrderDetailsPage(orderId: order.id),
              ),
              onEdit: () {
                _showChangeStatusDialog(context, order);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('تغيير حالة الطلب'),
          children: OrderStatus.values.map((status) {
            return SimpleDialogOption(
              onPressed: () async {
                await context.read<OrderProvider>().updateOrderStatus(order.id, status);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(status.name, style: const TextStyle(fontSize: 14)),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationKeys.filter.tr(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('all', 'الكل'),
            _buildFilterOption(OrderStatus.pending.name, 'قيد الانتظار'),
            _buildFilterOption(OrderStatus.preparing.name, 'قيد التجهيز'),
            _buildFilterOption(OrderStatus.ready.name, 'جاهز للاستلام'),
            _buildFilterOption(OrderStatus.shipped.name, 'في مسار التوصيل'),
            _buildFilterOption(OrderStatus.delivered.name, 'تم التسليم'),
            _buildFilterOption(OrderStatus.cancelled.name, 'ملغي'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _selectedStatusFilter,
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _selectedStatusFilter = val;
          });
          Navigator.pop(context);
        }
      },
    );
  }
}
