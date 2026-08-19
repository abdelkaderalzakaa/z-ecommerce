import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/order_details_page.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<OrderProvider>().listenToCustomerOrders(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = theme.brightness == Brightness.dark;

    final orderProvider = context.watch<OrderProvider>();
    final allOrders = orderProvider.customerOrders;

    // Filter orders based on status chip selection
    final filteredOrders = allOrders.where((order) {
      if (_selectedStatusFilter == 'all') return true;
      if (_selectedStatusFilter == 'pending') {
        return order.status == OrderStatus.pending;
      }
      if (_selectedStatusFilter == 'processing') {
        return order.status == OrderStatus.preparing || order.status == OrderStatus.confirmed;
      }
      if (_selectedStatusFilter == 'shipped') {
        return order.status == OrderStatus.shipped || order.status == OrderStatus.ready;
      }
      if (_selectedStatusFilter == 'completed') {
        return order.status == OrderStatus.delivered;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.orderHistory.tr(context),
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isAr
              ? 'تتبع واستعرض كافة طلبياتك ومراحل تجهيزها وتوصيلها'
              : 'Track and view all your order history and delivery statuses',
          style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Categorized Order Status Chips Bar
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip('all', isAr ? 'الكل' : 'All', allOrders.length, theme, isDark),
              _buildFilterChip(
                'pending',
                isAr ? 'الطلبية الحالية' : 'Current Orders',
                allOrders.where((o) => o.status == OrderStatus.pending).length,
                theme,
                isDark,
              ),
              _buildFilterChip(
                'processing',
                isAr ? 'قيد التجهيز' : 'In Preparation',
                allOrders
                    .where((o) => o.status == OrderStatus.preparing || o.status == OrderStatus.confirmed)
                    .length,
                theme,
                isDark,
              ),
              _buildFilterChip(
                'shipped',
                isAr ? 'استلمها الديليفري' : 'On Delivery',
                allOrders.where((o) => o.status == OrderStatus.shipped || o.status == OrderStatus.ready).length,
                theme,
                isDark,
              ),
              _buildFilterChip(
                'completed',
                isAr ? 'مكتملة' : 'Completed',
                allOrders.where((o) => o.status == OrderStatus.delivered).length,
                theme,
                isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (filteredOrders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: theme.primaryColor.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  TranslationKeys.noOrdersYet.tr(context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAr ? 'لا توجد طلبات تطابق هذه التصفية حالياً.' : 'No orders match this status criteria.',
                  style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredOrders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _OrderItem(order: filteredOrders[index], isMobile: isMobile);
            },
          ),
      ],
    );
  }

  Widget _buildFilterChip(
    String filterKey,
    String label,
    int count,
    ThemeData theme,
    bool isDark,
  ) {
    final isSelected = _selectedStatusFilter == filterKey;

    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.25) : theme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : theme.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        selected: isSelected,
        selectedColor: theme.primaryColor,
        backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? theme.primaryColor : AppColors.cardBorder,
          ),
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedStatusFilter = filterKey);
          }
        },
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final OrderModel order;
  final bool isMobile;

  const _OrderItem({
    required this.order,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;
    final currency = selectedBusiness.currency.symbol;
    final dateStr = DateFormat('yyyy/MM/dd - hh:mm a').format(order.createdAt);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "#${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "الطلبية للمتجر",
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              Text(
                "${order.storeTotal.toStringAsFixed(2)} $currency",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ButtonApp(
              format: FormatButtonApp.outline,
              label: 'تفاصيل الطلبية',
              icon: Icons.receipt_outlined,
              fontSize: 12,
              onPressed: () {
                changeScreen(context, OrderDetailsPage(order: order));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case OrderStatus.pending:
        bg = Colors.amber.withOpacity(0.15);
        fg = Colors.amber.shade900;
        label = 'الطلبية الحالية / قيد الانتظار';
        break;
      case OrderStatus.preparing:
      case OrderStatus.confirmed:
        bg = Colors.blue.withOpacity(0.15);
        fg = Colors.blue.shade900;
        label = 'قيد التجهيز';
        break;
      case OrderStatus.ready:
      case OrderStatus.shipped:
        bg = Colors.purple.withOpacity(0.15);
        fg = Colors.purple.shade900;
        label = 'استلمها الديليفري';
        break;
      case OrderStatus.delivered:
        bg = AppColors.green.withOpacity(0.15);
        fg = AppColors.green;
        label = 'مكتملة';
        break;
      case OrderStatus.cancelled:
        bg = Colors.red.withOpacity(0.15);
        fg = Colors.red.shade900;
        label = 'ملغاة';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
