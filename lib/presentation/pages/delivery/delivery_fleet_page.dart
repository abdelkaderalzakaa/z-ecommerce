import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_driver_model.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';

class DeliveryFleetPage extends StatelessWidget {
  const DeliveryFleetPage({super.key});

  void _showDriverDialog(BuildContext context, [DeliveryDriverModel? driver]) {
    final isEdit = driver != null;
    final nameController = TextEditingController(text: driver?.name ?? '');
    final phoneController = TextEditingController(text: driver?.phone ?? '');
    final vehicleController = TextEditingController(text: driver?.vehicleNumber ?? '');
    final typeController = TextEditingController(text: driver?.vehicleType ?? 'دراجة نارية');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEdit ? 'تعديل بيانات الكابتن' : 'إضافة كابتن جديد للأسطول'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الكابتن',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: vehicleController,
                  decoration: const InputDecoration(
                    labelText: 'رقم لوحة المركبة (اختياري)',
                    prefixIcon: Icon(Icons.pin),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'نوع المركبة (دراجة نارية / سيارة / فان)',
                    prefixIcon: Icon(Icons.two_wheeler),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
                  return;
                }

                final newDriver = DeliveryDriverModel(
                  id: driver?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  vehicleNumber: vehicleController.text.trim(),
                  vehicleType: typeController.text.trim(),
                  isAvailable: driver?.isAvailable ?? true,
                  deliveredCount: driver?.deliveredCount ?? 0,
                  rating: driver?.rating ?? 5.0,
                );

                await context.read<DeliveryProvider>().saveDriver(newDriver);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(isEdit ? 'حفظ التعديل' : 'إضافة الكابتن'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchCaller(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    if (phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = context.watch<LocaleProvider>().locale.languageCode == 'ar';
    final deliveryProvider = context.watch<DeliveryProvider>();
    final delivery = deliveryProvider.currentDelivery;
    final drivers = delivery.drivers;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppDataTable<DeliveryDriverModel>(
                items: drivers,
                isLoading: deliveryProvider.isLoading,
                selectable: true,
                showIndexColumn: true,
                searchMatcher: (driver, query) {
                  return driver.name.toLowerCase().contains(query) ||
                      driver.phone.toLowerCase().contains(query) ||
                      (driver.vehicleType?.toLowerCase().contains(query) ?? false) ||
                      (driver.vehicleNumber?.toLowerCase().contains(query) ?? false);
                },
                primaryActionButton: ElevatedButton.icon(
                  onPressed: () => _showDriverDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(isAr ? 'إضافة كابتن جديد' : 'Add New Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                columns: [
                  AppTableColumn<DeliveryDriverModel>(
                    title: isAr ? 'الكابتن' : 'Driver',
                    width: 240,
                    sortable: true,
                    cellBuilder: (driver) => TableImageTextCell(
                      title: driver.name,
                      subtitle: driver.phone,
                      fallbackIcon: Icons.person_pin_rounded,
                    ),
                    sortKey: (driver) => driver.name,
                  ),
                  AppTableColumn<DeliveryDriverModel>(
                    title: isAr ? 'المركبة واللوحة' : 'Vehicle',
                    width: 180,
                    cellBuilder: (driver) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.vehicleType ?? (isAr ? 'دراجة نارية' : 'Motorbike'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (driver.vehicleNumber != null && driver.vehicleNumber!.isNotEmpty)
                          Text(
                            'لوحة: ${driver.vehicleNumber}',
                            style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
                          ),
                      ],
                    ),
                  ),
                  AppTableColumn<DeliveryDriverModel>(
                    title: isAr ? 'الحالة' : 'Status',
                    width: 130,
                    cellBuilder: (driver) => TableStatusBadge(
                      statusText: driver.isAvailable
                          ? (isAr ? 'متاح للطلب' : 'Available')
                          : (isAr ? 'مشغول / أوفلاين' : 'Busy'),
                      backgroundColor: driver.isAvailable
                          ? Colors.green.withOpacity(0.12)
                          : Colors.orange.withOpacity(0.12),
                      textColor: driver.isAvailable ? Colors.green.shade800 : Colors.orange.shade800,
                    ),
                  ),
                  AppTableColumn<DeliveryDriverModel>(
                    title: isAr ? 'الطلبات المكتملة' : 'Delivered Orders',
                    width: 140,
                    sortable: true,
                    cellBuilder: (driver) => Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${driver.deliveredCount} طلب',
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 12),
                        ),
                      ),
                    ),
                    sortKey: (driver) => driver.deliveredCount,
                  ),
                  AppTableColumn<DeliveryDriverModel>(
                    title: isAr ? 'التقييم' : 'Rating',
                    width: 110,
                    cellBuilder: (driver) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          driver.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  AppTableColumn<DeliveryDriverModel>(
                    title: isAr ? 'الإجراءات' : 'Actions',
                    width: 170,
                    cellBuilder: (driver) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.phone_rounded, color: Colors.blue, size: 18),
                          tooltip: isAr ? 'اتصال' : 'Call',
                          onPressed: () => _launchCaller(driver.phone),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_rounded, color: Colors.green, size: 18),
                          tooltip: isAr ? 'واتساب' : 'WhatsApp',
                          onPressed: () => _launchWhatsApp(driver.phone),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_rounded, color: Colors.amber.shade800, size: 18),
                          tooltip: isAr ? 'تعديل' : 'Edit',
                          onPressed: () => _showDriverDialog(context, driver),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                          tooltip: isAr ? 'حذف' : 'Delete',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('تأكيد الحذف'),
                                content: Text('هل أنت متأكد من حذف الكابتن ${driver.name}؟'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('إلغاء'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('حذف', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await context.read<DeliveryProvider>().deleteDriver(driver.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
