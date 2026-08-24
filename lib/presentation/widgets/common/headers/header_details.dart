import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/breadcrumb.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/buttons.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/logo.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/cart_header_icon.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/account_header_icon.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/top_title.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../../../data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/pages/customer/home_page.dart';

class HeaderDetails extends StatefulWidget implements PreferredSizeWidget {

  final bool isCartActive;
  final bool showBackButton;
  final String title;
  const HeaderDetails({
    super.key,
    this.isCartActive = true,
    this.showBackButton = false,
    required this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(81);

  @override
  State<HeaderDetails> createState() => _HeaderDetailsState();
}

class _HeaderDetailsState extends State<HeaderDetails> {
  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              children: [
                if (widget.showBackButton) ...[
                  const BackButton(),
                  const SizedBox(width: 8),
                ],
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () {
                      changeScreen(context, const HomePage());
                    },
                    child: const Logo(),
                  ),
                ),
                const SizedBox(width: 24),
                Spacer(),
                CartHeaderIcon(isActive: widget.isCartActive),
                const SizedBox(width: 4),
                const AccountHeaderIcon(),
              ],
            ),
          ),
          Container(height: 1, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}
