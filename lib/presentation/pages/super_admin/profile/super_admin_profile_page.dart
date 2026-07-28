import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/auth_provider.dart';

class SuperAdminProfilePage extends StatefulWidget {
  const SuperAdminProfilePage({super.key});

  @override
  State<SuperAdminProfilePage> createState() => _SuperAdminProfilePageState();
}

class _SuperAdminProfilePageState extends State<SuperAdminProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _adminNameController =
      TextEditingController(text: 'سوبر ادمن النظام الأقصى (Master Super Admin)');
  final TextEditingController _adminEmailController =
      TextEditingController(text: 'superadmin@platform.com');
  final TextEditingController _adminPhoneController =
      TextEditingController(text: '+966 55 000 9999');
  final TextEditingController _systemIdController =
      TextEditingController(text: 'SA-ROOT-9901-PROD');

  bool _systemOutageAlerts = true;
  bool _newStoreSignupAlerts = true;
  bool _criticalErrorLogAlerts = true;
  bool _masterPasskeyEnabled = true;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _adminPhoneController.dispose();
    _systemIdController.dispose();
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
              Icon(Icons.shield_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('تم تحديث وحفظ بيانات واعتمادات مدير النظام الأقصى بنجاح!'),
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Page Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
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
                      const Text(
                        'الملف الشخصي لمدير النظام الأقصى (Super Admin)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'إدارة واعتمادات أعلى مستوى صلاحيات بالنظام وسجلات الأمان العامة',
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
                    label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ التعديلات'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Top Super Admin Profile Banner Card
                    _buildAdminCardHeader(theme),
                    const SizedBox(height: 20),

                    // Custom Tab Bar
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
                        tabs: const [
                          Tab(icon: Icon(Icons.badge_rounded, size: 18), text: 'اعتمادات المدير'),
                          Tab(icon: Icon(Icons.admin_panel_settings_rounded, size: 18), text: 'مصفوفة الصلاحيات'),
                          Tab(icon: Icon(Icons.gavel_rounded, size: 18), text: 'سجل الأمان والعمليات'),
                          Tab(icon: Icon(Icons.dvr_rounded, size: 18), text: 'تنبيهات المنصة'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tab View Box
                    SizedBox(
                      height: 520,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAdminCredentialsTab(theme),
                          _buildPermissionsMatrixTab(theme),
                          _buildSecurityAuditLogsTab(theme),
                          _buildPlatformAlertsTab(theme),
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

  Widget _buildAdminCardHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
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
                radius: 38,
                backgroundColor: theme.primaryColor,
                child: const Icon(Icons.shield_rounded, size: 40, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.key_rounded, size: 14, color: Colors.white),
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
                      _adminNameController.text,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded, size: 14, color: Color(0xFFDC2626)),
                          SizedBox(width: 4),
                          Text(
                            'مدير النظام الأقصى (Super Admin)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'مستوى الصلاحيات: Full System Authority Access | مستوى الأمان: 99.8% High Security',
                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCredentialsTab(ThemeData theme) {
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
          const Text('بيانات الاعتماد الرسمية لمدير النظام', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _adminNameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الرسمي لمدير المنصة',
                    prefixIcon: Icon(Icons.person_pin_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _systemIdController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'المعرف الرقمي الماستر (System ID)',
                    prefixIcon: Icon(Icons.fingerprint_rounded),
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
                  controller: _adminEmailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الرسمي المعتمد للمنصة',
                    prefixIcon: Icon(Icons.mark_email_read_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _adminPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف المباشر للطوارئ',
                    prefixIcon: Icon(Icons.phone_in_talk_rounded),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsMatrixTab(ThemeData theme) {
    final permissions = [
      {'name': 'إدارة المتاجر وحظر الحسابات', 'desc': 'صلاحية كاملة لإنشاء، تعديل، إيقاف، أو تعليق المتاجر', 'active': true},
      {'name': 'إدارة العمولات والاشتراكات', 'desc': 'التحكم بنسب العمولات وخطط الباقات المالية الفعالة', 'active': true},
      {'name': 'إدارة أدوار المشرفين والمستخدمين', 'desc': 'منح وسحب الصلاحيات الإدارية لجميع مدراء النظام', 'active': true},
      {'name': 'الاطلاع على السجلات الحساسة (Audit Logs)', 'desc': 'استعراض كافة السجلات الأمنية والتحركات بالمنصة', 'active': true},
    ];

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
          const Text('مصفوفة الصلاحيات العليا الممنوحة لحسابك', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: permissions.length,
              separatorBuilder: (_, _) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = permissions[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: Icon(Icons.check_circle_rounded, color: theme.primaryColor, size: 20),
                  ),
                  title: Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(item['desc'] as String, style: const TextStyle(fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('مُفعلة 100%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityAuditLogsTab(ThemeData theme) {
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
          const Text('سجل الأمان والنشاطات الإدارية الأخيرة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('تفعيل مفتاح الأمان البيومتري (Passkey Security)'),
            subtitle: const Text('طلب بصمة الأصبع أو الوجه قبل إجراء أي عملية حساسة بالمنصة'),
            value: _masterPasskeyEnabled,
            onChanged: (val) => setState(() => _masterPasskeyEnabled = val),
            activeColor: theme.primaryColor,
          ),
          const Divider(),
          const SizedBox(height: 10),
          const Text('سجل الدخول والتحركات الأخير:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🔐 تسجيل دخول ناجح - IP: 197.230.12.88', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('اليوم 12:44 م', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🛡️ تعديل خطة اشتراك متجر "الأنشطة المودرن"', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('أمس 08:30 م', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformAlertsTab(ThemeData theme) {
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
          const Text('إعدادات تنبيهات وإشعارات المنصة الشاملة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('تنبيهات حالة السيرفرات وتوقف الخدمات'),
            subtitle: const Text('إرسال تنبيه فوري عاجل في حال حدوث أي بطء أو انقطاع بالنظام'),
            value: _systemOutageAlerts,
            onChanged: (val) => setState(() => _systemOutageAlerts = val),
            activeColor: theme.primaryColor,
          ),
          SwitchListTile(
            title: const Text('إشعارات انضمام المتاجر الجديدة'),
            subtitle: const Text('تنبيه عند قيام تاجر جديد بإنشاء متجر على المنصة'),
            value: _newStoreSignupAlerts,
            onChanged: (val) => setState(() => _newStoreSignupAlerts = val),
            activeColor: theme.primaryColor,
          ),
          SwitchListTile(
            title: const Text('سجلات الأخطاء والـ Critical Logs'),
            subtitle: const Text('توجيه إشعارات الأخطاء البرمجية الحرجة فور حدوثها بالخادم'),
            value: _criticalErrorLogAlerts,
            onChanged: (val) => setState(() => _criticalErrorLogAlerts = val),
            activeColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }
}
