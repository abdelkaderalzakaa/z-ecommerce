import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import '../../../../data/providers/customer_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/models/common/address_model.dart';
import '../../../widgets/profile/tabs/widgets/address_form_dialog.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class AddressesTab extends StatelessWidget {
  const AddressesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
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
                  TranslationKeys.savedAddresses.tr(context),
                  style: AppTextStyles.heroTitle(context, isMobile).copyWith(
                    fontSize: 24,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  TranslationKeys.manageShippingAndBilling.tr(context),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ],
            ),
            if (!isMobile) _AddNewButton(),
          ],
        ),
        const SizedBox(height: 32),
        if (isMobile) ...[
          SizedBox(width: double.infinity, child: _AddNewButton()),
          const SizedBox(height: 32),
        ],
        addresses.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      TranslationKeys.noAddressesFound.tr(context),
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      TranslationKeys.addNewAddressPrompt.tr(context),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              )
            : isMobile
            ? ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: addresses.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    _AddressCard(address: addresses[index]),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.5,
                ),
                itemCount: addresses.length,
                itemBuilder: (context, index) =>
                    _AddressCard(address: addresses[index]),
              ),
      ],
    );
  }
}

class _AddNewButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ButtonApp(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const AddressFormDialog(),
        );
      },
      label: TranslationKeys.addNew.tr(context),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;

  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  address.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Row(
                children: [
                  ButtonApp(
                    format: FormatButtonApp.icon,
                    icon: Icons.edit_outlined,
                    label: 'تعديل',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AddressFormDialog(initialAddress: address),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  ButtonApp(
                    format: FormatButtonApp.icon,
                    icon: Icons.delete_outline,
                    color: Colors.red,
                    label: 'حذف',
                    onPressed: () {
                      final customer = context
                          .read<AuthProvider>()
                          .currentCustomer;
                      if (customer != null) {
                        final updated = customer.addresses
                            .where((a) => a.id != address.id)
                            .toList();
                        context.read<CustomerProvider>().updateAddresses(
                          customer.id,
                          updated,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            address.street,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${address.city.get(context)}, ${address.region.get(context)} ${address.postalCode ?? ''}',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.country.get(context),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
