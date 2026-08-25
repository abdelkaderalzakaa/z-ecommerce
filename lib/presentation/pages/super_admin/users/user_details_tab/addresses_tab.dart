import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/services/address_service.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class UserAddressesTab extends StatelessWidget {
  final UserModel user;

  const UserAddressesTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<AddressModel>>(
      stream: AddressService().streamAddressesByUserId(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final addresses = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${TranslationKeys.savedAddresses.tr(context)} (${addresses.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (addresses.isEmpty)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(TranslationKeys.noSavedAddresses.tr(context)),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addresses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: addr.isDefault
                              ? theme.primaryColor.withOpacity(0.5)
                              : theme.dividerColor.withOpacity(0.15),
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          addr.type == AddressType.home
                              ? Icons.home_outlined
                              : addr.type == AddressType.office
                              ? Icons.business_outlined
                              : Icons.location_on_outlined,
                          color: theme.primaryColor,
                        ),
                        title: Row(
                          children: [
                            Text(
                              addr.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (addr.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Default',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          addr.getFormattedAddress(),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
