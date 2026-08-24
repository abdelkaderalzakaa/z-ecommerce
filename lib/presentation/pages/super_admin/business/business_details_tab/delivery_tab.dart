import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/models/store/business_model.dart';
import '../../../../../../data/providers/business_provider.dart';
import '../../../../../../presentation/global/core/constants/enum_data.dart';
import '../../../../../../presentation/global/core/constants/app_constants.dart';

class DeliveryTab extends StatefulWidget {
  final BusinessModel store;

  const DeliveryTab({super.key, required this.store});

  @override
  State<DeliveryTab> createState() => _DeliveryTabState();
}

class _DeliveryTabState extends State<DeliveryTab> {
  late DeliveryHandlingType _selectedHandling;

  @override
  void initState() {
    super.initState();
    _selectedHandling = widget.store.deliveryHandling;
  }

  void _saveChanges() {
    final provider = context.read<BusinessProvider>();
    final updatedStore = widget.store.copyWith(deliveryHandling: _selectedHandling);
    provider.saveBusiness(updatedStore);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ إعدادات التوصيل')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إعدادات التوصيل',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الجهة المسؤولة عن التوصيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  RadioListTile<DeliveryHandlingType>(
                    title: const Text('خاص بالمتجر (Own)'),
                    subtitle: const Text('المتجر يدير عمليات التوصيل ولديه مناديبه الخاصين'),
                    value: DeliveryHandlingType.own,
                    groupValue: _selectedHandling,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedHandling = val);
                    },
                  ),
                  RadioListTile<DeliveryHandlingType>(
                    title: const Text('عبر المنصة (Platform)'),
                    subtitle: const Text('يعتمد المتجر على المنصة في توفير شركات/مناديب التوصيل'),
                    value: DeliveryHandlingType.platform,
                    groupValue: _selectedHandling,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedHandling = val);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedHandling == DeliveryHandlingType.platform) ...[
            const Text(
              'شركات التوصيل المخصصة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: const Text('هنا ستظهر قائمة لربط المتجر بالمناديب المضافين مسبقاً في قسم التوصيل.'),
            ),
            const SizedBox(height: 24),
          ],
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('حفظ التعديلات'),
          ),
        ],
      ),
    );
  }
}
