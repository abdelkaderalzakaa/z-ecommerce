import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

/// Reusable Card Container for Super Admin Views
class SuperAdminSectionContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? actionWidget;
  final List<Widget> statCards;
  final Widget child;

  const SuperAdminSectionContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionWidget,
    this.statCards = const [],
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: theme.primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              ?actionWidget,
            ],
          ),

          if (statCards.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: statCards
                  .map(
                    (card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: card,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          const SizedBox(height: 24),

          // Main Card Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Helper Metric Card
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Products Management Page Placeholder
// ---------------------------------------------------------------------------
class ProductsManagementPage extends StatelessWidget {
  const ProductsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SuperAdminSectionContainer(
      title: 'إدارة المنتجات',
      subtitle: 'متابعة والتحكم بجميع المنتجات المعروضة عبر المتاجر المختلفة',
      icon: Icons.inventory_2_rounded,
      actionWidget: ButtonApp(
        onPressed: () {},
        icon: Icons.add,
        label: 'إضافة منتج جديد',
      ),
      statCards: const [
        MetricCard(
          label: 'إجمالي المنتجات',
          value: '1,248',
          icon: Icons.inventory_2,
          color: Colors.blue,
        ),
        MetricCard(
          label: 'منتجات نشطة',
          value: '1,105',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        MetricCard(
          label: 'منتجات قيد المراجعة',
          value: '143',
          icon: Icons.pending,
          color: Colors.orange,
        ),
      ],
      child: Column(
        children: [
          // Filter Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'البحث باسم المنتج أو المتجر...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('فلترة'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Products Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('المنتج')),
                DataColumn(label: Text('المتجر')),
                DataColumn(label: Text('السعر')),
                DataColumn(label: Text('المخزون')),
                DataColumn(label: Text('الحالة')),
                DataColumn(label: Text('الإجراءات')),
              ],
              rows: List.generate(
                5,
                (index) => DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.shopping_bag, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text('منتج أزياء تجريبي #${index + 1}'),
                        ],
                      ),
                    ),
                    const DataCell(Text('متجر الأناقة')),
                    DataCell(Text('\$${(index + 1) * 29}.99')),
                    DataCell(Text('${(index + 1) * 15} قطعة')),
                    DataCell(
                      Chip(
                        label: Text(
                          index.isEven ? 'نشط' : 'قيد المراجعة',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: index.isEven
                            ? Colors.green
                            : Colors.orange,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          ButtonApp(
                            format: FormatButtonApp.icon,
                            icon: Icons.visibility_outlined,
                            label: 'عرض',
                            onPressed: () {},
                          ),
                          ButtonApp(
                            format: FormatButtonApp.icon,
                            icon: Icons.edit_outlined,
                            label: 'تعديل',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Orders Management Page Placeholder
// ---------------------------------------------------------------------------
class OrdersManagementPage extends StatelessWidget {
  const OrdersManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SuperAdminSectionContainer(
      title: 'إدارة الطلبات',
      subtitle: 'متابعة الطلبات المنفذة وحالات الشحن والدفع عبر كافة المتاجر',
      icon: Icons.shopping_cart_rounded,
      statCards: const [
        MetricCard(
          label: 'إجمالي الطلبات',
          value: '3,840',
          icon: Icons.shopping_cart,
          color: Colors.purple,
        ),
        MetricCard(
          label: 'طلبات جديدة',
          value: '42',
          icon: Icons.new_releases,
          color: Colors.blue,
        ),
        MetricCard(
          label: 'تم التوصيل',
          value: '3,610',
          icon: Icons.local_shipping,
          color: Colors.green,
        ),
      ],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'البحث برقم الطلب أو العميل...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.date_range, size: 18),
                label: const Text('تصفية بالتاريخ'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('رقم الطلب')),
                DataColumn(label: Text('العميل')),
                DataColumn(label: Text('المتجر')),
                DataColumn(label: Text('الإجمالي')),
                DataColumn(label: Text('حالة الطلب')),
                DataColumn(label: Text('التاريخ')),
              ],
              rows: List.generate(
                5,
                (index) => DataRow(
                  cells: [
                    DataCell(Text('#ORD-2026-${1000 + index}')),
                    DataCell(Text('عميل تجريبي ${index + 1}')),
                    const DataCell(Text('متجر التقنية')),
                    DataCell(Text('\$${(index + 1) * 140}.00')),
                    DataCell(
                      Chip(
                        label: Text(
                          index == 0
                              ? 'جديد'
                              : (index == 1 ? 'قيد التوصيل' : 'مكتمل'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: index == 0
                            ? Colors.blue
                            : (index == 1
                                  ? Colors.amber.shade800
                                  : Colors.green),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const DataCell(Text('2026-07-23')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Users Management Page Placeholder
// ---------------------------------------------------------------------------
class UsersManagementPage extends StatelessWidget {
  const UsersManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SuperAdminSectionContainer(
      title: 'إدارة المستخدمين والأدوار',
      subtitle: 'التحكم بحسابات المستخدمين ومدراء المتاجر والصلاحيات في النظام',
      icon: Icons.people_alt_rounded,
      actionWidget: ButtonApp(
        onPressed: () {},
        icon: Icons.person_add,
        label: 'إضافة مستخدم جديد',
      ),
      statCards: const [
        MetricCard(
          label: 'إجمالي المستخدمين',
          value: '8,490',
          icon: Icons.people,
          color: Colors.teal,
        ),
        MetricCard(
          label: 'مدراء المتاجر',
          value: '124',
          icon: Icons.admin_panel_settings,
          color: Colors.indigo,
        ),
        MetricCard(
          label: 'عملاء نشطين',
          value: '8,366',
          icon: Icons.person,
          color: Colors.green,
        ),
      ],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'البحث باسم المستخدم أو البريد الإلكتروني...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('المستخدم')),
                DataColumn(label: Text('البريد الإلكتروني')),
                DataColumn(label: Text('الدور / الصلاحية')),
                DataColumn(label: Text('تاريخ الانضمام')),
                DataColumn(label: Text('الحالة')),
              ],
              rows: List.generate(
                5,
                (index) => DataRow(
                  cells: [
                    DataCell(Text('مستخدم #${index + 1}')),
                    DataCell(Text('user$index@example.com')),
                    DataCell(Text(index == 0 ? 'مدير متجر' : 'عميل')),
                    const DataCell(Text('2026-01-15')),
                    const DataCell(
                      Chip(
                        label: Text(
                          'نشط',
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Offers Management Page Placeholder
// ---------------------------------------------------------------------------
class OffersManagementPage extends StatelessWidget {
  const OffersManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SuperAdminSectionContainer(
      title: 'إدارة العروض والخصومات',
      subtitle: 'إنشاء ومتابعة حملات التخفيضات وكوبونات الخصم للمتاجر',
      icon: Icons.local_offer_rounded,
      actionWidget: ButtonApp(
        onPressed: () {},
        icon: Icons.add,
        label: 'إضافة عرض جديد',
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'قسم العروض والخصومات قيد التطوير',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'يمكنك إضافة وتفعيل الحملات التسويقية وكوبونات الخصم قريباً.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Categories Management Page Placeholder
// ---------------------------------------------------------------------------
class CategoriesManagementPage extends StatelessWidget {
  const CategoriesManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SuperAdminSectionContainer(
      title: 'إدارة الأقسام والتصنيفات',
      subtitle: 'تنظيم الهيكل العام للأقسام الرئيسية والفرعية في المنصة',
      icon: Icons.category_rounded,
      actionWidget: ButtonApp(
        onPressed: () {},
        icon: Icons.add,
        label: 'إضافة قسم جديد',
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.category_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'قسم تصنيفات المنصة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'إدارة وتعديل شجرة التصنيفات الرئيسية والفرعية.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
