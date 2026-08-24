import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class OrderShippingTab extends StatelessWidget {
  final OrderModel order;

  const OrderShippingTab({super.key, required this.order});

  void _showAssignDeliveryDialog(BuildContext context) {
    final theme = Theme.of(context);
    final deliveryProvider = context.read<DeliveryProvider>();
    final businessProvider = context.read<BusinessProvider>();
    final orderProvider = context.read<OrderProvider>();

    final business = businessProvider.getBusinessById(order.businessId) ?? businessProvider.selectedBusiness;
    
    // Available deliveries:
    // If business has assigned deliveries, prioritize them. Else show all platform deliveries.
    final List<DeliveryModel> availableDeliveries = List.from(deliveryProvider.deliveries)
      ..sort((a, b) {
        final aInStore = business.assignedDeliveryIds.contains(a.id);
        final bInStore = business.assignedDeliveryIds.contains(b.id);
        if (aInStore && !bInStore) return -1;
        if (!aInStore && bInStore) return 1;
        if (a.isPlatformApproved && !b.isPlatformApproved) return -1;
        if (!a.isPlatformApproved && b.isPlatformApproved) return 1;
        return a.name.compareTo(b.name);
      });

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.local_shipping_rounded, color: Colors.blue),
              SizedBox(width: 10),
              Text('إسناد جهة توصيل للطلب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: availableDeliveries.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('لا توجد جهات توصيل مسجلة حالياً على المنصة.'),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: availableDeliveries.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final del = availableDeliveries[index];
                      final isCurrent = order.deliveryId == del.id;
                      final isStorePartner = business.assignedDeliveryIds.contains(del.id);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          backgroundImage: del.logo != null && del.logo!.isNotEmpty ? NetworkImage(del.logo!) : null,
                          child: del.logo == null || del.logo!.isEmpty
                              ? Icon(del.type == DeliveryEntityType.company ? Icons.business : Icons.person, color: theme.primaryColor)
                              : null,
                        ),
                        title: Row(
                          children: [
                            Text(del.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            if (del.isPlatformApproved) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('معتمد', style: TextStyle(fontSize: 9, color: Colors.amber, fontWeight: FontWeight.bold)),
                              ),
                            ],
                            if (isStorePartner) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('شريك للمتجر', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text('الهاتف: ${del.phone} • الرسوم: \$${del.baseFee.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                        trailing: isCurrent
                            ? const Chip(label: Text('المعين حالياً', style: TextStyle(fontSize: 11, color: Colors.blue)), visualDensity: VisualDensity.compact)
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                ),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  final success = await orderProvider.updateOrderDelivery(order.id, del.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(success ? 'تم إسناد الطلب لـ "${del.name}" بنجاح' : 'فشل إسناد الطلب'),
                                        backgroundColor: success ? Colors.green : Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('إسناد', style: TextStyle(fontSize: 12)),
                              ),
                      );
                    },
                  ),
          ),
          actions: [
            if (order.deliveryId != null && order.deliveryId!.isNotEmpty)
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await orderProvider.updateOrderDelivery(order.id, null);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إلغاء إسناد المندوب عن الطلب')),
                    );
                  }
                },
                child: const Text('إلغاء التعيين', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final address = order.shippingAddressSnapshot;
    final deliveryProvider = context.watch<DeliveryProvider>();
    final assignedDelivery = order.deliveryId != null && order.deliveryId!.isNotEmpty
        ? deliveryProvider.getDeliveryById(order.deliveryId!)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Delivery Partner Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'جهة التوصيل المسندة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAssignDeliveryDialog(context),
                icon: Icon(assignedDelivery != null ? Icons.swap_horiz : Icons.add_circle_outline, size: 18),
                label: Text(assignedDelivery != null ? 'تغيير المندوب' : 'إسناد مندوب توصيل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (assignedDelivery == null)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delivery_dining_outlined, color: Colors.orange, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'لم يتم إسناد مندوب لهذا الطلب بعد',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'يمكنك اختيار جهة أو مندوب توصيل من شبكة المنصة لتوصيل الطلب للعميل.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.primaryColor.withOpacity(0.3), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          backgroundImage: assignedDelivery.logo != null && assignedDelivery.logo!.isNotEmpty
                              ? NetworkImage(assignedDelivery.logo!)
                              : null,
                          child: assignedDelivery.logo == null || assignedDelivery.logo!.isEmpty
                              ? Icon(
                                  assignedDelivery.type == DeliveryEntityType.company ? Icons.business : Icons.person,
                                  color: theme.primaryColor,
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    assignedDelivery.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  if (assignedDelivery.isPlatformApproved) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.amber.shade600, width: 0.8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.verified, size: 12, color: Colors.amber),
                                          SizedBox(width: 3),
                                          Text(
                                            'معتمد من المنصة',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'النوع: ${assignedDelivery.type == DeliveryEntityType.company ? 'شركة توصيل' : 'مندوب فردي'}',
                                style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    _buildAddressRow(context, 'رقم الهاتف', assignedDelivery.phone),
                    const Divider(),
                    _buildAddressRow(context, 'رسوم التوصيل الأساسية', '\$${assignedDelivery.baseFee.toStringAsFixed(2)}'),
                    if (assignedDelivery.vehicleDetails != null && assignedDelivery.vehicleDetails!.isNotEmpty) ...[
                      const Divider(),
                      _buildAddressRow(context, 'بيانات المركبة', assignedDelivery.vehicleDetails!),
                    ],
                  ],
                ),
              ),
            ),

          const SizedBox(height: 32),

          // 2. Shipping Address Section
          Text(
            TranslationKeys.shippingAddress.tr(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (address == null)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('لم يتم تحديد عنوان شحن لهذا الطلب'),
                ),
              ),
            )
          else
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          address.title.isNotEmpty ? address.title : (address.details ?? 'عنوان الشحن'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAddressRow(
                      context,
                      TranslationKeys.streetAddress.tr(context),
                      address.street,
                    ),
                    const Divider(),
                    _buildAddressRow(
                      context,
                      TranslationKeys.city.tr(context),
                      address.city.get(context),
                    ),
                    const Divider(),
                    _buildAddressRow(
                      context,
                      TranslationKeys.state.tr(context),
                      address.region.get(context),
                    ),
                    if (address.postalCode != null && address.postalCode!.isNotEmpty) ...[
                      const Divider(),
                      _buildAddressRow(
                        context,
                        TranslationKeys.zipCode.tr(context),
                        address.postalCode!,
                      ),
                    ],
                    const Divider(),
                    _buildAddressRow(
                      context,
                      TranslationKeys.country.tr(context),
                      address.country.get(context),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
