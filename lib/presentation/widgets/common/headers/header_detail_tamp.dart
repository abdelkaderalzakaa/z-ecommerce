import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
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

class HeaderDetailsTemp extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onRefresh;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final List<Widget>? extraActions;
  const HeaderDetailsTemp({
    super.key,
    required this.title,
    this.onBack,
    this.onRefresh,
    this.onEdit,
    this.onDelete,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(150);

  @override
  State<HeaderDetailsTemp> createState() => _HeaderDetailsTempState();
}

class _HeaderDetailsTempState extends State<HeaderDetailsTemp> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 75,
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                // Back Button
                InkWell(
                  onTap: widget.onBack ?? () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.15),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Page Title
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Action Buttons (Refresh, Edit, Delete, Extra Actions)
                if (widget.onRefresh != null)
                  ButtonApp(
                    format: FormatButtonApp.icon,
                    icon: Icons.refresh_rounded,
                    color: Colors.blueAccent,
                    label: 'تحديث البيانات',
                    onPressed: widget.onRefresh,
                  ),
                if (widget.onEdit != null)
                  ButtonApp(
                    icon: Icons.edit_outlined,
                    label: 'تعديل',
                    onPressed: widget.onEdit,
                  ),
                if (widget.onDelete != null)
                  ButtonApp(
                    format: FormatButtonApp.icon,
                    icon: Icons.delete_outline_rounded,
                    color: Colors.red,
                    label: 'حذف',
                    onPressed: widget.onDelete,
                  ),
                if (widget.extraActions != null) ...widget.extraActions!,
              ],
            ),
          ),
          Container(height: 1, color: theme.dividerColor),
        ],
      ),
    );
  }
}
