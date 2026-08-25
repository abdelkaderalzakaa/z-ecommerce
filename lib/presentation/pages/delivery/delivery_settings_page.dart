import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/currency_helper.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';

class DeliverySettingsPage extends StatelessWidget {
  const DeliverySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = context.watch<LocaleProvider>().locale.languageCode == 'ar';
    final deliveryProvider = context.watch<DeliveryProvider>();
    final delivery = deliveryProvider.currentDelivery;
    final isCompany = delivery.type == DeliveryEntityType.company;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Card Matching Super Admin & Store Settings
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withOpacity(0.12),
                      theme.cardColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'إعدادات وخيارات التوصيل والشحن' : 'Delivery & Logistics Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAr
                                ? 'إدارة بيانات الاتصال، تسعيرة الشحنات (\$ / ل.ل)، مدن التغطية، وتفاصيل المركبة.'
                                : 'Manage contact details, delivery pricing (\$ / LBP), coverage cities, and vehicle.',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Settings Category Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.25,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildSettingsCard(
                        context: context,
                        title: isAr ? 'البيانات ومعلومات الاتصال' : 'Contact Information',
                        subtitle: isAr ? 'تعديل اسم الكابتن/الشركة، الهاتف، والبريد' : 'Edit name, direct phone, and email',
                        icon: Icons.contact_phone_rounded,
                        color: Colors.blue,
                        onTap: () => _showContactInfoDialog(context, delivery),
                      ),
                      _buildSettingsCard(
                        context: context,
                        title: isAr ? 'تسعيرة وأجور التوصيل' : 'Delivery Pricing & Fees',
                        subtitle: isAr
                            ? 'أجرة التوصيل الأساسية: ${AppCurrencyHelper.formatUSD(delivery.baseFee)} (${AppCurrencyHelper.formatLBP(delivery.baseFee, isArabic: true)})'
                            : 'Base fee: ${AppCurrencyHelper.formatUSD(delivery.baseFee)}',
                        icon: Icons.price_change_rounded,
                        color: Colors.green,
                        onTap: () => _showPricingDialog(context, delivery),
                      ),
                      _buildSettingsCard(
                        context: context,
                        title: isAr ? 'مناطق ومدن التغطية' : 'Coverage Areas & Cities',
                        subtitle: isAr
                            ? 'تغطية ${delivery.coverageAreas.length} منطقة ومدينة'
                            : '${delivery.coverageAreas.length} areas covered',
                        icon: Icons.map_rounded,
                        color: Colors.purple,
                        onTap: () => _showCoverageDialog(context, delivery),
                      ),
                      _buildSettingsCard(
                        context: context,
                        title: isAr ? 'تفاصيل المركبة والأسطول' : 'Vehicle & Fleet Details',
                        subtitle: isAr
                            ? (delivery.vehicleDetails?.isNotEmpty == true ? delivery.vehicleDetails! : 'دراجة نارية / سيارة')
                            : 'Vehicle type, license plate, and fleet',
                        icon: isCompany ? Icons.local_shipping_rounded : Icons.two_wheeler_rounded,
                        color: Colors.orange,
                        onTap: () => _showVehicleDialog(context, delivery),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 1. Contact Information Modal
  void _showContactInfoDialog(BuildContext context, DeliveryModel delivery) {
    final nameController = TextEditingController(text: delivery.name);
    final phoneController = TextEditingController(text: delivery.phone);
    final emailController = TextEditingController(text: delivery.email ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('بيانات ومعلومات الاتصال'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthTextField(
                controller: nameController,
                label: 'اسم المندوب / شركة التوصيل',
                hintText: 'شركة التوصيل السريع',
                prefixIcon: Icons.badge_rounded,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: phoneController,
                label: 'رقم هاتف الاتصال المباشر',
                hintText: '+961 70 123 456',
                prefixIcon: Icons.phone_rounded,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: emailController,
                label: 'البريد الإلكتروني (اختياري)',
                hintText: 'delivery@example.com',
                prefixIcon: Icons.email_rounded,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final updated = delivery.copyWith(
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
              );
              await context.read<DeliveryProvider>().saveDelivery(updated);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('حفظ التعديلات'),
          ),
        ],
      ),
    );
  }

  // 2. Pricing Modal
  void _showPricingDialog(BuildContext context, DeliveryModel delivery) {
    final feeController = TextEditingController(text: delivery.baseFee.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تسعيرة وأجور التوصيل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الأجرة الأساسية المحتسبة للشحنة بالدولار الأمريكي (\$ USD):',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: feeController,
              label: 'أجرة التوصيل الأساسية (\$ USD)',
              hintText: '5.0',
              prefixIcon: Icons.attach_money_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يتم تحويل الأجرة تلقائياً بالليرة اللبنانية حسب سعر الصرف المعتمد في المنصة.',
                      style: TextStyle(fontSize: 11, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final fee = double.tryParse(feeController.text.trim()) ?? delivery.baseFee;
              final updated = delivery.copyWith(baseFee: fee);
              await context.read<DeliveryProvider>().saveDelivery(updated);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('حفظ التسعيرة'),
          ),
        ],
      ),
    );
  }

  // 3. Coverage Areas Modal
  void _showCoverageDialog(BuildContext context, DeliveryModel delivery) {
    List<String> areas = List.from(delivery.coverageAreas);
    final areaController = TextEditingController();

    final presetCities = const [
      'بيروت',
      'طرابلس',
      'صيدا',
      'صور',
      'زحلة',
      'النبطية',
      'جبيل',
      'جونية',
      'بعبدا',
      'الشوف',
      'المتن',
      'كسروان',
      'عكار',
      'بعلبك',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('مناطق ومدن التغطية'),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: areaController,
                            decoration: const InputDecoration(
                              hintText: 'اكتب اسم منطقة واضغط إضافة...',
                              prefixIcon: Icon(Icons.add_location_alt_rounded),
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty && !areas.contains(val.trim())) {
                                setDialogState(() => areas.add(val.trim()));
                                areaController.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (areaController.text.trim().isNotEmpty && !areas.contains(areaController.text.trim())) {
                              setDialogState(() => areas.add(areaController.text.trim()));
                              areaController.clear();
                            }
                          },
                          child: const Text('إضافة'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('اقتراحات سريعة للمدن:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: presetCities.map((city) {
                        final isAdded = areas.contains(city);
                        return ActionChip(
                          avatar: Icon(isAdded ? Icons.check : Icons.add, size: 14),
                          label: Text(city, style: const TextStyle(fontSize: 11)),
                          onPressed: () {
                            setDialogState(() {
                              if (isAdded) {
                                areas.remove(city);
                              } else {
                                areas.add(city);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const Text('المناطق المعتمدة حالياً:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: areas.map((area) {
                        return Chip(
                          label: Text(area),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () => setDialogState(() => areas.remove(area)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  final updated = delivery.copyWith(coverageAreas: areas);
                  await context.read<DeliveryProvider>().saveDelivery(updated);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('حفظ مناطق التغطية'),
              ),
            ],
          );
        },
      ),
    );
  }

  // 4. Vehicle Modal
  void _showVehicleDialog(BuildContext context, DeliveryModel delivery) {
    final vehicleController = TextEditingController(text: delivery.vehicleDetails ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تفاصيل المركبة والأسطول'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuthTextField(
              controller: vehicleController,
              label: 'نوع المركبة ورقم اللوحة',
              hintText: 'دراجة نارية هوندا - لوحة 1234',
              prefixIcon: Icons.two_wheeler_rounded,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final updated = delivery.copyWith(
                vehicleDetails: vehicleController.text.trim().isNotEmpty ? vehicleController.text.trim() : null,
              );
              await context.read<DeliveryProvider>().saveDelivery(updated);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('حفظ البيانات'),
          ),
        ],
      ),
    );
  }
}
