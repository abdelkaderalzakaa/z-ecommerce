import 'package:flutter/material.dart';
import '../../global/core/constants/app_constants.dart';
import 'filter_sidebar.dart';

void showFilterModal(BuildContext context, {String? categoryLabel, String? brandName}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
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
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: FilterSidebar(isMobile: true, categoryLabel: categoryLabel, brandName: brandName),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
