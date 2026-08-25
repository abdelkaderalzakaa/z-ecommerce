import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_buisness.dart';
import '../../../../data/providers/business_provider.dart';
import '../../../global/translate/app_localizations.dart';
import '../../../global/translate/translation_keys.dart';
import '../../../widgets/common/headers/header_details.dart';
import '../../../widgets/common/footers/footer_section.dart';
import '../../../global/core/constants/app_constants.dart';
import '../../../global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/pages/customer/home_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/order_tracking/live_order_tracking_page.dart';
import '../../../widgets/common/headers/widgets/top_title.dart';

class ConfirmOrderPage extends StatelessWidget {
  final List<String>? ids;

  const ConfirmOrderPage({super.key, this.ids});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: TranslationKeys.orderPlacedSuccessfully.tr(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopTitle(
              title: TranslationKeys.orderPlacedSuccessfully.tr(context),
              paths: [
                TranslationKeys.home.tr(context),
                TranslationKeys.orderPlacedSuccessfully.tr(context),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: hPad),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: EdgeInsets.all(
                    ResponsiveLayout.isMobile(context) ? 24 : 40,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: Theme.of(context).dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          size: 100,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        TranslationKeys.orderPlacedSuccessfully.tr(context),
                        style: TextStyle(
                          fontSize: ResponsiveLayout.isMobile(context)
                              ? 24
                              : 32,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${TranslationKeys.thankYouForPurchase.tr(context)}${(ids ?? []).map((id) => '• $id').join('\n')}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      if (ids != null && ids!.isNotEmpty) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.track_changes_rounded, size: 20),
                            label: const Text(
                              'تتبع مسار وحالة طلبك لحظياً 🚀',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              changeScreen(
                                context,
                                LiveOrderTrackingPage(orderId: ids!.first),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.button),
                            ),
                          ),
                          icon: const Icon(Icons.home_outlined),
                          onPressed: () {
                            changeScreen(context, const HomePage());
                          },
                          label: Text(TranslationKeys.backToHome.tr(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
            FooterBuisness(
              idBuisness: context.read<BusinessProvider>().selectedBusiness.id,
            ),
          ],
        ),
      ),
    );
  }
}
