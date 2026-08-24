import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';

class DeliveryPermissionsTab extends StatelessWidget {
  final DeliveryModel delivery;

  const DeliveryPermissionsTab({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Consumer2<BusinessProvider, DeliveryProvider>(
      builder: (context, businessProvider, deliveryProvider, child) {
        
        final assignedBusinesses = businessProvider.businesses.where((b) {
          return b.assignedDeliveryIds.contains(delivery.id);
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Toggle Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'حالة التفعيل',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            delivery.status == 'Active'
                                ? 'الحساب مفعل ويمكنه استقبال الطلبات'
                                : 'الحساب معطل',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: delivery.status == 'Active',
                        onChanged: (val) {
                          final newStatus = val ? 'Active' : 'Inactive';
                          deliveryProvider.saveDelivery(
                            delivery.copyWith(status: newStatus),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'معتمد لدى المنصة',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                delivery.isPlatformApproved
                                    ? 'يظهر هذا المندوب في بداية القائمة للمتاجر'
                                    : 'غير معتمد حالياً',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: delivery.isPlatformApproved,
                            onChanged: (val) {
                              deliveryProvider.saveDelivery(
                                delivery.copyWith(isPlatformApproved: val),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'المتاجر المرتبطة بهذا المندوب',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showLinkBusinessDialog(context, delivery, businessProvider),
                    icon: const Icon(Icons.add_link, size: 20),
                    label: const Text('ربط بمتجر'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: AppDataTable<BusinessModel>(
                  items: assignedBusinesses,
                  isLoading: businessProvider.isLoading,
                  columns: [
                    AppTableColumn<BusinessModel>(
                      title: 'المتجر',
                      width: 250,
                      cellBuilder: (business) => TableImageTextCell(
                        title: business.localization.name.ar,
                        subtitle: business.ownerEmail,
                        imageUrl: business.theme.logoUrl,
                        fallbackIcon: Icons.store_outlined,
                      ),
                    ),
                    AppTableColumn<BusinessModel>(
                      title: 'رقم الهاتف',
                      width: 150,
                      cellBuilder: (business) => Text(business.ownerPhone ?? 'غير متوفر'),
                    ),
                    AppTableColumn<BusinessModel>(
                      title: 'إلغاء الربط',
                      width: 100,
                      cellBuilder: (business) => IconButton(
                        icon: const Icon(Icons.link_off, color: Colors.red),
                        onPressed: () {
                          final newList = List<String>.from(business.assignedDeliveryIds);
                          newList.remove(delivery.id);
                          final updated = business.copyWith(assignedDeliveryIds: newList);
                          businessProvider.saveBusiness(updated);
                        },
                      ),
                    ),
                  ],
                  onRowTap: (business) {
                    // Navigate to business details if needed
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLinkBusinessDialog(BuildContext context, DeliveryModel delivery, BusinessProvider provider) {
    final availableBusinesses = provider.businesses.where((b) {
      return !b.assignedDeliveryIds.contains(delivery.id);
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ربط بمتجر'),
          content: SizedBox(
            width: double.maxFinite,
            child: availableBusinesses.isEmpty
                ? const Text('جميع المتاجر مرتبطة مسبقاً بهذا المندوب')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableBusinesses.length,
                    itemBuilder: (context, index) {
                      final b = availableBusinesses[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: b.theme.logoUrl != null ? NetworkImage(b.theme.logoUrl!) : null,
                          child: b.theme.logoUrl == null ? const Icon(Icons.store) : null,
                        ),
                        title: Text(b.localization.name.ar),
                        trailing: TextButton(
                          onPressed: () {
                            final newList = List<String>.from(b.assignedDeliveryIds);
                            newList.add(delivery.id);
                            provider.saveBusiness(b.copyWith(assignedDeliveryIds: newList));
                            Navigator.pop(context);
                          },
                          child: const Text('ربط'),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }
}
