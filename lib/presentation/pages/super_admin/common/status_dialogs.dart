import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:z_ecommerce/data/models/order/invoice_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/invoice_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

/// Interactive Order Status Update Dialog
void showOrderStatusDialog(BuildContext context, InvoiceModel invoice) {
  OrderStatus selectedStatus = invoice.status;

  showDialog(
    context: context,
    builder: (context) => StatefulWidgetBuilder(
      builder: (context, setState) {
        final theme = Theme.of(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.sync_alt_rounded, color: theme.primaryColor),
              const SizedBox(width: 10),
              Text('تغيير حالة الطلب #${invoice.id}'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<OrderStatus>(
                title: Text(TranslationKeys.statusPending.tr(context)),
                subtitle: const Text('الطلب قيد المراجعة والانتظار'),
                value: OrderStatus.pending,
                groupValue: selectedStatus,
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
              RadioListTile<OrderStatus>(
                title: Text(TranslationKeys.statusPaid.tr(context)),
                subtitle: const Text('تم استلام مبلغ الطلب بنجاح'),
                value: OrderStatus.confirmed,
                groupValue: selectedStatus,
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
              RadioListTile<OrderStatus>(
                title: Text(TranslationKeys.statusCompleted.tr(context)),
                subtitle: const Text('تم توصيل واستكمال الطلب بنجاح'),
                value: OrderStatus.delivered,
                groupValue: selectedStatus,
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
              RadioListTile<OrderStatus>(
                title: const Text('مرفوض / ملغي (Cancelled)'),
                subtitle: const Text('تم إلغاء أو رفض الطلب'),
                value: OrderStatus.cancelled,
                groupValue: selectedStatus,
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
            ],
          ),
          actions: [
            ButtonApp(
              format: FormatButtonApp.text,
              onPressed: () => Navigator.pop(context),
              label:TranslationKeys.cancel.tr(context),
            ),
            ButtonApp(
              onPressed: () {
                invoice.updateStatus(
                  selectedStatus,
                  "super_admin",
                  UserRole.superAdmin,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تحديث حالة الطلب إلى "${selectedStatus.name}" بنجاح',
                    ),
                  ),
                );
              },
              icon: Icons.check,
              label: TranslationKeys.saveChanges.tr(context),
            ),
          ],
        );
      },
    ),
  );
}

/// Interactive Store Status Update Dialog
void showStoreStatusDialog(BuildContext context, BusinessModel store) {
  String selectedStatus = store.status ?? 'Active';

  showDialog(
    context: context,
    builder: (context) => StatefulWidgetBuilder(
      builder: (context, setState) {
        final theme = Theme.of(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.storefront_rounded, color: theme.primaryColor),
              const SizedBox(width: 10),
              Text(
                'تحديث حالة المتجر "${store.localization.name.get(context)}"',
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('نشط (Active)'),
                subtitle: const Text('المتجر مفعل ويعمل بكامل صلاحياته'),
                value: 'Active',
                groupValue: selectedStatus,
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
              RadioListTile<String>(
                title: const Text('غير نشط (Inactive)'),
                subtitle: const Text('المتجر متوقف مؤقتاً عن العمل'),
                value: 'Inactive',
                groupValue: selectedStatus,
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
              RadioListTile<String>(
                title: const Text('معلق / محظور (Suspended)'),
                subtitle: const Text('تم تجميد حساب المتجر لمراجعة المخالفات'),
                value: 'Suspended',
                groupValue: selectedStatus,
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
            ],
          ),
          actions: [
            ButtonApp(
              format: FormatButtonApp.text,
              onPressed: () => Navigator.pop(context),
              label: TranslationKeys.cancel.tr(context),
            ),
            ButtonApp(
              onPressed: () async {
                final provider = context.read<BusinessProvider>();
                await provider.updateStoreStatus(store.id, selectedStatus);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تحديث حالة المتجر إلى "$selectedStatus" بنجاح',
                    ),
                  ),
                );
              },
              icon: Icons.check,
              label: TranslationKeys.saveChanges.tr(context),
            ),
          ],
        );
      },
    ),
  );
}

class StatefulWidgetBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, StateSetter setState) builder;

  const StatefulWidgetBuilder({super.key, required this.builder});

  @override
  State<StatefulWidgetBuilder> createState() => _StatefulWidgetBuilderState();
}

class _StatefulWidgetBuilderState extends State<StatefulWidgetBuilder> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, setState);
  }
}
