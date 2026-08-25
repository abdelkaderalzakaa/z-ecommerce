import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/services/address_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/pages/add_edit_address.dart';

class StoreManageAddressesPage extends StatelessWidget {
  final BusinessModel store;

  const StoreManageAddressesPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final addressService = AddressService();

    return StreamBuilder<List<AddressModel>>(
      stream: addressService.streamAddressesByUserId(store.id),
      builder: (context, snapshot) {
        final addresses = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'عناوين وفروع المتجر (${addresses.length})' : 'Store Branches (${addresses.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    changeScreen(
                      context,
                      AddEditAddress(
                        userId: store.id,
                        userType: 'business',
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                  label: Text(isAr ? 'إضافة فرع / عنوان' : 'Add Branch'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (addresses.isEmpty)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.location_off_outlined, size: 48, color: theme.dividerColor),
                        const SizedBox(height: 12),
                        Text(
                          isAr ? 'لا توجد فروع أو عناوين مسجلة للمتجر بعد' : 'No store branches registered yet',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            changeScreen(
                              context,
                              AddEditAddress(
                                userId: store.id,
                                userType: 'business',
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: Text(isAr ? 'إضافة أول عنوان للمتجر' : 'Add First Address'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final addr = addresses[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: addr.isDefault
                            ? theme.primaryColor.withOpacity(0.5)
                            : theme.dividerColor.withOpacity(0.15),
                        width: addr.isDefault ? 1.5 : 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.storefront_rounded, color: theme.primaryColor, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      addr.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    if (addr.isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isAr ? 'الرئيسي' : 'Main',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  addr.getFormattedAddress(langCode: isAr ? 'ar' : 'en'),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                  ),
                                ),
                                if (addr.details != null && addr.details!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${isAr ? 'علامة فارقة: ' : 'Landmark: '}${addr.details}',
                                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                onPressed: () {
                                  changeScreen(
                                    context,
                                    AddEditAddress(
                                      initialAddress: addr,
                                      userId: store.id,
                                      userType: 'business',
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () async {
                                  await addressService.deleteAddress(addr.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isAr ? 'تم حذف العنوان بنجاح' : 'Address deleted'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
