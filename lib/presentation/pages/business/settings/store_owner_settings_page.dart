import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/business/branding/restaurant_menu_branding_page.dart';
import 'package:z_ecommerce/presentation/pages/business/branding/business_branding_page.dart';
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
    _descriptionController = TextEditingController(
      text: 'متجر متخصص بتقديم أحدث المنتجات بجودة عالية وأسعار منافسة',
    );
    _emailController = TextEditingController(text: 'owner@mystore.com');
    _phoneController = TextEditingController(text: '+961 70 123 456');
    _deliveryFeeController = TextEditingController(text: '5.0');

    // Social Media Defaults
    _facebookController = TextEditingController(
      text: 'https://facebook.com/mystore',
    );
    _instagramController = TextEditingController(
      text: 'https://instagram.com/mystore',
    );
    _whatsappController = TextEditingController(text: '+96170123456');
    _twitterController = TextEditingController(text: 'https://x.com/mystore');
    _tiktokController = TextEditingController(
      text: 'https://tiktok.com/@mystore',
    );
    _linkedinController = TextEditingController(
      text: 'https://linkedin.com/company/mystore',
    );
    _youtubeController = TextEditingController(
      text: 'https://youtube.com/@mystore',
    );
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
        const SnackBar(
          content: Text('تم حفظ وتحديث كافة إعدادات الهوية والتواصل بنجاح!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AddEditTemplate(
      title: TranslationKeys.storeSettingsTitle.tr(context),
      subtitle: TranslationKeys.storeSettingsSubtitle.tr(context),
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
          title: TranslationKeys.storeInformation.tr(context),
          subtitle: TranslationKeys.storeInfoSubtitle.tr(context),
          icon: Icons.storefront_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameArController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.storeNameAr.tr(context),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.language, size: 20),
                    ),
                    validator: (v) => v!.isEmpty
                        ? TranslationKeys.required.tr(context)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _nameEnController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.storeNameEn.tr(context),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.language, size: 20),
                    ),
                    validator: (v) => v!.isEmpty
                        ? TranslationKeys.required.tr(context)
                        : null,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _sloganController,
              decoration: const InputDecoration(
                labelText: 'Slogan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.auto_awesome_rounded, size: 20),
              ),
            ),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: TranslationKeys.storeInfoSubtitle.tr(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description_outlined, size: 20),
              ),
            ),
          ],
        ),

        // 2. Visual Theme & Branding Studios
        FormSection(
          title: Localizations.localeOf(context).languageCode == 'ar'
              ? 'استوديوهات الهوية والتصميم المباشر (Branding & Menu Studios)'
              : 'Branding & Menu Studios',
          subtitle: Localizations.localeOf(context).languageCode == 'ar'
              ? 'خصص هوية المتجر العامة وثيم الألوان، أو خصص منيو المطعم الرقمي بشكل مستقل'
              : 'Customize general store UI branding or digital restaurant menu independently',
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
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.palette_rounded,
                      size: 28,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? 'استوديو تخصيص الهوية وثيم المتجر المباشر (Store Theme Studio)'
                              : 'Store Theme & Branding Studio',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? 'تحكم بالدرجات والألوان الرئيسية والفرعية، روابط اللوجو والغلاف، الخطوط العربي والإنجليزي، انحناءات الأزرار للكروت مع معاينة حية.'
                              : 'Control primary/secondary colors, logo/banner URLs, Arabic/English fonts, and radii with real-time preview.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ButtonApp(
                    onPressed: () =>
                        changeScreen(context, const StoreBrandingPage()),
                    icon: Icons.open_in_new_rounded,
                    label: Localizations.localeOf(context).languageCode == 'ar'
                        ? 'تخصيص الهوية والثيم الآن'
                        : 'Customize Store Branding',
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
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 28,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? 'استوديو تخصيص منيو المطعم الرقمي (Restaurant Menu Studio)'
                              : 'Digital Restaurant Menu Studio',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? 'استوديو مخصص للمطاعم والكافيهات لتنسيق المنيو الرقمي، السعرات الحرارية، مكونات الحساسية، والطلب المباشر للطاولة بالـ QR.'
                              : 'Dedicated studio for restaurants & cafes to customize 2-page digital menu, calories, allergens & table QR ordering.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ButtonApp(
                    onPressed: () => changeScreen(
                      context,
                      const RestaurantMenuBrandingPage(),
                    ),
                    icon: Icons.restaurant_rounded,
                    label: Localizations.localeOf(context).languageCode == 'ar'
                        ? 'تخصيص المنيو الرقمي الآن'
                        : 'Customize Restaurant Menu',
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
                      prefixIcon: Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 20,
                      ),
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
                      prefixIcon: Icon(
                        Icons.business_center_outlined,
                        size: 20,
                      ),
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
