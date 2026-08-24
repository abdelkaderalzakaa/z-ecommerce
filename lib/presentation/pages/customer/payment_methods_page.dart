import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_section.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/top_title.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final List<_PaymentOption> paymentMethods = [
      _PaymentOption(
        title: isAr
            ? 'الدفع عند الاستلام (Cash on Delivery)'
            : 'Cash on Delivery (COD)',
        description: isAr
            ? 'ادفع نقداً بكل سهولة وأمان عند وصول الطلبية إلى باب منزلك أو مقر عملك دون أي رسوم مسبقة.'
            : 'Pay in cash effortlessly when your order arrives at your doorstep.',
        icon: Icons.payments_outlined,
        color: AppColors.green,
        badge: isAr ? 'متاح وموصى به' : 'Popular Choice',
        features: [
          isAr ? 'بدون حاجة لبطاقات مصرفية' : 'No credit card needed',
          isAr ? 'دفع آمن بعد معاينة الطلبية' : 'Pay after inspecting item',
        ],
      ),
      _PaymentOption(
        title: isAr ? 'البطاقات الائتمانية والمصرفية' : 'Credit & Debit Cards',
        description: isAr
            ? 'دعم كامل لبطاقات (Visa, MasterCard, American Express) بتشفير آمن وحماية بنكية عالية 256-bit.'
            : 'Full support for Visa, MasterCard, and AMEX with 256-bit SSL encryption.',
        icon: Icons.credit_card_outlined,
        color: Colors.blue,
        badge: isAr ? 'دفع فوري وآمن' : 'Instant & Secure',
        features: [
          isAr ? 'معالجة فورية ومؤمنة' : 'Instant transaction processing',
          isAr ? 'حماية مشفرة ضد الاحتيال' : 'Fraud-protected 256-bit SSL',
        ],
      ),
      _PaymentOption(
        title: isAr
            ? 'المحافظ الإلكترونية (Digital Wallets)'
            : 'Digital Wallets',
        description: isAr
            ? 'ادفع مباشرة عبر المحافظ الإلكترونية المعتمدة مثل (Whish Money, OMT Card, ZainCash, Apple Pay).'
            : 'Pay seamlessly using Whish Money, OMT Card, Apple Pay, and local e-wallets.',
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.purple,
        badge: isAr ? 'سريع ودقيق' : 'Fast & Seamless',
        features: [
          isAr ? 'إتمام الدفع بكبسة زر' : 'One-tap checkout experience',
          isAr ? 'تأكيد فوري بالرسائل' : 'Instant SMS confirmation',
        ],
      ),
      _PaymentOption(
        title: isAr
            ? 'التحويل البنكي المباشر (Bank Transfer)'
            : 'Bank Wire Transfer',
        description: isAr
            ? 'إمكانية التحويل البنكي المباشر إلى الحساب المصرفي الرسمي مع إرفاق وصل التحويل لتأكيد الطلبية.'
            : 'Direct bank transfer to official IBAN with receipt attachment.',
        icon: Icons.account_balance_outlined,
        color: Colors.orange,
        badge: isAr ? 'للطلبات الكبيرة' : 'For Bulk Orders',
        features: [
          isAr ? 'مناسب للمشتريات الكبيرة' : 'Ideal for wholesale orders',
          isAr ? 'فواتير رسمية موثقة' : 'Official bank-verified invoices',
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: isAr ? 'طرق الدفع المتاحة' : 'Payment Methods',
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TopTitle(
              title: isAr ? 'طرق الدفع المتاحة' : 'Payment Methods',
              paths: [isAr ? 'طرق الدفع' : 'Payment Methods'],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Hero Section
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.payment,
                          color: theme.primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr
                                  ? 'وسائل وطرق الدفع المعتمدة'
                                  : 'Accepted Payment Options',
                              style: TextStyle(
                                fontSize: isMobile ? 22 : 28,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAr
                                  ? 'اختر طريقة الدفع الأكثر ملاءمة لك مع ضمان حماية الدفع المالي 100%'
                                  : 'Select your preferred payment method with 100% security guarantee',
                              style: AppTextStyles.bodyText(
                                context,
                              ).copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Buyer Protection Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user,
                          color: AppColors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr
                                    ? 'ضمان أمان وحماية الدفع 100%'
                                    : '100% Payment Protection Guarantee',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.green,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAr
                                    ? 'جميع المعاملات المالية مشفرة وآمنة وفق أعلى معايير الحماية المصرفية العالمية.'
                                    : 'All transactions are encrypted and secured under banking standards.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Payment Options Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: isMobile ? 1.35 : 1.5,
                    ),
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, index) {
                      final option = paymentMethods[index];
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: option.color.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    option.icon,
                                    color: option.color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: option.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    option.badge,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: option.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Text(
                              option.description,
                              style: AppTextStyles.bodyText(
                                context,
                              ).copyWith(fontSize: 12.5),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              children: option.features.map((feat) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 14,
                                        color: option.color,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        feat,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              theme.textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String badge;
  final List<String> features;

  _PaymentOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.badge,
    required this.features,
  });
}
