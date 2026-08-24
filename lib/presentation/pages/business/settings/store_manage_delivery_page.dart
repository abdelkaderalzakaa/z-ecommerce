import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

class StoreManageDeliveryPage extends StatefulWidget {
  final BusinessModel? store;

  const StoreManageDeliveryPage({super.key, this.store});

  @override
  State<StoreManageDeliveryPage> createState() => _StoreManageDeliveryPageState();
}

class _StoreManageDeliveryPageState extends State<StoreManageDeliveryPage> {
  late DeliveryHandlingType _deliveryHandling;
  late List<String> _assignedDeliveryIds;
  bool _isSaving = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final business = widget.store ?? context.read<BusinessProvider>().selectedBusiness;
    _deliveryHandling = business.deliveryHandling;
    _assignedDeliveryIds = List<String>.from(business.assignedDeliveryIds);
  }

  Future<void> _saveSettings(BusinessModel currentBusiness) async {
    setState(() => _isSaving = true);
    try {
      final updated = currentBusiness.copyWith(
        deliveryHandling: _deliveryHandling,
        assignedDeliveryIds: _assignedDeliveryIds,
      );
      await context.read<BusinessProvider>().saveBusiness(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ إعدادات التوصيل بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الحفظ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final businessProvider = context.watch<BusinessProvider>();
    final currentBusiness = widget.store ?? businessProvider.selectedBusiness;
    final deliveryProvider = context.watch<DeliveryProvider>();

    // Sort deliveries: platform approved first, then alphabetically
    final allDeliveries = List<DeliveryModel>.from(deliveryProvider.deliveries)
      ..sort((a, b) {
        if (a.isPlatformApproved && !b.isPlatformApproved) return -1;
        if (!a.isPlatformApproved && b.isPlatformApproved) return 1;
        return a.name.compareTo(b.name);
      });

    final filteredDeliveries = allDeliveries.where((d) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return d.name.toLowerCase().contains(q) ||
          d.phone.contains(q) ||
          d.coverageAreas.any((area) => area.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('إعدادات وشركات التوصيل'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ButtonApp(
              label: _isSaving ? 'جاري الحفظ...' : 'حفظ التعديلات',
              onPressed: _isSaving ? null : () => _saveSettings(currentBusiness),
              isLoading: _isSaving,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Delivery Mode Selection Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.local_shipping_rounded, color: theme.primaryColor),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'نموذج إدارة التوصيل',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'حدد ما إذا كان متجرك يعتمد على التوصيل الخاص به أو شبكة التوصيل التابعة للمنصة',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Platform Delivery Option
                      InkWell(
                        onTap: () {
                          setState(() => _deliveryHandling = DeliveryHandlingType.platform);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _deliveryHandling == DeliveryHandlingType.platform
                                  ? theme.primaryColor
                                  : theme.dividerColor.withOpacity(0.2),
                              width: _deliveryHandling == DeliveryHandlingType.platform ? 2 : 1,
                            ),
                            color: _deliveryHandling == DeliveryHandlingType.platform
                                ? theme.primaryColor.withOpacity(0.04)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Radio<DeliveryHandlingType>(
                                value: DeliveryHandlingType.platform,
                                groupValue: _deliveryHandling,
                                onChanged: (val) {
                                  if (val != null) setState(() => _deliveryHandling = val);
                                },
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'التوصيل عبر شبكة المنصة (Platform Network)',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'الاستفادة من أسطول المنصة، المناديب المعتمدين وشركات التوصيل المسجلة مع إمكانية تعيينهم للطلبات.',
                                      style: TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.hub_rounded, color: Colors.blue),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Own Delivery Option
                      InkWell(
                        onTap: () {
                          setState(() => _deliveryHandling = DeliveryHandlingType.own);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _deliveryHandling == DeliveryHandlingType.own
                                  ? theme.primaryColor
                                  : theme.dividerColor.withOpacity(0.2),
                              width: _deliveryHandling == DeliveryHandlingType.own ? 2 : 1,
                            ),
                            color: _deliveryHandling == DeliveryHandlingType.own
                                ? theme.primaryColor.withOpacity(0.04)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Radio<DeliveryHandlingType>(
                                value: DeliveryHandlingType.own,
                                groupValue: _deliveryHandling,
                                onChanged: (val) {
                                  if (val != null) setState(() => _deliveryHandling = val);
                                },
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'التوصيل خاص بالمتجر (Own Delivery)',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'يقوم المتجر بإدارة مناديبه وسياراته الخاصة واستلام الطلبات وتوصيلها مباشرة دون شركات المنصة.',
                                      style: TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.store_mall_directory_rounded, color: Colors.teal),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Deliveries List (When Platform Mode is Selected)
              if (_deliveryHandling == DeliveryHandlingType.platform) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'شركات ومناديب التوصيل المتاحين',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'اختر المناديب والشركات التي تود إتاحتها لمتجرك (${_assignedDeliveryIds.length} محددة)',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                    if (_assignedDeliveryIds.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _assignedDeliveryIds.clear());
                        },
                        icon: const Icon(Icons.clear_all, size: 18, color: Colors.red),
                        label: const Text('إلغاء تحديد الكل', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'بحث باسم المندوب، الهاتف، أو منطقة التغطية...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.cardColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (deliveryProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filteredDeliveries.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 54, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'لا توجد جهات توصيل مطابقة',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDeliveries.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final delivery = filteredDeliveries[index];
                      final isAssigned = _assignedDeliveryIds.contains(delivery.id);

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isAssigned
                                ? theme.primaryColor.withOpacity(0.5)
                                : theme.dividerColor.withOpacity(0.12),
                            width: isAssigned ? 1.5 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Avatar / Logo
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: theme.primaryColor.withOpacity(0.1),
                                backgroundImage: delivery.logo != null && delivery.logo!.isNotEmpty
                                    ? NetworkImage(delivery.logo!)
                                    : null,
                                child: delivery.logo == null || delivery.logo!.isEmpty
                                    ? Icon(
                                        delivery.type == DeliveryEntityType.company
                                            ? Icons.business_rounded
                                            : Icons.person_rounded,
                                        color: theme.primaryColor,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          delivery.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (delivery.isPlatformApproved) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.amber.shade600, width: 0.8),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.verified, size: 13, color: Colors.amber),
                                                SizedBox(width: 4),
                                                Text(
                                                  'معتمد من المنصة',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 4,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              delivery.phone,
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.attach_money_outlined, size: 14, color: Colors.green),
                                            Text(
                                              'رسوم التوصيل: \$${delivery.baseFee.toStringAsFixed(2)}',
                                              style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        if (delivery.coverageAreas.isNotEmpty)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.map_outlined, size: 14, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                'التغطية: ${delivery.coverageAreas.join(', ')}',
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Checkbox / Switch
                              Switch(
                                value: isAssigned,
                                activeColor: theme.primaryColor,
                                onChanged: (val) {
                                  setState(() {
                                    if (val) {
                                      if (!_assignedDeliveryIds.contains(delivery.id)) {
                                        _assignedDeliveryIds.add(delivery.id);
                                      }
                                    } else {
                                      _assignedDeliveryIds.remove(delivery.id);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ] else ...[
                // Own Delivery Helper Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.teal, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'إدارة التوصيل الخاص بالمتجر',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'عند اختيار "التوصيل الخاص بالمتجر"، ستتمكن من إدارة طلبياتك وتسليمها مباشرة عبر فريق التوصيل التابع لمتجرك دون ربطها بشركات المنصة الخارجية.',
                        style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '💡 ملاحظة: سيظهر لعملائك أثناء الشراء أن التوصيل يتم مباشرة من قبل المتجر.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
