import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/services/address_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/add_edit_address.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_section.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/top_title.dart';

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

    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? authProvider.currentCustomer?.id ?? '';
    final addressService = AddressService();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: isAr
            ? 'عناوين التوصيل والمواقع'
            : 'Delivery Addresses & Locations',
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TopTitle(
              title: isAr
                  ? 'عناوين التوصيل والمواقع'
                  : 'Delivery Addresses & Locations',
              paths: [TranslationKeys.addresses.tr(context)],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: hPad),
              child: StreamBuilder<List<AddressModel>>(
                stream: addressService.streamAddressesByUserId(currentUserId),
                builder: (context, snapshot) {
                  final allAddresses = snapshot.data ?? [];
                  final isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;

                  final filteredAddresses = allAddresses.where((address) {
                    if (_selectedFilterTag == 'all') return true;
                    if (_selectedFilterTag == 'home') return address.type == AddressType.home;
                    if (_selectedFilterTag == 'work') return address.type == AddressType.office;
                    if (_selectedFilterTag == 'main') return address.type == AddressType.main;
                    if (_selectedFilterTag == 'other') return address.type == AddressType.other;
                    return true;
                  }).toList();

                  return Column(
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
                                    ? 'إدارة وتخصيص عناوين الاستلام والتوصيل الخاصة بك'
                                    : 'Manage and customize your delivery addresses',
                                style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
                              ),
                            ],
                          ),
                          ButtonApp(
                            label: isAr ? 'إضافة عنوان جديد' : 'Add Address',
                            icon: Icons.add_location_alt_outlined,
                            onPressed: () {
                              changeScreen(
                                context,
                                AddEditAddress(
                                  userId: currentUserId,
                                  userType: 'customer',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Filter Chips Bar
                      Row(
                        children: [
                          _buildTagFilterChip(
                            'all',
                            isAr ? 'جميع العناوين' : 'All Addresses',
                            allAddresses.length,
                            theme,
                          ),
                          const SizedBox(width: 8),
                          _buildTagFilterChip(
                            'home',
                            isAr ? 'المنزل' : 'Home',
                            allAddresses.where((a) => a.type == AddressType.home).length,
                            theme,
                          ),
                          const SizedBox(width: 8),
                          _buildTagFilterChip(
                            'work',
                            isAr ? 'العمل' : 'Work',
                            allAddresses.where((a) => a.type == AddressType.office).length,
                            theme,
                          ),
                          const SizedBox(width: 8),
                          _buildTagFilterChip(
                            'other',
                            isAr ? 'أخرى' : 'Other',
                            allAddresses.where((a) => a.type == AddressType.other || a.type == AddressType.main).length,
                            theme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      if (isLoading)
                        const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                      else if (filteredAddresses.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 60,
                            horizontal: 24,
                          ),
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
                                isAr
                                    ? 'لا توجد عناوين أضيفت بعد'
                                    : 'No Addresses Found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isAr
                                    ? 'أضف عنوانك الأول لتسريع وتسهيل عمليات الشراء والتوصيل'
                                    : 'Add your first address to speed up checkout and delivery',
                                style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  changeScreen(
                                    context,
                                    AddEditAddress(
                                      userId: currentUserId,
                                      userType: 'customer',
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: Text(isAr ? 'إضافة عنوان جديد' : 'Add New Address'),
                              ),
                            ],
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 900
                                ? 3
                                : (constraints.maxWidth > 600 ? 2 : 1);
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredAddresses.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 220,
                              ),
                              itemBuilder: (context, index) {
                                final address = filteredAddresses[index];
                                return _AddressPageCard(
                                  address: address,
                                  langCode: langCode,
                                  userId: currentUserId,
                                  addressService: addressService,
                                );
                              },
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 48),
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTagFilterChip(
    String filterKey,
    String label,
    int count,
    ThemeData theme,
  ) {
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
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : theme.primaryColor.withOpacity(0.12),
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
  final String userId;
  final AddressService addressService;

  const _AddressPageCard({
    required this.address,
    required this.langCode,
    required this.userId,
    required this.addressService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = langCode == 'ar';

    IconData addressIcon = Icons.home_outlined;
    switch (address.type) {
      case AddressType.home:
        addressIcon = Icons.home_outlined;
        break;
      case AddressType.office:
        addressIcon = Icons.business_outlined;
        break;
      case AddressType.main:
        addressIcon = Icons.storefront_outlined;
        break;
      case AddressType.other:
        addressIcon = Icons.location_on_outlined;
        break;
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
                    child: Icon(
                      addressIcon,
                      color: theme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.title.isNotEmpty
                            ? address.title
                            : address.type.displayName(isAr: isAr),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
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
                    await addressService.setDefaultAddress(userId, address.id);
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text(
                    isAr ? 'جعله افتراضي' : 'Set Default',
                    style: const TextStyle(fontSize: 12),
                  ),
                )
              else
                const SizedBox.shrink(),

              Row(
                children: [
                  IconButton(
                    tooltip: isAr ? 'تعديل' : 'Edit',
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () {
                      changeScreen(
                        context,
                        AddEditAddress(
                          initialAddress: address,
                          userId: userId,
                          userType: 'customer',
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: isAr ? 'حذف' : 'Delete',
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    onPressed: () async {
                      await addressService.deleteAddress(address.id);
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
