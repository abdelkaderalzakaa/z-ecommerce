import 'package:flutter/material.dart';
import 'filter_sidebar.dart';

void showFilterModal(BuildContext context, {String? categoryLabel, String? brandName}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 24),
                  child: FilterSidebar(
                    categoryLabel: categoryLabel,
                    brandName: brandName,
                    onApply: () => Navigator.pop(modalContext),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
