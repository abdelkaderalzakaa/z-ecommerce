import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/models/customer/customer_model.dart';
import 'package:z_ecommerce/data/services/user_service.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class UserWishlistTab extends StatelessWidget {
  final UserModel user;

  const UserWishlistTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<CustomerModel?>(
      future: UserService().getCustomerById(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final wishlist = snapshot.data?.wishlist ?? [];

        return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.wishlist.tr(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (wishlist.isEmpty)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text(TranslationKeys.yourWishlistIsEmpty.tr(context)),
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: wishlist.map((productId) {
                return Chip(
                  avatar: const Icon(Icons.favorite, size: 18, color: Colors.redAccent),
                  label: Text('منتج ID: $productId'),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }).toList(),
            ),
        ],
      ),
    );
      },
    );
  }
}
