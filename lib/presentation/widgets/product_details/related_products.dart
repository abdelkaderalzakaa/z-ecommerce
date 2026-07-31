import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../common/product_card.dart';
import '../../../data/providers/product_provider.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class RelatedProducts extends StatelessWidget {
  const RelatedProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);

    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final products = provider.allProducts.take(4).toList();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            children: [
              SectionHeader(
                title: TranslationKeys.youMightAlsoLike.tr(context),
              ),
              const SizedBox(height: 54),
              if (isMobile)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: products.map((p) {
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        child: ProductCard(product: p),
                      );
                    }).toList(),
                  ),
                )
              else
                Row(
                  children: products.map((p) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: p == products.last ? 0 : 20,
                        ),
                        child: ProductCard(product: p),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}
