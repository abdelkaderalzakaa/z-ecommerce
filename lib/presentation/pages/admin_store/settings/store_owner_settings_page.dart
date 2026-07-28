import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/admin_store/branding/restaurant_menu_branding_page.dart';
import 'package:z_ecommerce/presentation/pages/admin_store/branding/store_branding_page.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class StoreOwnerSettingsPage extends StatefulWidget {
  const StoreOwnerSettingsPage({super.key});

  @override
  State<StoreOwnerSettingsPage> createState() => _StoreOwnerSettingsPageState();
}

class _StoreOwnerSettingsPageState extends State<StoreOwnerSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Store Identity Controllers
  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _sloganController;
  late TextEditingController _descriptionController;

  // Contact Info Controllers
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _deliveryFeeController;

  // Social Media Links Controllers
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _whatsappController;
  late TextEditingController _twitterController;
  late TextEditingController _tiktokController;
  late TextEditingController _linkedinController;
  late TextEditingController _youtubeController;

  // Payment Toggles
  bool _isSubmitting = false;
  bool _enableCod = true;
  bool _enableWishMoney = true;
  bool _enableOmt = true;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController(text: 'متجري التجاري');
    _nameEnController = TextEditingController(text: 'My Commercial Store');
    _sloganController = TextEditingController(text: 'أفخم التشكيلات المودرن');
    _descriptionController = TextEditingController(text: 'متجر متخصص بتقديم أحدث المنتجات بجودة عالية وأسعار منافسة');
    _emailController = TextEditingController(text: 'owner@mystore.com');
    _phoneController = TextEditingController(text: '+961 70 123 456');
    _deliveryFeeController = TextEditingController(text: '5.0');

    // Social Media Defaults
    _facebookController = TextEditingController(text: 'https://facebook.com/mystore');
    _instagramController = TextEditingController(text: 'https://instagram.com/mystore');
    _whatsappController = TextEditingController(text: '+96170123456');
    _twitterController = TextEditingController(text: 'https://x.com/mystore');
    _tiktokController = TextEditingController(text: 'https://tiktok.com/@mystore');
    _linkedinController = TextEditingController(text: 'https://linkedin.com/company/mystore');
    _youtubeController = TextEditingController(text: 'https://youtube.com/@mystore');
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _sloganController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _deliveryFeeController.dispose();

    _facebookController.dispose();
    _instagramController.dispose();
    _whatsappController.dispose();
    _twitterController.dispose();
    _tiktokController.dispose();
    _linkedinController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ وتحديث كافة إعدادات الهوية والتواصل بنجاح!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AddEditTemplate(
      title: 'إعدادات متجري الشاملة',
      subtitle: 'تعديل الهوية، الشعار، ألوان الثيم، التواصل وشبكات التواصل الاجتماعي',
      isEditMode: true,
      formKey: _formKey,
      submitLabel: TranslationKeys.saveChanges.tr(context),
      submitIcon: Icons.save_rounded,
      onSubmit: _submit,
      isSubmitting: _isSubmitting,
      cancelLabel: TranslationKeys.cancel.tr(context),
      sections: [
        // 1. Store Identity Section
        FormSection(
          title: 'هوية واسم المتجر',
          subtitle: 'اسم المتجر باللغتين العربية والإنجليزية والشعار اللفظي والوصف',
          icon: Icons.storefront_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameArController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المتجر (عربي)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language, size: 20),
                    ),
                    validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _nameEnController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المتجر (إنجليزي)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language, size: 20),
                    ),
                    validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _sloganController,
              decoration: const InputDecoration(
                labelText: 'الشعار اللفظي (Slogan)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.auto_awesome_rounded, size: 20),
              ),
            ),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'وصف المتجر',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined, size: 20),
              ),
            ),
          ],
        ),

        // 2. Visual Theme & Branding Studios (زرين منفصلين كلياً)
        FormSection(
          title: 'استوديوهات الهوية والتصميم المباشر (Branding & Menu Studios)',
          subtitle: 'خصص هوية المتجر العامة وثيم الألوان، أو خصص منيو المطعم الرقمي بشكل مستقل',
          icon: Icons.palette_rounded,
          fields: [
            // Button 1: Store General UI Branding Studio
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.08),
                    Theme.of(context).primaryColor.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.palette_rounded, size: 28, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'استوديو تخصيص الهوية وثيم المتجر المباشر (Store Theme Studio)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'تحكم بالدرجات والألوان الرئيسية والفرعية، روابط اللوجو والغلاف، الخطوط العربي والإنجليزي، انحناءات الأزرار للكروت مع معاينة حية.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => changeScreen(context, const StoreBrandingPage()),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text(
                      'تخصيص الهوية والثيم الآن',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Button 2: Dedicated Digital Restaurant Menu Studio
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepOrange.withOpacity(0.08),
                    Colors.deepOrange.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.deepOrange.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant_menu_rounded, size: 28, color: Colors.deepOrange),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'استوديو تخصيص منيو المطعم الرقمي (Restaurant Menu Studio)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'استوديو مخصص للمطاعم والكافيهات لتنسيق المنيو الرقمي، السعرات الحرارية، مكونات الحساسية، والطلب المباشر للطاولة بالـ QR.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => changeScreen(context, const RestaurantMenuBrandingPage()),
                    icon: const Icon(Icons.restaurant_rounded, size: 18),
                    label: const Text(
                      'تخصيص المنيو الرقمي الآن',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // 3. Social Media Links Section
        FormSection(
          title: 'شبكات ومنصات التواصل الاجتماعي (Social Media Links)',
          subtitle: 'روابط صفحات ومواقع التواصل المباشرة الخاصة بمتجرك',
          icon: Icons.share_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _facebookController,
                    decoration: const InputDecoration(
                      labelText: 'فيسبوك (Facebook URL)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.facebook, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _instagramController,
                    decoration: const InputDecoration(
                      labelText: 'إنستغرام (Instagram URL)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.camera_alt_outlined, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _whatsappController,
                    decoration: const InputDecoration(
                      labelText: 'واتساب مباشر (WhatsApp Number)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.chat_bubble_outline_rounded, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _twitterController,
                    decoration: const InputDecoration(
                      labelText: 'تويتر / منصة X (Twitter URL)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag_rounded, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tiktokController,
                    decoration: const InputDecoration(
                      labelText: 'تيك توك (TikTok URL)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.music_note_rounded, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _linkedinController,
                    decoration: const InputDecoration(
                      labelText: 'لينكد إن (LinkedIn URL)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business_center_outlined, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _youtubeController,
              decoration: const InputDecoration(
                labelText: 'قناة يوتيوب (YouTube Channel URL)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.play_circle_outline_rounded, size: 20),
              ),
            ),
          ],
        ),

        // 4. Financial & Payment Section
        FormSection(
          title: 'الإعدادات المالية ووسائل الدفع المفعلة',
          subtitle: 'رسوم التوصيل الافتراضية ووسائل الدفع المقبولة في المتجر',
          icon: Icons.attach_money_rounded,
          fields: [
            TextFormField(
              controller: _deliveryFeeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${TranslationKeys.deliveryFee.tr(context)} (\$)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.local_shipping_outlined, size: 20),
              ),
            ),
            SwitchListTile(
              title: const Text('الدفع عند الاستلام (COD)'),
              value: _enableCod,
              onChanged: (val) => setState(() => _enableCod = val),
            ),
            SwitchListTile(
              title: const Text('تحويل Wish Money'),
              value: _enableWishMoney,
              onChanged: (val) => setState(() => _enableWishMoney = val),
            ),
            SwitchListTile(
              title: const Text('تحويل OMT Express'),
              value: _enableOmt,
              onChanged: (val) => setState(() => _enableOmt = val),
            ),
          ],
        ),

        // 5. Contact Info Section
        FormSection(
          title: 'معلومات الاتصال والتواصل المباشر',
          subtitle: 'البريد الإلكتروني والهاتف المباشر لخدمة العملاء بالمتجر',
          icon: Icons.contact_phone_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.storeContactEmail.tr(context),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.storeContactPhone.tr(context),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
