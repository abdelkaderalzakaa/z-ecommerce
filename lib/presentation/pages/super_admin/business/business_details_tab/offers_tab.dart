import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/offer_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/pages/business/offers/create_edit_offer_page.dart';

class OffersTab extends StatefulWidget {
  final BusinessModel store;

  const OffersTab({super.key, required this.store});

  @override
  State<OffersTab> createState() => _OffersTabState();
}

class _OffersTabState extends State<OffersTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OfferProvider>(
      builder: (context, offerProvider, child) {
        final storeOffers = offerProvider.storeOffers
            .where((o) => o.businessId == widget.store.id)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'العروض المتاحة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ButtonApp(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateEditOfferPage(),
                      ),
                    );
                  },
                  icon: Icons.add,
                  label: 'إضافة عرض',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (storeOffers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('لا توجد عروض لهذا المتجر حتى الآن.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: storeOffers.length,
                itemBuilder: (context, index) {
                  final offer = storeOffers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: offer.imageUrl != null
                          ? Image.network(
                              offer.imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.local_offer, size: 40),
                      title: Text(offer.name.get(context)),
                      subtitle: Text(offer.type),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ButtonApp(
                            format: FormatButtonApp.icon,
                            icon: Icons.edit,
                            color: Colors.blue,
                            label: 'تعديل',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CreateEditOfferPage(offer: offer),
                                ),
                              );
                            },
                          ),
                          Switch(
                            value: offer.isActive,
                            onChanged: (val) {
                              // Optional: call provider to toggle isActive state
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تغيير حالة العرض'),
                                ),
                              );
                            },
                          ),
                          ButtonApp(
                            format: FormatButtonApp.icon,
                            icon: Icons.delete,
                            color: Colors.red,
                            label: 'حذف',
                            onPressed: () {
                              Provider.of<OfferProvider>(
                                context,
                                listen: false,
                              ).deleteOffer(offer.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم حذف العرض بنجاح'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
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
