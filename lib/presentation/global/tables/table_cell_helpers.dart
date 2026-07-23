import 'package:flutter/material.dart';
import '../translate/app_localizations.dart';

/// 1. Simple Text Cell with optional Subtitle
class TableTextCell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final bool isBold;

  const TableTextCell({
    super.key,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titleStyle ??
              TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: subtitleStyle ??
                TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

/// 2. Image / Icon + Text Cell (Great for Products, Stores, Users)
class TableImageTextCell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final IconData? fallbackIcon;
  final Color? iconBackgroundColor;
  final Color? iconColor;

  const TableImageTextCell({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.fallbackIcon = Icons.storefront_rounded,
    this.iconBackgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = iconBackgroundColor ?? theme.primaryColor.withOpacity(0.08);
    final fgColor = iconColor ?? theme.primaryColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            image: (imageUrl != null && imageUrl!.startsWith('http'))
                ? DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: (imageUrl == null || !imageUrl!.startsWith('http'))
              ? Icon(
                  fallbackIcon,
                  size: 18,
                  color: fgColor,
                )
              : null,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: TableTextCell(
            title: title,
            subtitle: subtitle,
            isBold: true,
          ),
        ),
      ],
    );
  }
}

/// 3. Pre-styled Soft Status Badge Pill (Data Table v3 Template Style)
class TableStatusBadge extends StatelessWidget {
  final String statusText;
  final Color backgroundColor;
  final Color textColor;

  const TableStatusBadge({
    super.key,
    required this.statusText,
    required this.backgroundColor,
    required this.textColor,
  });

  /// Factory helper for automatic soft pill styling matching the template
  factory TableStatusBadge.fromStatus(String status) {
    final lower = status.trim().toLowerCase();
    Color bg;
    Color fg;

    if (lower.contains('paid') || lower.contains('نشط') || lower.contains('active') || lower.contains('مكتمل') || lower.contains('completed')) {
      bg = const Color(0xFFE6F4EA); // Soft light mint
      fg = const Color(0xFF137333); // Dark green text
    } else if (lower.contains('open') || lower.contains('جديد') || lower.contains('new') || lower.contains('قيد التوصيل')) {
      bg = const Color(0xFFEEF2FF); // Soft indigo/purple tint
      fg = const Color(0xFF4F46E5); // Indigo text
    } else if (lower.contains('inactive') || lower.contains('معلق') || lower.contains('غير نشط') || lower.contains('review')) {
      bg = const Color(0xFFF1F5F9); // Soft slate grey
      fg = const Color(0xFF64748B); // Slate text
    } else if (lower.contains('due') || lower.contains('ملغي') || lower.contains('cancelled') || lower.contains('مرفوض') || lower.contains('rejected')) {
      bg = const Color(0xFFFEE2E2); // Soft rose/red
      fg = const Color(0xFFDC2626); // Red text
    } else {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF475569);
    }

    return TableStatusBadge(
      statusText: status,
      backgroundColor: bg,
      textColor: fg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 4. Currency / Price Cell with Colored Balance Indicators
class TablePriceCell extends StatelessWidget {
  final double amount;
  final String currency;
  final bool showPositiveNegativeColors;

  const TablePriceCell({
    super.key,
    required this.amount,
    this.currency = '\$',
    this.showPositiveNegativeColors = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? color;

    if (showPositiveNegativeColors) {
      if (amount < 0) {
        color = const Color(0xFFDC2626); // Red for negative balance
      } else if (amount > 0) {
        color = const Color(0xFF16A34A); // Green for positive balance
      }
    }

    final formattedAmount = amount < 0
        ? '-$currency${amount.abs().toStringAsFixed(2)}'
        : '$currency${amount.toStringAsFixed(2)}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formattedAmount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? theme.textTheme.bodyLarge?.color,
          ),
        ),
        const Text(
          'CAD',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

/// 5. Row Index Cell (#)
class TableIndexCell extends StatelessWidget {
  final int index;

  const TableIndexCell({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$index',
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }
}

/// 6. 3-Dots Popup Menu Actions Cell (Matching Template Popup Menu)
class TablePopupMenuActions extends StatelessWidget {
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final List<PopupMenuEntry<String>>? extraItems;
  final void Function(String key)? onCustomSelected;

  const TablePopupMenuActions({
    super.key,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.extraItems,
    this.onCustomSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 18,
        color: theme.textTheme.bodySmall?.color,
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onSelected: (value) {
        if (value == 'view' && onView != null) {
          onView!();
        } else if (value == 'edit' && onEdit != null) {
          onEdit!();
        } else if (value == 'delete' && onDelete != null) {
          onDelete!();
        } else if (onCustomSelected != null) {
          onCustomSelected!(value);
        }
      },
      itemBuilder: (context) => [
        if (onView != null)
          PopupMenuItem(
            value: 'view',
            height: 36,
            child: Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 16, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)?.translate('view_details') ?? 'معاينة',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        if (onEdit != null)
          PopupMenuItem(
            value: 'edit',
            height: 36,
            child: Row(
              children: [
                const Icon(Icons.edit_outlined, size: 16, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)?.translate('edit_address') ?? 'تعديل',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            height: 36,
            child: Row(
              children: [
                const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)?.translate('delete_selected') ?? 'حذف',
                  style: const TextStyle(fontSize: 13, color: Colors.red),
                ),
              ],
            ),
          ),
        if (extraItems != null) ...extraItems!,
      ],
    );
  }
}

