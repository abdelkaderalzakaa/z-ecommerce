import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';

class DeliverySidebarItem {
  final String titleAr;
  final String titleEn;
  final IconData icon;
  final String? Function(DeliveryProvider)? badgeBuilder;

  const DeliverySidebarItem({
    required this.titleAr,
    required this.titleEn,
    required this.icon,
    this.badgeBuilder,
  });
}

class DeliveryPortalSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const DeliveryPortalSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  static List<DeliverySidebarItem> getItems(bool isCompany) {
    return [
      const DeliverySidebarItem(
        titleAr: 'لوحة التحكم والرادار',
        titleEn: 'Dashboard Overview',
        icon: Icons.dashboard_rounded,
      ),
      DeliverySidebarItem(
        titleAr: 'الطلبات والمهام',
        titleEn: 'Orders & Missions',
        icon: Icons.inventory_2_rounded,
        badgeBuilder: (provider) {
          final count = provider.pendingPickupOrders.length + provider.inTransitOrders.length;
          return count > 0 ? '$count' : null;
        },
      ),
      if (isCompany)
        DeliverySidebarItem(
          titleAr: 'أسطول الكباتن',
          titleEn: 'Fleet & Drivers',
          icon: Icons.groups_rounded,
          badgeBuilder: (provider) {
            final driverCount = provider.currentDelivery.drivers.length;
            return driverCount > 0 ? '$driverCount' : null;
          },
        ),
      const DeliverySidebarItem(
        titleAr: 'المحفظة والأرباح',
        titleEn: 'Wallet & Earnings',
        icon: Icons.account_balance_wallet_rounded,
      ),
      const DeliverySidebarItem(
        titleAr: 'إعدادات ومناطق التغطية',
        titleEn: 'Delivery Settings',
        icon: Icons.tune_rounded,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final isAr = localeProvider.locale.languageCode == 'ar';
    final deliveryProvider = context.watch<DeliveryProvider>();
    final delivery = deliveryProvider.currentDelivery;
    final isCompany = delivery.type == DeliveryEntityType.company;

    final items = getItems(isCompany);
    final width = isCollapsed ? 72.0 : 250.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      clipBehavior: Clip.hardEdge,
      width: width,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          left: isAr ? BorderSide.none : BorderSide(color: theme.dividerColor.withOpacity(0.12)),
          right: isAr ? BorderSide(color: theme.dividerColor.withOpacity(0.12)) : BorderSide.none,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Quick Entity Profile Header inside expanded sidebar
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.primaryColor.withOpacity(0.18)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.primaryColor,
                      child: Icon(
                        isCompany ? Icons.local_shipping_rounded : Icons.two_wheeler_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            delivery.name.isNotEmpty
                                ? delivery.name
                                : (isAr ? 'كابتن التوصيل' : 'Delivery Captain'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: delivery.isOnline ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                delivery.isOnline
                                    ? (isAr ? 'متاح للطلبات' : 'Available')
                                    : (isAr ? 'غير متاح حالياً' : 'Offline'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: delivery.isOnline ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 4),

          // Sidebar Navigation Items List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedIndex == index;
                final badgeText = item.badgeBuilder?.call(deliveryProvider);

                return InkWell(
                  onTap: () => onItemSelected(index),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    clipBehavior: Clip.hardEdge,
                    padding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 10 : 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: theme.primaryColor.withOpacity(0.35),
                              width: 1.2,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: isCollapsed
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: isSelected
                              ? theme.primaryColor
                              : theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                        ),
                        if (!isCollapsed) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isAr ? item.titleAr : item.titleEn,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? theme.primaryColor
                                    : theme.textTheme.bodyLarge?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? theme.primaryColor : Colors.amber.shade700,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                badgeText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer Info & Collapse Toggle Button
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (!isCollapsed)
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: delivery.isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isAr ? 'نظام التوصيل الفوري' : 'Delivery Dispatch',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (onToggleCollapse != null)
                  InkWell(
                    onTap: onToggleCollapse,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isCollapsed
                            ? (isAr ? Icons.chevron_left : Icons.chevron_right)
                            : (isAr ? Icons.chevron_right : Icons.chevron_left),
                        color: theme.textTheme.bodySmall?.color,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
