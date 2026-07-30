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

class _StoreOwnerProfilePageState extends State<StoreOwnerProfilePage> {
  // Personal Info Form Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();

  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final user = context.watch<AuthProvider>().currentUser;
      if (user != null) {
        _fullNameController.text = user.name.isNotEmpty ? user.name : 'صاحب المتجر';
        _emailController.text = user.email;
        _phoneController.text = (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
            ? user.phoneNumber!
            : '+961 70 123 456';
      } else {
        _fullNameController.text = 'مالك المتجر';
        _emailController.text = 'owner@mystore.com';
        _phoneController.text = '+961 70 123 456';
      }
      _jobTitleController.text = 'مالك ورئيس مجلس إدارة المتجر';
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    await authProvider.updateUserProfile(
      name: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('تم حفظ وتحديث بيانات البروفايل الشخصي بنجاح!'),
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
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  // Sign Out Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                    label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Save Button
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
                    const SizedBox(height: 24),

                    // Single Main Tab: Personal Info
                    _buildPersonalInfoTab(theme),
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
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
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
                      _fullNameController.text.isNotEmpty ? _fullNameController.text : 'صاحب المتجر',
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
                  'اسم المتجر المرتبط: $storeName | عضو معتمد في المنصة',
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
          const Text('البيانات الشخصية ورابط التواصل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  readOnly: true,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني للإدارة (غير قابل للتعديل)',
                    prefixIcon: Icon(Icons.email_outlined),
                    helperText: 'لا يمكن تغيير البريد الإلكتروني لمنع فقدان الوصول للمتجر',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الجوال للتواصل الإداري (لبناني +961)',
                    hintText: '+961 70 123 456',
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
}
