import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class ProfileSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelectTab;
  final List<String> tabs;

  const ProfileSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelectTab,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              TranslationKeys.menu.tr(context),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(tabs.length, (index) {
            final isSelected = selectedIndex == index;
            return _SidebarItem(
              title: tabs[index],
              isSelected: isSelected,
              onTap: () => onSelectTab(index),
            );
          }),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color getTextColor() {
      if (widget.title == TranslationKeys.logout) return Colors.red;
      if (widget.isSelected) return Theme.of(context).primaryColor;
      if (_hovered) return Theme.of(context).primaryColor;
      return Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: widget.isSelected ? Theme.of(context).colorScheme.surfaceContainerHighest : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: widget.isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Text(
            widget.title.tr(context),
            style: TextStyle(
              fontSize: 16,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              color: getTextColor(),
            ),
          ),
        ),
      ),
    );
  }
}
