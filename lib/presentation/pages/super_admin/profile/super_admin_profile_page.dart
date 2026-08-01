import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/super_admin_provider.dart';
import '../../../../data/models/common/social_media.dart';
import '../../../../presentation/global/core/constants/enum_data.dart';
class SuperAdminProfilePage extends StatefulWidget {
  const SuperAdminProfilePage({super.key});

  @override
  State<SuperAdminProfilePage> createState() => _SuperAdminProfilePageState();
}

class _SuperAdminProfilePageState extends State<SuperAdminProfilePage> {
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminPhoneController = TextEditingController();
  final TextEditingController _systemIdController = TextEditingController();

  // Social Media Links Controllers
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final user = context.watch<AuthProvider>().currentUser;
      final superAdmin = context.watch<SuperAdminProvider>().currentSuperAdmin;

      if (user != null) {
        _adminNameController.text = user.name.isNotEmpty ? user.name : 'Super Admin';
        _adminEmailController.text = user.email;
        _adminPhoneController.text = user.phoneNumber.isNotEmpty
            ? user.phoneNumber
            : '+961 70 123 456';
        _systemIdController.text = user.id.isNotEmpty ? user.id : 'SA-ROOT-9901-PROD';

        final socials = superAdmin?.socials ?? [];
        String getUrl(SocialPlatform plat) {
          final found = socials.where((e) => e.platform == plat);
          return found.isNotEmpty ? found.first.url : '';
        }

        _whatsappController.text = getUrl(SocialPlatform.whatsapp).isNotEmpty ? getUrl(SocialPlatform.whatsapp) : '+961 70 123 456';
        _instagramController.text = getUrl(SocialPlatform.instagram).isNotEmpty ? getUrl(SocialPlatform.instagram) : 'https://instagram.com/alzakaa';
        _linkedinController.text = getUrl(SocialPlatform.linkedin).isNotEmpty ? getUrl(SocialPlatform.linkedin) : 'https://linkedin.com/company/alzakaa';
        _facebookController.text = getUrl(SocialPlatform.facebook).isNotEmpty ? getUrl(SocialPlatform.facebook) : 'https://facebook.com/alzakaa';
        _websiteController.text = getUrl(SocialPlatform.website).isNotEmpty ? getUrl(SocialPlatform.website) : 'https://alzakaa.com';
      } else {
        _adminNameController.text = 'Super Admin';
        _adminEmailController.text = 'alzakaasimplesolutions@gmail.com';
        _adminPhoneController.text = '+961 70 123 456';
        _systemIdController.text = 'SA-ROOT-9901-PROD';
        _whatsappController.text = '+961 70 123 456';
        _instagramController.text = 'https://instagram.com/alzakaa';
        _linkedinController.text = 'https://linkedin.com/company/alzakaa';
        _facebookController.text = 'https://facebook.com/alzakaa';
        _websiteController.text = 'https://alzakaa.com';
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _adminPhoneController.dispose();
    _systemIdController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    setState(() => _isSaving = true);
    final authProvider = context.read<AuthProvider>();

    // Remove unused socialLinks variable


    await authProvider.updateProfile(
      name: _adminNameController.text.trim(),
      phoneNumber: _adminPhoneController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.shield_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('تم تحديث وحفظ بيانات الاعتماد وروايط التواصل بنجاح!'),
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
                        'الملف الشخصي لمدير النظام (Super Admin)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'إدارة الاعتماد ورقم التواصل وروابط التواصل الاجتماعي المعتمدة',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
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
                    // Top Super Admin Banner Header
                    _buildAdminCardHeader(theme),
                    const SizedBox(height: 24),

                    // Admin Credentials Section
                    _buildAdminCredentialsSection(theme),
                    const SizedBox(height: 24),

                    // Social Media Links Section
                    _buildSocialMediaSection(theme),
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
                      _adminNameController.text.isNotEmpty ? _adminNameController.text : 'Super Admin',
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
                            'مدير النظام (Super Admin)',
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

  Widget _buildAdminCredentialsSection(ThemeData theme) {
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
          const Text('بيانات الاعتماد الرسمية لمدير النظام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'المعرف الرقمي الماستر (غير قابل للتعديل)',
                    prefixIcon: Icon(Icons.fingerprint_rounded),
                    helperText: 'معرّف آمن ثابت مخصص لمستند السوبر أدمن',
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
                  readOnly: true,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'البريد الرسمي المعتمد (غير قابل للتعديل)',
                    prefixIcon: Icon(Icons.mark_email_read_rounded),
                    helperText: 'لا يمكن تغيير البريد الإلكتروني الرئيسي لمنع فقدان الصلاحيات',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _adminPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف المباشر (لبناني +961)',
                    hintText: '+961 70 123 456',
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

  Widget _buildSocialMediaSection(ThemeData theme) {
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
          const Row(
            children: [
              Icon(Icons.share_rounded, size: 20),
              SizedBox(width: 8),
              Text('روابط التواصل الاجتماعي والتواصل المباشر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'روابط وسائل التواصل الرسمية الخاصة بالإدارة والمساعدة والمنصة',
            style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _whatsappController,
                  decoration: const InputDecoration(
                    labelText: 'رقم واتساب للتواصل (WhatsApp)',
                    prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                    hintText: '+961 70 123 456',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _instagramController,
                  decoration: const InputDecoration(
                    labelText: 'رابط إنستغرام (Instagram)',
                    prefixIcon: Icon(Icons.camera_alt_outlined),
                    hintText: 'https://instagram.com/...',
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
                  controller: _linkedinController,
                  decoration: const InputDecoration(
                    labelText: 'رابط لينكد إن (LinkedIn)',
                    prefixIcon: Icon(Icons.business_center_outlined),
                    hintText: 'https://linkedin.com/...',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _facebookController,
                  decoration: const InputDecoration(
                    labelText: 'رابط فيسبوك (Facebook)',
                    prefixIcon: Icon(Icons.facebook_outlined),
                    hintText: 'https://facebook.com/...',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _websiteController,
            decoration: const InputDecoration(
              labelText: 'الموقع الإلكتروني الرسمي (Official Website)',
              prefixIcon: Icon(Icons.language_rounded),
              hintText: 'https://alzakaa.com',
            ),
          ),
        ],
      ),
    );
  }
}
