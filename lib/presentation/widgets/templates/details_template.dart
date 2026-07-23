import 'package:flutter/material.dart';

/// A reusable, responsive, unified Details Template widget for Flutter applications.
/// Capable of displaying detailed views for any entity (e.g., Stores, Products, Orders, Users).
class DetailsTemplate extends StatelessWidget {
  /// Header Page Title (e.g., 'تفاصيل المتجر', 'تفاصيل المنتج')
  final String title;

  /// Back action callback (defaults to Navigator.pop(context))
  final VoidCallback? onBack;

  /// Optional Action Callbacks for the top action bar
  final VoidCallback? onRefresh;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final List<Widget>? extraActions;

  /// Entity Header Card Data
  final String name;
  final String? subtitle;
  final String? avatarUrl;
  final IconData fallbackIcon;
  final Widget? statusBadge;
  final List<Widget>? headerMetrics;

  /// Tabbed Content Section
  final List<Tab> tabs;
  final List<Widget> tabViews;

  const DetailsTemplate({
    super.key,
    required this.title,
    this.onBack,
    this.onRefresh,
    this.onEdit,
    this.onDelete,
    this.extraActions,
    required this.name,
    this.subtitle,
    this.avatarUrl,
    this.fallbackIcon = Icons.info_outline,
    this.statusBadge,
    this.headerMetrics,
    required this.tabs,
    required this.tabViews,
  }) : assert(
         tabs.length == tabViews.length,
         'tabs and tabViews must have the same length',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: tabs.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Custom Header & Action Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    // Back Button
                    InkWell(
                      onTap: onBack ?? () => Navigator.of(context).pop(),
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
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Action Buttons (Refresh, Edit, Delete, Extra Actions)
                    if (onRefresh != null)
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        tooltip: 'تحديث البيانات',
                        onPressed: onRefresh,
                      ),
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: Colors.blueAccent,
                        tooltip: 'تعديل',
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                        ),
                        color: Colors.red,
                        tooltip: 'حذف',
                        onPressed: onDelete,
                      ),
                    if (extraActions != null) ...extraActions!,
                  ],
                ),
              ),

              // 2. Profile / Entity Header Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 15.0),
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar / Image Icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            image:
                                (avatarUrl != null &&
                                    avatarUrl!.startsWith('http'))
                                ? DecorationImage(
                                    image: NetworkImage(avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              (avatarUrl == null ||
                                  !avatarUrl!.startsWith('http'))
                              ? Icon(
                                  fallbackIcon,
                                  size: 30,
                                  color: theme.primaryColor,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),

                        // Name, Subtitle & Status Badge
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (statusBadge != null) ...[
                                          const SizedBox(width: 10),
                                          statusBadge!,
                                        ],
                                      ],
                                    ),
                                    if (subtitle != null &&
                                        subtitle!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        subtitle!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: theme
                                              .textTheme
                                              .bodySmall
                                              ?.color
                                              ?.withOpacity(0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (headerMetrics != null &&
                                  headerMetrics!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: headerMetrics!,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    // 3. Tab Bar Header
                    Container(
                      margin: const EdgeInsets.only(top: 10),

                      child: TabBar(
                        isScrollable: true,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                        dividerColor: Colors.transparent,
                        labelColor: theme.primaryColor,
                        unselectedLabelColor: theme.textTheme.bodySmall?.color,
                        indicatorColor: theme.primaryColor,
                        indicatorWeight: 2.5,
                        tabs: tabs,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Tab Views Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                  child: Card(child: TabBarView(children: tabViews)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
