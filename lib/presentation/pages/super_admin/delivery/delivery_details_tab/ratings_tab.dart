import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';

class DeliveryRatingsTab extends StatelessWidget {
  final DeliveryModel delivery;

  const DeliveryRatingsTab({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_half_rounded, size: 80, color: Colors.amber.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'التقييمات والمراجعات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'سيتم عرض تقييمات العملاء لهذا المندوب / الشركة هنا قريباً.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
