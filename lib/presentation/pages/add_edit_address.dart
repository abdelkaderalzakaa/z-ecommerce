import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/providers/address_provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/services/lebanon_regions_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';

class AddEditAddress extends StatefulWidget {
  final AddressModel? initialAddress;
  final String? userId;
  final String? userType;
  final void Function(AddressModel savedAddress)? onSave;

  const AddEditAddress({
    super.key,
    this.initialAddress,
    this.userId,
    this.userType,
    this.onSave,
  });

  @override
  State<AddEditAddress> createState() => _AddEditAddressState();
}

class _AddEditAddressState extends State<AddEditAddress> {
  final _formKey = GlobalKey<FormState>();

  // 1️⃣ Type & Title
  late AddressType _selectedType;
  late TextEditingController _titleController;

  // 2️⃣ Lebanese Geographic Cascading Hierarchy
  List<LebanonGovernorate> _governorates = [];
  LebanonGovernorate? _selectedGovernorate;
  LebanonDistrict? _selectedDistrict;
  String? _selectedTown;
  bool _isLoadingRegions = true;

  // 3️⃣ Street, Building & Notes
  late TextEditingController _streetController;
  late TextEditingController _buildingController;
  late TextEditingController _detailsController;
  late TextEditingController _postalCodeController;

  // 4️⃣ GPS & Coordinates
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  // 5️⃣ Default Status
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final addr = widget.initialAddress;

    _selectedType = addr?.type ?? AddressType.home;
    _titleController = TextEditingController(
      text: addr?.title ?? _selectedType.displayName(isAr: true),
    );

    _streetController = TextEditingController(text: addr?.street ?? '');
    _buildingController = TextEditingController(text: addr?.building ?? '');
    _detailsController = TextEditingController(text: addr?.details ?? '');
    _postalCodeController = TextEditingController(text: addr?.postalCode ?? '');

    _latitude = addr?.latitude;
    _longitude = addr?.longitude;
    _isDefault = addr?.isDefault ?? false;

    _loadLebaneseRegions();
  }

  Future<void> _loadLebaneseRegions() async {
    final list = await LebanonRegionsService.getGovernorates();
    if (!mounted) return;

    setState(() {
      _governorates = list;
      _isLoadingRegions = false;

      final addr = widget.initialAddress;
      if (addr != null && _governorates.isNotEmpty) {
        // Try to match governorate
        final govName = addr.governorate.ar.isNotEmpty
            ? addr.governorate.ar
            : addr.governorate.en;
        if (govName.isNotEmpty) {
          _selectedGovernorate = _governorates.firstWhere(
            (g) => g.nameAr == govName || g.nameEn.toLowerCase() == govName.toLowerCase(),
            orElse: () => _governorates.first,
          );
        } else {
          _selectedGovernorate = _governorates.first;
        }

        // Try to match district
        if (_selectedGovernorate != null && _selectedGovernorate!.districts.isNotEmpty) {
          final distName = addr.district.ar.isNotEmpty
              ? addr.district.ar
              : (addr.region.ar.isNotEmpty ? addr.region.ar : addr.district.en);
          _selectedDistrict = _selectedGovernorate!.districts.firstWhere(
            (d) => d.nameAr == distName || d.nameEn.toLowerCase() == distName.toLowerCase(),
            orElse: () => _selectedGovernorate!.districts.first,
          );
        }

        // Try to match town
        if (_selectedDistrict != null && _selectedDistrict!.towns.isNotEmpty) {
          final townName = addr.town.ar.isNotEmpty
              ? addr.town.ar
              : (addr.city.ar.isNotEmpty ? addr.city.ar : addr.town.en);
          if (_selectedDistrict!.towns.contains(townName)) {
            _selectedTown = townName;
          } else {
            _selectedTown = _selectedDistrict!.towns.first;
          }
        }
      } else if (_governorates.isNotEmpty) {
        _selectedGovernorate = _governorates.first;
        if (_selectedGovernorate!.districts.isNotEmpty) {
          _selectedDistrict = _selectedGovernorate!.districts.first;
          if (_selectedDistrict!.towns.isNotEmpty) {
            _selectedTown = _selectedDistrict!.towns.first;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _detailsController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _onTypeChanged(AddressType type, bool isAr) {
    setState(() {
      _selectedType = type;
      if (_titleController.text.trim().isEmpty ||
          AddressType.values.any((t) => t.displayName(isAr: isAr) == _titleController.text.trim())) {
        _titleController.text = type.displayName(isAr: isAr);
      }
    });
  }

  void _captureGpsLocation(bool isAr) {
    setState(() => _isGettingLocation = true);
    // Simulation / Quick Capture coordinates for Beirut/Lebanon region
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _latitude = 33.8938; // Lebanon / Beirut default coordinates
        _longitude = 35.5018;
        _isGettingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'تم تحديد الإحداثيات الجغرافية بنجاح 📍 (33.8938, 35.5018)'
                : 'GPS coordinates captured successfully 📍 (33.8938, 35.5018)',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
    });
  }

  Future<void> _saveForm(bool isAr) async {
    if (!_formKey.currentState!.validate()) return;

    final govAr = _selectedGovernorate?.nameAr ?? '';
    final govEn = _selectedGovernorate?.nameEn ?? '';
    final distAr = _selectedDistrict?.nameAr ?? '';
    final distEn = _selectedDistrict?.nameEn ?? '';
    final townStr = _selectedTown ?? '';

    final authProvider = context.read<AuthProvider>();
    final addressProvider = context.read<AddressProvider>();
    final effectiveUserId = widget.userId ?? authProvider.currentUser?.id ?? '';
    final effectiveUserType = widget.userType ?? authProvider.currentUser?.role.name ?? 'customer';

    final savedAddress = AddressModel(
      id: widget.initialAddress?.id.isNotEmpty == true
          ? widget.initialAddress!.id
          : 'addr_${DateTime.now().millisecondsSinceEpoch}',
      userId: effectiveUserId,
      userType: effectiveUserType,
      type: _selectedType,
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : _selectedType.displayName(isAr: isAr),
      country: const LocalizedString(ar: 'لبنان', en: 'Lebanon'),
      governorate: LocalizedString(ar: govAr, en: govEn),
      district: LocalizedString(ar: distAr, en: distEn),
      town: LocalizedString(ar: townStr, en: townStr),
      street: _streetController.text.trim(),
      building: _buildingController.text.trim().isNotEmpty ? _buildingController.text.trim() : null,
      details: _detailsController.text.trim().isNotEmpty ? _detailsController.text.trim() : null,
      postalCode: _postalCodeController.text.trim().isNotEmpty ? _postalCodeController.text.trim() : null,
      latitude: _latitude,
      longitude: _longitude,
      isDefault: _isDefault,
    );

    if (effectiveUserId.isNotEmpty) {
      await addressProvider.saveAddress(
        userId: effectiveUserId,
        address: savedAddress,
        userType: effectiveUserType,
      );
    }

    if (widget.onSave != null) {
      widget.onSave!(savedAddress);
    }
    if (mounted) {
      Navigator.of(context).pop(savedAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isMobile = ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);
    final isEditing = widget.initialAddress != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? (isAr ? 'تعديل العنوان' : 'Edit Address')
              : (isAr ? 'إضافة عنوان جديد' : 'Add New Address'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoadingRegions
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ---------------------------------------------------
                        // 1️⃣ تصنيف العنوان (Address Type & Title)
                        // ---------------------------------------------------
                        _buildSectionCard(
                          context,
                          title: isAr ? '1. نوع العنوان والتسمية' : '1. Address Category & Label',
                          icon: Icons.bookmark_border_rounded,
                          children: [
                            Text(
                              isAr ? 'اختر تصنيف العنوان:' : 'Select Address Type:',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: AddressType.values.map((type) {
                                final isSelected = _selectedType == type;
                                IconData iconData;
                                switch (type) {
                                  case AddressType.home:
                                    iconData = Icons.home_rounded;
                                    break;
                                  case AddressType.office:
                                    iconData = Icons.business_rounded;
                                    break;
                                  case AddressType.main:
                                    iconData = Icons.storefront_rounded;
                                    break;
                                  case AddressType.other:
                                    iconData = Icons.location_on_rounded;
                                    break;
                                }

                                return ChoiceChip(
                                  avatar: Icon(
                                    iconData,
                                    size: 18,
                                    color: isSelected ? Colors.white : theme.primaryColor,
                                  ),
                                  label: Text(type.displayName(isAr: isAr)),
                                  selected: isSelected,
                                  selectedColor: theme.primaryColor,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  onSelected: (_) => _onTypeChanged(type, isAr),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: isAr ? 'اسم العنوان المرجعي' : 'Address Title',
                                hintText: isAr ? 'مثال: الفرع الرئيسي، المنزل، مكتب العمل' : 'e.g. Main Branch, Home',
                                prefixIcon: const Icon(Icons.edit_note_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return isAr ? 'يرجى إدخال اسم العنوان' : 'Please enter address title';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ---------------------------------------------------
                        // 2️⃣ التدرج الجغرافي اللبناني (Cascading Selectors)
                        // ---------------------------------------------------
                        _buildSectionCard(
                          context,
                          title: isAr ? '2. المنطقة والموقع في لبنان' : '2. Lebanese Location',
                          icon: Icons.map_outlined,
                          children: [
                            // Country Badge (Read Only: Lebanon)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.flag_outlined, size: 20, color: Colors.red),
                                  const SizedBox(width: 10),
                                  Text(
                                    isAr ? 'الدولة: لبنان 🇱🇧' : 'Country: Lebanon 🇱🇧',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Governorate Dropdown
                            DropdownButtonFormField<LebanonGovernorate>(
                              value: _selectedGovernorate,
                              decoration: InputDecoration(
                                labelText: isAr ? 'المحافظة' : 'Governorate',
                                prefixIcon: const Icon(Icons.account_balance_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: _governorates.map((gov) {
                                return DropdownMenuItem(
                                  value: gov,
                                  child: Text(gov.getName(isAr)),
                                );
                              }).toList(),
                              onChanged: (newGov) {
                                setState(() {
                                  _selectedGovernorate = newGov;
                                  _selectedDistrict = newGov?.districts.isNotEmpty == true
                                      ? newGov!.districts.first
                                      : null;
                                  _selectedTown = _selectedDistrict?.towns.isNotEmpty == true
                                      ? _selectedDistrict!.towns.first
                                      : null;
                                });
                              },
                              validator: (val) => val == null
                                  ? (isAr ? 'يرجى اختيار المحافظة' : 'Select governorate')
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            // District Dropdown
                            DropdownButtonFormField<LebanonDistrict>(
                              value: _selectedDistrict,
                              decoration: InputDecoration(
                                labelText: isAr ? 'القضاء' : 'District',
                                prefixIcon: const Icon(Icons.holiday_village_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: (_selectedGovernorate?.districts ?? []).map((dist) {
                                return DropdownMenuItem(
                                  value: dist,
                                  child: Text(dist.getName(isAr)),
                                );
                              }).toList(),
                              onChanged: (newDist) {
                                setState(() {
                                  _selectedDistrict = newDist;
                                  _selectedTown = newDist?.towns.isNotEmpty == true
                                      ? newDist!.towns.first
                                      : null;
                                });
                              },
                              validator: (val) => val == null
                                  ? (isAr ? 'يرجى اختيار القضاء' : 'Select district')
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            // Town Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedTown,
                              decoration: InputDecoration(
                                labelText: isAr ? 'البلدة / الحي / المدينة' : 'Town / City / Area',
                                prefixIcon: const Icon(Icons.location_city_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: (_selectedDistrict?.towns ?? []).map((town) {
                                return DropdownMenuItem(
                                  value: town,
                                  child: Text(town),
                                );
                              }).toList(),
                              onChanged: (newTown) {
                                setState(() {
                                  _selectedTown = newTown;
                                });
                              },
                              validator: (val) => val == null || val.isEmpty
                                  ? (isAr ? 'يرجى اختيار البلدة / الحي' : 'Select town')
                                  : null,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ---------------------------------------------------
                        // 3️⃣ تفاصيل الشارع والمبنى والعلامة الفارقة
                        // ---------------------------------------------------
                        _buildSectionCard(
                          context,
                          title: isAr ? '3. التفاصيل الدقيقة للعنوان' : '3. Street & Building Details',
                          icon: Icons.signpost_outlined,
                          children: [
                            // Street (Required)
                            TextFormField(
                              controller: _streetController,
                              decoration: InputDecoration(
                                labelText: isAr ? 'اسم الشارع *' : 'Street Name *',
                                hintText: isAr ? 'مثال: شارع الحمرا الرئيسي، أوتوستراد جل الديب' : 'e.g. Main Hamra Street',
                                prefixIcon: const Icon(Icons.add_road_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return isAr ? 'يرجى كتابة اسم الشارع' : 'Please enter street name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Building & Floor (Optional)
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _buildingController,
                                    decoration: InputDecoration(
                                      labelText: isAr ? 'المبنى / الطابق' : 'Building / Floor',
                                      hintText: isAr ? 'مثال: بناية السنتر، طابق 3' : 'e.g. Center Bldg, 3rd Floor',
                                      prefixIcon: const Icon(Icons.domain_rounded),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _postalCodeController,
                                    decoration: InputDecoration(
                                      labelText: isAr ? 'الرمز البريدي' : 'Postal Code',
                                      hintText: '1100',
                                      prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Extra details / Landmark (Optional)
                            TextFormField(
                              controller: _detailsController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: isAr ? 'علامة فارقة / ملاحظات التوصيل' : 'Landmark / Delivery Notes',
                                hintText: isAr
                                    ? 'مثال: قرب صيدلية السلام، المدخل الخلفي بجانب البنك'
                                    : 'e.g. Near pharmacy, back entrance',
                                prefixIcon: const Icon(Icons.notes_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ---------------------------------------------------
                        // 4️⃣ الإحداثيات الجغرافية (GPS & Map Coordinates)
                        // ---------------------------------------------------
                        _buildSectionCard(
                          context,
                          title: isAr ? '4. الموقع على الخريطة (GPS)' : '4. Map Pinning (GPS)',
                          icon: Icons.my_location_rounded,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isGettingLocation ? null : () => _captureGpsLocation(isAr),
                                    icon: _isGettingLocation
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.gps_fixed),
                                    label: Text(
                                      isAr ? 'التقاط موقعي الحالي عبر GPS' : 'Capture Current GPS',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_latitude != null && _longitude != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Lat: ${_latitude!.toStringAsFixed(4)}, Long: ${_longitude!.toStringAsFixed(4)}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                                      onPressed: () => setState(() {
                                        _latitude = null;
                                        _longitude = null;
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ---------------------------------------------------
                        // 5️⃣ التفضيلات والحفظ (Default & Save)
                        // ---------------------------------------------------
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                          ),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              isAr ? 'تعيين كعنوان افتراضي' : 'Set as Default Address',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              isAr
                                  ? 'سيتم استخدام هذا العنوان تلقائياً في الشحن والطلبات'
                                  : 'This address will be auto-selected for checkout',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            value: _isDefault,
                            onChanged: (val) => setState(() => _isDefault = val),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(isAr ? 'إلغاء' : 'Cancel'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () => _saveForm(isAr),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  isEditing
                                      ? (isAr ? 'حفظ التعديلات' : 'Save Changes')
                                      : (isAr ? 'إضافة العنوان' : 'Add Address'),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
}
