import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_buisness.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';
import '../../../global/core/constants/app_constants.dart';
import '../../../global/core/responsive/responsive_layout.dart';
import '../../../widgets/common/headers/header_home.dart';
import '../../../widgets/common/footers/footer_section.dart';
import '../../../widgets/common/headers/widgets/breadcrumb.dart';
import '../../../widgets/common/headers/widgets/top_title.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../../global/translate/app_localizations.dart';
import '../../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import '../../../../data/providers/business_provider.dart';

import '../../../widgets/cart/cart_items_list.dart';
import '../../../widgets/cart/order_summary.dart';
import 'package:z_ecommerce/presentation/pages/customer/cart/cart_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: TranslationKeys.yourCart.tr(context),
        fallbackRoute: 'shop',
        paths: [
          TranslationKeys.home.tr(context),
          '${TranslationKeys.checkout.tr(context).split(' ').first}:${context.watch<CartProvider>().cartCount(context.read<BusinessProvider>().selectedBusiness?.id)} ${TranslationKeys.items.tr(context)}',
        ],
        isCartActive: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: isMobile
                  ? const Column(
                      children: [
                        CartItemsList(),
                        SizedBox(height: 20),
                        OrderSummary(),
                      ],
                    )
                  : const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: CartItemsList()),
                        SizedBox(width: 20),
                        Expanded(flex: 2, child: OrderSummary()),
                      ],
                    ),
            ),

            const SizedBox(height: 80),
            FooterBuisness(idBuisness: context.read<BusinessProvider>().selectedBusiness?.id ?? ''),
          ],
        ),
      ),
    );
  }
}
