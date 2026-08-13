import 'package:flutter/material.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class SuperAdminSidebarItem {
  final String titleKey;
  final IconData icon;
  final String? badge;

  const SuperAdminSidebarItem({
    required this.titleKey,
    required this.icon,
    this.badge,
  });
}

class SuperAdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  static const List<SuperAdminSidebarItem> items = [
    SuperAdminSidebarItem(
      titleKey: TranslationKeys.superAdminDashboard,
      icon: Icons.dashboard_rounded,
    ),
    SuperAdminSidebarItem(
      titleKey: TranslationKeys.storesManagement,
      icon: Icons.store_rounded,
    ),
    SuperAdminSidebarItem(
      titleKey: TranslationKeys.ordersManagement,
      icon: Icons.shopping_cart_rounded,
    ),
    SuperAdminSidebarItem(
      titleKey: TranslationKeys.usersManagement,
      icon: Icons.people_alt_rounded,
    ),
    SuperAdminSidebarItem(
      titleKey: TranslationKeys.offersManagement,
      icon: Icons.local_offer_rounded,
    ),
    SuperAdminSidebarItem(
      titleKey: TranslationKeys.categoriesManagement,
      icon: Icons.category_rounded,
    ),

    SuperAdminSidebarItem(
      titleKey: TranslationKeys.settingsTab,
      icon: Icons.settings_rounded,
    ),
  ];

  const SuperAdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = isCollapsed ? 70.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      clipBehavior: Clip.hardEdge,
      width: width,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          left: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
          right: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Sidebar Navigation Items List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedIndex == index;

                return InkWell(
                  onTap: () => onItemSelected(index),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    clipBehavior: Clip.hardEdge,
                    padding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 8 : 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: theme.primaryColor.withOpacity(0.3),
                              width: 1,
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
                                : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          if (!isCollapsed) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.titleKey.tr(context),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? theme.primaryColor
                                      : theme.textTheme.bodyLarge?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ),
                            if (item.badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item.badge!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
          const SizedBox(height: 8),

          // Footer Info & Collapse Toggle Button
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              TranslationKeys.statusActive.tr(context),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'v1.0.0',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
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
                          isCollapsed ? Icons.chevron_right : Icons.chevron_left,
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
