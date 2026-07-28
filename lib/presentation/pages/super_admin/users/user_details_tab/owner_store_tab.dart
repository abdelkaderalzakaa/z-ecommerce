import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/user_model.dart';
import 'package:z_ecommerce/data/providers/super_admin_stores_provider.dart';

class OwnerStoreTab extends StatelessWidget {
  final UserModel user;

  const OwnerStoreTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SuperAdminStoresProvider>(
      builder: (context, provider, child) {
        final store = provider.stores.firstWhere(
          (s) => s.id == user.companyId,
          orElse: () => provider.stores.first,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'المتجر والنشاط التجاري المنسوب',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: Icon(Icons.storefront_rounded, color: theme.primaryColor),
                  ),
                  title: Text(
                    store.name.get(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('رمز المتجر: ${store.id} • القسم: ${store.category.name.get(context)}'),
                  trailing: Chip(
                    label: Text(store.status ?? 'Active'),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
