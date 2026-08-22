import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class StoreOwnerSidebarItem {
  final String titleKey;
  final IconData icon;

  const StoreOwnerSidebarItem({
    required this.titleKey,
    required this.icon,
  });
}

class StoreOwnerSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  final List<StoreOwnerSidebarItem> items;

  const StoreOwnerSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final businessProvider = Provider.of<BusinessProvider>(context);
    final storeTheme = businessProvider.selectedBusiness.theme;
    final primaryColor = storeTheme.primaryColorValue;
    final fontFamily = storeTheme.fontFamily;
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
                          ? primaryColor.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: storeTheme.buttonBorderRadius,
                      border: isSelected
                          ? Border.all(
                              color: primaryColor.withOpacity(0.3),
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
                              ? primaryColor
                              : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                        if (!isCollapsed) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.titleKey.tr(context),
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? primaryColor
                                    : theme.textTheme.bodyLarge?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
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
