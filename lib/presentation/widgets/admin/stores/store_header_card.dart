import 'package:flutter/material.dart';
import '../../../../../data/models/company_settings_model.dart';
import '../../../../../data/models/user_model.dart';

class StoreHeaderCard extends StatelessWidget {
  final CompanySettingsModel store;
  final UserModel owner;

  const StoreHeaderCard({super.key, required this.store, required this.owner});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Cover Image Placeholder
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Logo Placeholder
                Container(
                  width: 80,
                  height: 80,
                  transform: Matrix4.translationValues(0, -40, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  child: const Center(child: Icon(Icons.store, size: 32, color: Colors.grey)),
                ),
                const SizedBox(width: 16),
                
                // Store Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name.get(context),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.category, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(store.category.name.get(context), style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 16),
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(owner.name, style: const TextStyle(color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ),
                
                // Actions
                Column(
                  children: [
                    Chip(
                      label: Text(store.status ?? 'Active'),
                      backgroundColor: store.status == 'Active' ? Colors.green.shade100 : Colors.red.shade100,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Store'),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
