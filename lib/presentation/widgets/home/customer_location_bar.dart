import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/providers/address_provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/services/lebanon_regions_service.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_colors.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/pages/add_edit_address.dart';

class CustomerLocationBar extends StatelessWidget {
  final bool isCompact;

  const CustomerLocationBar({
    super.key,
    this.isCompact = false,
  });

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _LocationPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LocaleProvider>().locale.languageCode == 'ar';
    final businessProvider = context.watch<BusinessProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final theme = Theme.of(context);

    // إذا لم يكن هناك موقع نشط محدد في businessProvider، نأخذ العنوان الافتراضي للمستخدم تلقائياً
    final activeLocation = businessProvider.activeCustomerLocation ?? addressProvider.defaultAddress;

    String locationLabel = isAr ? 'حدد موقعك للتوصيل' : 'Set delivery location';
    String subLabel = isAr ? 'لعرض المتاجر الأقرب إليك والتوصيل المتاح' : 'To see nearest stores & delivery reach';

    if (activeLocation != null && activeLocation.town.isNotEmpty) {
      final town = activeLocation.town.get(context);
      final dist = activeLocation.district.get(context);
      locationLabel = town.isNotEmpty ? (dist.isNotEmpty ? '$town، $dist' : town) : activeLocation.title;
      subLabel = activeLocation.street.isNotEmpty ? activeLocation.street : (isAr ? 'موقعك النشط' : 'Active Location');
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activeLocation != null
              ? theme.primaryColor.withOpacity(0.3)
              : AppColors.cardBorder,
          width: activeLocation != null ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLocationPicker(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (activeLocation != null
                            ? theme.primaryColor
                            : AppColors.textMuted)
                        .withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    activeLocation != null
                        ? Icons.delivery_dining_rounded
                        : Icons.location_on_outlined,
                    size: 22,
                    color: activeLocation != null
                        ? theme.primaryColor
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            isAr ? 'التوصيل إلى: ' : 'Deliver to: ',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              locationLabel,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (!isCompact) ...[
                        const SizedBox(height: 2),
                        Text(
                          subLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: activeLocation != null
                                ? theme.primaryColor.withOpacity(0.85)
                                : AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isAr ? 'تغيير' : 'Change',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: theme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet();

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  final LebanonRegionsService _regionsService = LebanonRegionsService();
  List<LebanonGovernorate> _governorates = [];
  LebanonGovernorate? _selectedGov;
  LebanonDistrict? _selectedDist;
  String? _selectedTown;
  bool _isLoadingRegions = true;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    try {
      final govs = await _regionsService.loadRegions();
      if (mounted) {
        setState(() {
          _governorates = govs;
          _isLoadingRegions = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRegions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LocaleProvider>().locale.languageCode == 'ar';
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final businessProvider = context.watch<BusinessProvider>();
    final user = authProvider.currentUser;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  isAr ? 'تحديد موقع التوصيل والتسوق' : 'Select Delivery & Shopping Location',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // SECTION 1: Saved Addresses (If Logged In)
                if (user != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAr ? 'عناوينك المحفوظة' : 'Your Saved Addresses',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(isAr ? 'إضافة عنوان' : 'Add Address'),
                        onPressed: () {
                          Navigator.pop(context);
                          changeScreen(
                            context,
                            AddEditAddress(
                              userId: user.id,
                              userType: 'customer',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (addressProvider.addresses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        isAr
                            ? 'ليس لديك عناوين مسجلة بعد. يمكنك اختيار البلدة بالأسفل أو إضافة عنوان.'
                            : 'No saved addresses yet. Pick a town below or add an address.',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    )
                  else
                    ...addressProvider.addresses.map((addr) {
                      final isSelected = businessProvider.activeCustomerLocation?.id == addr.id ||
                          (businessProvider.activeCustomerLocation == null && addr.isDefault);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.primaryColor.withOpacity(0.08)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? theme.primaryColor
                                : AppColors.cardBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            addr.type == AddressType.home
                                ? Icons.home_rounded
                                : addr.type == AddressType.office
                                    ? Icons.work_rounded
                                    : Icons.location_on_rounded,
                            color: isSelected ? theme.primaryColor : AppColors.textMuted,
                          ),
                          title: Text(
                            addr.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? theme.primaryColor : null,
                            ),
                          ),
                          subtitle: Text(
                            addr.getFormattedAddress(langCode: isAr ? 'ar' : 'en'),
                            style: const TextStyle(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: theme.primaryColor)
                              : null,
                          onTap: () {
                            businessProvider.setActiveCustomerLocation(addr);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                ],

                // SECTION 2: Manual Geographic Selection (Lebanon Regions)
                Text(
                  isAr ? 'أو اختر البلدة / المنطقة مباشرة:' : 'Or Select Town / Area directly:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),

                if (_isLoadingRegions)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ))
                else ...[
                  // 1. Governorate
                  DropdownButtonFormField<LebanonGovernorate>(
                    value: _selectedGov,
                    decoration: InputDecoration(
                      labelText: isAr ? 'المحافظة' : 'Governorate',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _governorates.map((g) {
                      return DropdownMenuItem(
                        value: g,
                        child: Text(g.getName(isAr)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedGov = val;
                        _selectedDist = null;
                        _selectedTown = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // 2. District
                  if (_selectedGov != null)
                    DropdownButtonFormField<LebanonDistrict>(
                      value: _selectedDist,
                      decoration: InputDecoration(
                        labelText: isAr ? 'القضاء' : 'District',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: _selectedGov!.districts.map((d) {
                        return DropdownMenuItem(
                          value: d,
                          child: Text(d.getName(isAr)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedDist = val;
                          _selectedTown = null;
                        });
                      },
                    ),
                  const SizedBox(height: 12),

                  // 3. Town
                  if (_selectedDist != null)
                    DropdownButtonFormField<String>(
                      value: _selectedTown,
                      decoration: InputDecoration(
                        labelText: isAr ? 'البلدة / الحي' : 'Town / Area',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: _selectedDist!.towns.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedTown = val;
                        });
                      },
                    ),

                  const SizedBox(height: 20),

                  // Apply Manual Selection Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      isAr ? 'تطبيق الموقع المختار' : 'Apply Selected Location',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: (_selectedGov != null && _selectedDist != null && _selectedTown != null)
                        ? () {
                            final manualAddress = AddressModel(
                              id: 'temp_location_${DateTime.now().millisecondsSinceEpoch}',
                              userId: user?.id ?? 'guest',
                              userType: 'customer',
                              title: _selectedTown!,
                              country: const LocalizedString(ar: 'لبنان', en: 'Lebanon'),
                              governorate: LocalizedString(ar: _selectedGov!.nameAr, en: _selectedGov!.nameEn),
                              district: LocalizedString(ar: _selectedDist!.nameAr, en: _selectedDist!.nameEn),
                              town: LocalizedString(ar: _selectedTown!, en: _selectedTown!),
                              street: '',
                              isDefault: true,
                            );

                            businessProvider.setActiveCustomerLocation(manualAddress);
                            Navigator.pop(context);
                          }
                        : null,
                  ),

                  // Clear Filter Button
                  if (businessProvider.activeCustomerLocation != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      icon: const Icon(Icons.clear, size: 16),
                      label: Text(isAr ? 'إلغاء التحديد وعرض كل لبنان' : 'Clear & Show All Lebanon'),
                      onPressed: () {
                        businessProvider.setActiveCustomerLocation(null);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
