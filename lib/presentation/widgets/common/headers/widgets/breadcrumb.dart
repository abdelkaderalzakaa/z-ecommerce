import 'package:flutter/material.dart';
import '../../../../global/core/constants/app_constants.dart';
import '../../../../global/core/responsive/responsive_layout.dart';
import '../../../../pages/home_page.dart';
import '../../../../pages/categories_page.dart';
import '../../../../../data/providers/category_provider.dart';
import 'package:provider/provider.dart';

class Breadcrumb extends StatelessWidget {
  final List<String> paths;

  const Breadcrumb({super.key, required this.paths});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < paths.length; i++) ...[
              _BreadcrumbItem(
                label: paths[i],
                isLast: i == paths.length - 1,
                isMobile: isMobile,
              ),
              if (i < paths.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.chevron_right,
                    size: isMobile ? 10 : 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BreadcrumbItem extends StatefulWidget {
  final String label;
  final bool isLast;
  final bool isMobile;

  const _BreadcrumbItem({
    required this.label,
    required this.isLast,
    required this.isMobile,
  });

  @override
  State<_BreadcrumbItem> createState() => _BreadcrumbItemState();
}

class _BreadcrumbItemState extends State<_BreadcrumbItem> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.label,
      style: TextStyle(
        fontSize: widget.isMobile ? 12 : 14,
        fontWeight: widget.isLast ? FontWeight.w500 : FontWeight.w400,
        color: widget.isLast
            ? Theme.of(context).textTheme.bodyLarge?.color
            : Theme.of(context).textTheme.bodyMedium?.color,
      ),
    );
  }
}
