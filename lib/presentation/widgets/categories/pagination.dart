import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../../data/providers/product_provider.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class Pagination extends StatelessWidget {
  final String? categoryLabel;
  final String? brandName;
  final bool onSale;
  const Pagination({super.key, this.categoryLabel, this.brandName, this.onSale = false});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final totalPages = provider.getTotalPages(categoryLabel, brand: brandName, onSale: onSale);
        final currentPage = provider.currentPage;

        if (totalPages <= 1) return const SizedBox.shrink(); // hide if only 1 page

        return Column(
          children: [
            Divider(color: Theme.of(context).dividerColor, height: 1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavButton(
                  label: TranslationKeys.previous.tr(context),
                  icon: Icons.arrow_back,
                  isMobile: isMobile,
                  isLeft: true,
                  onTap: currentPage > 1 ? () => provider.setPage(currentPage - 1, categoryLabel, brand: brandName, onSale: onSale) : null,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildPageNumbers(context, provider, totalPages, currentPage, isMobile),
                ),
                _NavButton(
                  label: TranslationKeys.next.tr(context),
                  icon: Icons.arrow_forward,
                  isMobile: isMobile,
                  isLeft: false,
                  onTap: currentPage < totalPages ? () => provider.setPage(currentPage + 1, categoryLabel, brand: brandName, onSale: onSale) : null,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context, ProductProvider provider, int totalPages, int currentPage, bool isMobile) {
    List<Widget> widgets = [];
    
    if (totalPages <= 5 || isMobile) {
       int start = 1;
       int end = totalPages > 5 && isMobile ? 5 : totalPages;
       for (int i = start; i <= end; i++) {
         widgets.add(_PageNumber(
           label: i.toString(),
           isActive: i == currentPage,
           isMobile: isMobile,
           onTap: () => provider.setPage(i, categoryLabel, brand: brandName, onSale: onSale),
         ));
       }
    } else {
       widgets.add(_PageNumber(label: '1', isActive: 1 == currentPage, isMobile: isMobile, onTap: () => provider.setPage(1, categoryLabel, brand: brandName, onSale: onSale)));
       widgets.add(_PageNumber(label: '2', isActive: 2 == currentPage, isMobile: isMobile, onTap: () => provider.setPage(2, categoryLabel, brand: brandName, onSale: onSale)));
       widgets.add(_PageNumber(label: '3', isActive: 3 == currentPage, isMobile: isMobile, onTap: () => provider.setPage(3, categoryLabel, brand: brandName, onSale: onSale)));
       
       if (totalPages > 6) {
         widgets.add(_PageNumber(label: '...', isMobile: isMobile));
       }
       
       if (totalPages > 4) {
         widgets.add(_PageNumber(label: (totalPages - 2).toString(), isActive: (totalPages - 2) == currentPage, isMobile: isMobile, onTap: () => provider.setPage(totalPages - 2, categoryLabel, brand: brandName, onSale: onSale)));
       }
       
       if (totalPages > 3) {
         widgets.add(_PageNumber(label: (totalPages - 1).toString(), isActive: (totalPages - 1) == currentPage, isMobile: isMobile, onTap: () => provider.setPage(totalPages - 1, categoryLabel, brand: brandName, onSale: onSale)));
       }
       
       widgets.add(_PageNumber(label: totalPages.toString(), isActive: totalPages == currentPage, isMobile: isMobile, onTap: () => provider.setPage(totalPages, categoryLabel, brand: brandName, onSale: onSale)));
    }
    
    return widgets;
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isMobile;
  final bool isLeft;
  final VoidCallback? onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.isMobile,
    required this.isLeft,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(AppRadius.button),
          color: onTap == null ? Theme.of(context).cardColor : null, // dim if disabled
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLeft) ...[
              Icon(icon, size: 16, color: onTap == null ? Theme.of(context).textTheme.bodyMedium?.color : Theme.of(context).textTheme.bodyLarge?.color),
              if (!isMobile) const SizedBox(width: 8),
            ],
            if (!isMobile)
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: onTap == null ? Theme.of(context).textTheme.bodyMedium?.color : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            if (!isLeft) ...[
              if (!isMobile) const SizedBox(width: 8),
              Icon(icon, size: 16, color: onTap == null ? Theme.of(context).textTheme.bodyMedium?.color : Theme.of(context).textTheme.bodyLarge?.color),
            ],
          ],
        ),
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isMobile;
  final VoidCallback? onTap;

  const _PageNumber({
    required this.label,
    this.isActive = false,
    required this.isMobile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDots = label == '...';

    return GestureDetector(
      onTap: isDots ? null : onTap,
      child: Container(
        width: isMobile ? 32 : 40,
        height: isMobile ? 32 : 40,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        decoration: isActive
            ? BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isDots ? Theme.of(context).textTheme.bodyLarge?.color : (isActive ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
      ),
    );
  }
}
