import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:intl/intl.dart';

class DeliveryOverviewTab extends StatelessWidget {
  final DeliveryModel delivery;

  const DeliveryOverviewTab({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'المعلومات الأساسية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _buildInfoRow(
                    context,
                    'النوع',
                    delivery.type == DeliveryEntityType.company ? 'شركة' : 'فرد/مندوب',
                    Icons.business_center_outlined,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    'البريد الإلكتروني',
                    delivery.email?.isNotEmpty == true ? delivery.email! : 'غير متوفر',
                    Icons.email_outlined,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    'الهاتف',
                    delivery.phone,
                    Icons.phone_outlined,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    'رسوم التوصيل',
                    '\$${delivery.baseFee.toStringAsFixed(2)}',
                    Icons.attach_money_outlined,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Working Details Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تفاصيل العمل والمركبة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _buildInfoRow(
                    context,
                    'تفاصيل المركبة',
                    delivery.vehicleDetails?.isNotEmpty == true ? delivery.vehicleDetails! : 'غير متوفر',
                    Icons.two_wheeler_outlined,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    'مناطق التغطية',
                    delivery.coverageAreas.isNotEmpty ? delivery.coverageAreas.join(', ') : 'غير محدد',
                    Icons.map_outlined,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Account Timeline
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'سجل الحساب',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _buildInfoRow(
                    context,
                    'تاريخ الإنشاء',
                    DateFormat.yMMMd().format(delivery.createdAt),
                    Icons.calendar_today_outlined,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    'آخر تحديث',
                    DateFormat.yMMMd().format(delivery.updatedAt),
                    Icons.update_outlined,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
