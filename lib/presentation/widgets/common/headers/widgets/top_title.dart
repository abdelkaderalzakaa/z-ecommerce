import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/company_provider.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/router/app_routes.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/breadcrumb.dart';

class TopTitle extends StatelessWidget {
  final String title;
  final String? fallbackRoute;
  final VoidCallback? onBack;
  final List<String> paths;
  const TopTitle({
    super.key,
    required this.title,
    this.fallbackRoute,
    this.onBack,
    required this.paths,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap:
                onBack ??
                () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    final cid =
                        context.read<CompanyProvider>().companySettings?.id ??
                        'cmp_001';
                    context.go(fallbackRoute ?? AppRoutes.toHome(cid));
                  }
                },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.arrow_back_ios_outlined,
                size: 26,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          Spacer(),
          Breadcrumb(paths: paths),
        ],
      ),
    );
  }
}
