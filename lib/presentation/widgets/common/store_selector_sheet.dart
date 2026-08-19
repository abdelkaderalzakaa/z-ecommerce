import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class StoreSelectorSheet extends StatelessWidget {
  const StoreSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final businessProvider = context.watch<BusinessProvider>();
    final businesses = businessProvider.businesses;
    final currentStoreId = businessProvider.selectedBusiness.id;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              TranslationKeys.selectStore.tr(context),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          ...businesses.map((store) {
            final isSelected = store.id == currentStoreId;
            return ListTile(
              onTap: () {
                if (!isSelected) {
                  businessProvider.selectBusiness(store.id);
                }
                Navigator.pop(context);
              },
              leading: CircleAvatar(
                backgroundColor: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Icon(Icons.store, color: Theme.of(context).iconTheme.color, size: 20),
              ),
              title: Text(
                store.localization.name.get(context),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              subtitle: Text(store.id),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : null,
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
