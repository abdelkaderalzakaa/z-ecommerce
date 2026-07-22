import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../global/router/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/company_provider.dart';

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
        IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            size: isMobile ? 28 : 32,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: onBack ?? () {
            if (context.canPop()) {
              context.pop();
            } else {
              final cid = context.read<CompanyProvider>().companySettings?.id ?? 'cmp_001';
              context.go(fallbackRoute ?? AppRoutes.toHome(cid));
            }
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
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
