import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/customer_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/profile/tabs/widgets/address_form_dialog.dart';

class AddressesTab extends StatelessWidget {
  const AddressesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final customer = context.watch<AuthProvider>().currentCustomer;
    final addresses = customer?.addresses ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationKeys.addresses.tr(context),
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAr
                      ? 'العناوين المحفوظة الخاصة بك (البيت، العمل، أخرى)'
                      : 'Your saved personal addresses (Home, Work, Other)',
                  style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
                ),
              ],
            ),
            ButtonApp(
              label: isAr ? 'إضافة عنوان جديد' : 'Add New Address',
              icon: Icons.add_location_alt_outlined,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddressFormDialog(),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 28),

        if (addresses.isEmpty)
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
                  Icons.location_on_outlined,
                  size: 64,
                  color: theme.primaryColor.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  TranslationKeys.noAddressesFound.tr(context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAr ? 'أضف عنوان المنزل أو العمل لتسهيل واستلام طلباتك.' : 'Add your home or work address for faster delivery.',
                  style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
                ),
                const SizedBox(height: 20),
                ButtonApp(
                  label: isAr ? 'إضافة عنوان الآن' : 'Add Address Now',
                  icon: Icons.add,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddressFormDialog(),
                    );
                  },
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: addresses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _AddressCardItem(address: addresses[index]);
            },
          ),
      ],
    );
  }
}

class _AddressCardItem extends StatelessWidget {
  final AddressModel address;

  const _AddressCardItem({required this.address});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final langCode = isAr ? 'ar' : 'en';

    IconData addressIcon = Icons.home_outlined;
    String addressTagLabel = isAr ? 'البيت' : 'Home';

    final titleLower = address.title.toLowerCase();
    if (titleLower.contains('work') || titleLower.contains('عمل') || titleLower.contains('مكتب')) {
      addressIcon = Icons.work_outline;
      addressTagLabel = isAr ? 'العمل' : 'Work';
    } else if (titleLower.contains('other') || titleLower.contains('أخرى') || titleLower.contains('اخرى')) {
      addressIcon = Icons.location_city_outlined;
      addressTagLabel = isAr ? 'أخرى' : 'Other';
    }

    final formattedAddress = address.getFormattedAddress(langCode: langCode);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isDefault ? theme.primaryColor : AppColors.cardBorder,
          width: address.isDefault ? 1.5 : 1,
        ),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(addressIcon, color: theme.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    address.title.isNotEmpty ? address.title : addressTagLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (address.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isAr ? 'الافتراضي' : 'Default',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Edit & Delete Actions
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddressFormDialog(initialAddress: address),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    onPressed: () async {
                      final customerProvider = context.read<CustomerProvider>();
                      final authProvider = context.read<AuthProvider>();
                      final currentCustomer = authProvider.currentCustomer;
                      if (currentCustomer != null) {
                        final updatedList = currentCustomer.addresses.where((a) => a.id != address.id).toList();
                        await customerProvider.updateAddresses(currentCustomer.id, updatedList);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            formattedAddress.isNotEmpty ? formattedAddress : address.street,
            style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
