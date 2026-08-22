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
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_section.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';
import 'package:z_ecommerce/presentation/widgets/profile/tabs/widgets/address_form_dialog.dart';

class CustomerAddressesPage extends StatefulWidget {
  const CustomerAddressesPage({super.key});

  @override
  State<CustomerAddressesPage> createState() => _CustomerAddressesPageState();
}

class _CustomerAddressesPageState extends State<CustomerAddressesPage> {
  String _selectedFilterTag = 'all';

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final langCode = isAr ? 'ar' : 'en';

    final customer = context.watch<AuthProvider>().currentCustomer;
    final allAddresses = customer?.addresses ?? [];

    final filteredAddresses = allAddresses.where((address) {
      if (_selectedFilterTag == 'all') return true;
      final titleLower = address.title.toLowerCase();
      if (_selectedFilterTag == 'home') {
        return titleLower.contains('home') || titleLower.contains('بيت') || titleLower.contains('منزل');
      }
      if (_selectedFilterTag == 'work') {
        return titleLower.contains('work') || titleLower.contains('عمل') || titleLower.contains('مكتب');
      }
      if (_selectedFilterTag == 'other') {
        return titleLower.contains('other') || titleLower.contains('أخرى') || titleLower.contains('اخرى');
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: isAr ? 'عناوين التوصيل والمواقع' : 'Delivery Addresses & Locations',
        paths: [TranslationKeys.addresses.tr(context)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: isMobile ? 20 : 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Hero Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'عناويني المحفوظة' : 'My Saved Addresses',
                            style: TextStyle(
                              fontSize: isMobile ? 22 : 28,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAr
                                ? 'إدارة وتخصيص عناوين الاستلام والتوصيل الخاصة بك (البيت، العمل، أخرى)'
                                : 'Manage and customize your delivery addresses (Home, Work, Other)',
                            style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                      ButtonApp(
                        label: isAr ? 'إضافة عنوان جديد' : 'Add Address',
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
                  const SizedBox(height: 24),

                  // Filter Chips Bar
                  Row(
                    children: [
                      _buildTagFilterChip('all', isAr ? 'جميع العناوين' : 'All Addresses', allAddresses.length, theme),
                      const SizedBox(width: 8),
                      _buildTagFilterChip(
                        'home',
                        isAr ? 'البيت' : 'Home',
                        allAddresses.where((a) {
                          final t = a.title.toLowerCase();
                          return t.contains('home') || t.contains('بيت') || t.contains('منزل');
                        }).length,
                        theme,
                      ),
                      const SizedBox(width: 8),
                      _buildTagFilterChip(
                        'work',
                        isAr ? 'العمل' : 'Work',
                        allAddresses.where((a) {
                          final t = a.title.toLowerCase();
                          return t.contains('work') || t.contains('عمل') || t.contains('مكتب');
                        }).length,
                        theme,
                      ),
                      const SizedBox(width: 8),
                      _buildTagFilterChip(
                        'other',
                        isAr ? 'أخرى' : 'Other',
                        allAddresses.where((a) {
                          final t = a.title.toLowerCase();
                          return t.contains('other') || t.contains('أخرى') || t.contains('اخرى');
                        }).length,
                        theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Content Body: Grid of Addresses or Empty State
                  if (filteredAddresses.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 64,
                            color: theme.primaryColor.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isAr ? 'لا توجد عناوين أضيفت بعد' : 'No Addresses Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isAr
                                ? 'قم بإضافة عنوان منزل أو عمل لتسريع استلام طلباتك.'
                                : 'Add your home or office address to receive orders faster.',
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
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: isMobile ? 1.45 : 1.6,
                      ),
                      itemCount: filteredAddresses.length,
                      itemBuilder: (context, index) {
                        return _AddressPageCard(
                          address: filteredAddresses[index],
                          langCode: langCode,
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTagFilterChip(String filterKey, String label, int count, ThemeData theme) {
    final isSelected = _selectedFilterTag == filterKey;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.25) : theme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : theme.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      selectedColor: theme.primaryColor,
      backgroundColor: theme.cardColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? theme.primaryColor : AppColors.cardBorder,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilterTag = filterKey);
        }
      },
    );
  }
}

class _AddressPageCard extends StatelessWidget {
  final AddressModel address;
  final String langCode;

  const _AddressPageCard({
    required this.address,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = langCode == 'ar';

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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Icon, Title & Default Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(addressIcon, color: theme.primaryColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.title.isNotEmpty ? address.title : addressTagLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isAr ? 'الافتراضي للتوصيل' : 'Default Address',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 20),

          // Address Details
          Text(
            formattedAddress.isNotEmpty ? formattedAddress : address.street,
            style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Action Buttons: Set Default, Edit, Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!address.isDefault)
                TextButton.icon(
                  onPressed: () async {
                    final customerProvider = context.read<CustomerProvider>();
                    final authProvider = context.read<AuthProvider>();
                    final currentCustomer = authProvider.currentCustomer;
                    if (currentCustomer != null) {
                      final updatedList = currentCustomer.addresses.map((a) {
                        return AddressModel(
                          id: a.id,
                          title: a.title,
                          country: a.country,
                          city: a.city,
                          region: a.region,
                          street: a.street,
                          building: a.building,
                          details: a.details,
                          postalCode: a.postalCode,
                          latitude: a.latitude,
                          longitude: a.longitude,
                          isDefault: a.id == address.id,
                        );
                      }).toList();
                      await customerProvider.updateAddresses(currentCustomer.id, updatedList);
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text(isAr ? 'جعله افتراضي' : 'Set Default', style: const TextStyle(fontSize: 12)),
                )
              else
                const SizedBox.shrink(),

              Row(
                children: [
                  IconButton(
                    tooltip: isAr ? 'تعديل' : 'Edit',
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddressFormDialog(initialAddress: address),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: isAr ? 'حذف' : 'Delete',
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
        ],
      ),
    );
  }
}
