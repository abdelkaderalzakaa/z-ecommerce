import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/pages/customer/home_page.dart';

class TopTitle extends StatelessWidget {
  final String title;
  final bool isHero;
  final String? fallbackRoute;
  final VoidCallback? onBack;

  const TopTitle({
    super.key,
    required this.title,
    this.isHero = true,
    this.fallbackRoute,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final titleStyle = isHero
        ? AppTextStyles.heroTitle(context, isMobile).copyWith(
            fontSize: isMobile ? 32 : 40,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          )
        : TextStyle(
            fontSize: isMobile ? 28 : 32,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            letterSpacing: -0.5,
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ButtonApp(
          format: FormatButtonApp.icon,
          icon: Icons.arrow_back_rounded,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          label: 'رجوع',
          onPressed:
              onBack ??
              () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  changeScreen(context, const HomePage());
                }
              },
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            title,
            style: titleStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
