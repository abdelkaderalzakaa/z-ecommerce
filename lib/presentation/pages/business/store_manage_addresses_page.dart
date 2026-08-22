import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class StoreManageAddressesPage extends StatefulWidget {
  final BusinessModel store;

  const StoreManageAddressesPage({super.key, required this.store});

  @override
  State<StoreManageAddressesPage> createState() => _StoreManageAddressesPageState();
}

class _StoreManageAddressesPageState extends State<StoreManageAddressesPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();

  AddressModel? _editingAddress;
  bool _isSubmitting = false;

  void _clearForm() {
    setState(() {
      _editingAddress = null;
      _titleController.clear();
      _cityController.clear();
      _regionController.clear();
      _streetController.clear();
      _buildingController.clear();
    });
  }

  void _loadAddressForEdit(AddressModel address) {
    setState(() {
      _editingAddress = address;
      _titleController.text = address.title;
      _cityController.text = address.city.ar;
      _regionController.text = address.region.ar;
      _streetController.text = address.street;
      _buildingController.text = address.building ?? '';
    });
  }

  Future<void> _saveAddress() async {
    if (_titleController.text.trim().isEmpty || _streetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة عنوان الفرع والشارع التفصيلي')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = context.read<BusinessProvider>();
    final currentStore = provider.businesses.firstWhere(
      (b) => b.id == widget.store.id,
      orElse: () => widget.store,
    );

    List<AddressModel> updatedAddresses = List.from(currentStore.addAddress);

    final newAddress = AddressModel(
      id: _editingAddress?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      country: const LocalizedString(ar: 'العراق', en: 'Iraq'),
      city: LocalizedString(ar: _cityController.text.trim(), en: _cityController.text.trim()),
      region: LocalizedString(ar: _regionController.text.trim(), en: _regionController.text.trim()),
      street: _streetController.text.trim(),
      building: _buildingController.text.trim(),
      isDefault: _editingAddress?.isDefault ?? (updatedAddresses.isEmpty),
    );

    if (_editingAddress != null) {
      final index = updatedAddresses.indexWhere((a) => a.id == _editingAddress!.id);
      if (index != -1) {
        updatedAddresses[index] = newAddress;
      }
    } else {
      updatedAddresses.add(newAddress);
    }

    final updatedStore = currentStore.copyWith(addAddress: updatedAddresses);
    await provider.saveBusiness(updatedStore);

    if (mounted) {
      setState(() => _isSubmitting = false);
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ عنوان المتجر بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    final provider = context.read<BusinessProvider>();
    final currentStore = provider.businesses.firstWhere(
      (b) => b.id == widget.store.id,
      orElse: () => widget.store,
    );

    final updatedAddresses = currentStore.addAddress.where((a) => a.id != addressId).toList();
    final updatedStore = currentStore.copyWith(addAddress: updatedAddresses);
    await provider.saveBusiness(updatedStore);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف العنوان بنجاح'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final businessProvider = context.watch<BusinessProvider>();
    final currentStore = businessProvider.businesses.firstWhere(
      (b) => b.id == widget.store.id,
      orElse: () => widget.store,
    );

    return AddEditTemplate(
      title: isAr ? 'إدارة وتعديل عناوين فروع المتجر' : 'Manage Store Branch Addresses',
      subtitle: isAr ? 'إضافة وتعديل وحذف الفروع والعناوين لـ (${currentStore.localization.name.get(context)})' : 'Add & update store branches',
      formKey: _formKey,
      isSubmitting: _isSubmitting,
      isEditMode: true,
      submitLabel: _editingAddress == null ? (isAr ? 'حفظ وإضافة العنوان' : 'Save Address') : (isAr ? 'تحديث وتطبيق العنوان' : 'Update Address'),
      onSubmit: _saveAddress,
      sections: [
        // Form Section 1: Address Input Form
        FormSection(
          title: _editingAddress == null ? (isAr ? 'إضافة عنوان فرع جديد' : 'Add New Branch Address') : (isAr ? 'تعديل العنوان المحدد' : 'Edit Address'),
          icon: Icons.add_location_alt_outlined,
          fields: [
            if (_editingAddress != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'جاري تعديل: ${_editingAddress!.title}',
                      style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _clearForm,
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('إلغاء التعديل'),
                    ),
                  ],
                ),
              ),
            AuthTextField(
              controller: _titleController,
              label: isAr ? 'اسم الفرع / العنوان' : 'Branch Title',
              hintText: isAr ? 'مثال: الفرع الرئيسي - الكرادة' : 'e.g. Main Branch',
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _cityController,
              label: isAr ? 'المدينة' : 'City',
              hintText: isAr ? 'مثال: بغداد' : 'e.g. Baghdad',
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _regionController,
              label: isAr ? 'المنطقة / القضاء' : 'Region',
              hintText: isAr ? 'مثال: المنصور' : 'e.g. Al-Mansour',
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _streetController,
              label: isAr ? 'الشارع والتفاصيل' : 'Street Details',
              hintText: isAr ? 'مثال: شارع الاميرات - مقابل المول' : 'Street details',
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _buildingController,
              label: isAr ? 'رقم المبنى / الطابق' : 'Building / Floor',
              hintText: isAr ? 'مثال: مبنى 42 - الطابق الأرضي' : 'Building 42',
            ),
          ],
        ),

        // Form Section 2: Registered Addresses List
        FormSection(
          title: isAr ? 'العناوين المسجلة للمتجر (${currentStore.addAddress.length})' : 'Registered Addresses',
          icon: Icons.list_alt_rounded,
          fields: [
            if (currentStore.addAddress.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    isAr ? 'لا توجد عناوين مسجلة بعد للمتجر' : 'No store addresses registered yet',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentStore.addAddress.length,
                itemBuilder: (context, index) {
                  final addr = currentStore.addAddress[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.storefront, color: theme.primaryColor),
                      title: Text(
                        addr.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        addr.getFormattedAddress(langCode: isAr ? 'ar' : 'en'),
                        style: const TextStyle(fontSize: 12.5),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                            onPressed: () => _loadAddressForEdit(addr),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () => _deleteAddress(addr.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
