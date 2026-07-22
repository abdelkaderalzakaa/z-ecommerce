import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class ProfileTabsMobile extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelectTab;
  final List<String> tabs;

  const ProfileTabsMobile({
    super.key,
    required this.selectedIndex,
    required this.onSelectTab,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 12),
            child: _TabChip(
              title: tabs[index],
              isSelected: isSelected,
              onTap: () => onSelectTab(index),
            ),
          );
        }),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getTextColor() {
      if (title == TranslationKeys.logout.tr(context)) return Colors.red;
      if (isSelected) return Colors.white;
      return Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    }

    Color getBgColor() {
      if (isSelected) return Theme.of(context).primaryColor;
      return Theme.of(context).cardColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: getBgColor(),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          title, // title is already translated by the parent
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: getTextColor(),
          ),
        ),
      ),
    );
  }
}
