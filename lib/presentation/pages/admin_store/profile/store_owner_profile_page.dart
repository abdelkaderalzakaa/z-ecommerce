import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/company_provider.dart';
import '../../../global/translate/app_localizations.dart';
import '../../../global/translate/translation_keys.dart';

class StoreOwnerProfilePage extends StatefulWidget {
  const StoreOwnerProfilePage({super.key});

  @override
  State<StoreOwnerProfilePage> createState() => _StoreOwnerProfilePageState();
}

class _StoreOwnerProfilePageState extends State<StoreOwnerProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Personal Info Form Controllers
  final TextEditingController _fullNameController =
      TextEditingController(text: 'عبدالقادر الزكاء');
  final TextEditingController _emailController =
      TextEditingController(text: 'owner@mystore.com');
  final TextEditingController _phoneController =
      TextEditingController(text: '+966 50 123 4567');
  final TextEditingController _jobTitleController =
      TextEditingController(text: 'مالك ورئيس مجلس إدارة المتجر');

  // Business Info Form Controllers
  final TextEditingController _taxIdController =
      TextEditingController(text: '310123456700003');
  final TextEditingController _crNumberController =
      TextEditingController(text: '1010887766');
  final TextEditingController _storeAddressController =
      TextEditingController(text: 'المملكة العربية السعودية - الرياض - حي العليا');

  // Password Change Controllers
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Notification Toggles
  bool _emailOrderAlerts = true;
  bool _smsLowStockAlerts = true;
  bool _weeklyReportAlerts = true;
  bool _twoFactorAuthEnabled = true;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _taxIdController.dispose();
    _crNumberController.dispose();
    _storeAddressController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('تم حفظ وتحديث بيانات البروفايل الشخصي والمهني بنجاح!'),
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final companyProvider = Provider.of<CompanyProvider>(context);
    final companySettings = companyProvider.companySettings;
    final storeTheme = companySettings?.theme;
    final storeName = companySettings?.name.ar ?? 'متجري الرقمي';
    final storeLogo = storeTheme?.logoUrl;

    return Scaffold(
      backgroundColor: storeTheme?.backgroundColorValue ?? theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Page Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: storeTheme?.surfaceColorValue ?? theme.cardColor,
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                ),
              ),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    Container(
                      margin: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'تراجع والعودة',
                      ),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationKeys.storeOwnerProfileTitle.tr(context),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        TranslationKeys.storeOwnerProfileSubtitle.tr(context),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _handleSaveProfile,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: Text(_isSaving ? '...' : TranslationKeys.saveChanges.tr(context)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Top Owner Card & Quick Stats Banner
                    _buildOwnerCardHeader(theme, storeName, storeLogo),
                    const SizedBox(height: 20),

                    // Custom Tab Header Bar
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: theme.primaryColor,
                        unselectedLabelColor: theme.textTheme.bodyMedium?.color,
                        indicatorColor: theme.primaryColor,
                        indicatorWeight: 3,
                        tabs: [
                          Tab(icon: const Icon(Icons.person_rounded, size: 18), text: TranslationKeys.personalInfoTab.tr(context)),
                          Tab(icon: const Icon(Icons.business_center_rounded, size: 18), text: TranslationKeys.ownershipInfoTab.tr(context)),
                          Tab(icon: const Icon(Icons.security_rounded, size: 18), text: TranslationKeys.securityTab.tr(context)),
                          Tab(icon: const Icon(Icons.notifications_active_rounded, size: 18), text: TranslationKeys.notificationsTab.tr(context)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tab Views Box
                    SizedBox(
                      height: 520,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPersonalInfoTab(theme),
                          _buildOwnershipInfoTab(theme),
                          _buildSecurityTab(theme),
                          _buildNotificationsTab(theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerCardHeader(ThemeData theme, String storeName, String? storeLogo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.primaryColor.withOpacity(0.12),
                backgroundImage: storeLogo != null ? NetworkImage(storeLogo) : null,
                child: storeLogo == null
                    ? Icon(Icons.person_rounded, size: 36, color: theme.primaryColor)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _fullNameController.text,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars_rounded, size: 14, color: theme.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            'صاحب المتجر المعتمد (Store Owner)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'اسم المتجر المرتبط: $storeName | عضو منذ 2024',
                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('البيانات الشخصية ورابط التواصل', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _jobTitleController,
                  decoration: const InputDecoration(
                    labelText: 'المسمى الوظيفي الإداري',
                    prefixIcon: Icon(Icons.work_outline_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني للإدارة',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الجوال للتواصل الإداري',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOwnershipInfoTab(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('بيانات السجل التجاري والملكية القانونية للمتجر', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _crNumberController,
                  decoration: const InputDecoration(
                    labelText: 'رقم السجل التجاري (CR Number)',
                    prefixIcon: Icon(Icons.verified_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _taxIdController,
                  decoration: const InputDecoration(
                    labelText: 'الرقم الضريبي (Vat Tax ID)',
                    prefixIcon: Icon(Icons.receipt_long_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _storeAddressController,
            decoration: const InputDecoration(
              labelText: 'عنوان مقر الإدارة الرئيسي',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('إعدادات الأمان وتغيير كلمة المرور', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('تفعيل التحقق بخطوتين (2FA Security)'),
            subtitle: const Text('إرسال رمز تحقق لجوالك عند تسجيل الدخول من أجهزة جديدة'),
            value: _twoFactorAuthEnabled,
            onChanged: (val) => setState(() => _twoFactorAuthEnabled = val),
            activeColor: theme.primaryColor,
          ),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _currentPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور الحالية',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    prefixIcon: Icon(Icons.lock_reset_rounded),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('إعدادات الإشعارات والتنبيهات المباشرة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('إشعارات الطلبات الجديدة الفورية'),
            subtitle: const Text('تنبيه فوري عبر البريد واللوحة عند إتمام عميل لطلب جديد'),
            value: _emailOrderAlerts,
            onChanged: (val) => setState(() => _emailOrderAlerts = val),
            activeColor: theme.primaryColor,
          ),
          SwitchListTile(
            title: const Text('تنبيهات استنفاد كميات المنتجات'),
            subtitle: const Text('إرسال إشعار عندما تقل كمية أي منتج عن 5 قطع في المخزن'),
            value: _smsLowStockAlerts,
            onChanged: (val) => setState(() => _smsLowStockAlerts = val),
            activeColor: theme.primaryColor,
          ),
          SwitchListTile(
            title: const Text('التقرير الأسبوعي للأداء والمبيعات'),
            subtitle: const Text('ملخص أسبوعي شامل لإجمالي الإيرادات والنمو عبر البريد'),
            value: _weeklyReportAlerts,
            onChanged: (val) => setState(() => _weeklyReportAlerts = val),
            activeColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }
}
