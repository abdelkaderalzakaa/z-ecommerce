import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/company/company_settings_model.dart';
import 'package:z_ecommerce/data/models/order/invoice_model.dart';
import 'package:z_ecommerce/data/providers/invoice_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_stores_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

/// Interactive Order Status Update Dialog
void showOrderStatusDialog(BuildContext context, InvoiceModel invoice) {
  String selectedStatus = invoice.status;

  showDialog(
    context: context,
    builder: (context) => StatefulWidgetBuilder(
      builder: (context, setState) {
        final theme = Theme.of(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.sync_alt_rounded, color: theme.primaryColor),
              const SizedBox(width: 10),
              Text('تغيير حالة الطلب #${invoice.invoiceId}'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(TranslationKeys.statusPending.tr(context)),
                subtitle: const Text('الطلب قيد المراجعة والانتظار'),
                value: 'Pending',
                groupValue: selectedStatus,
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
              RadioListTile<String>(
                title: Text(TranslationKeys.statusPaid.tr(context)),
                subtitle: const Text('تم استلام مبلغ الطلب بنجاح'),
                value: 'Paid',
                groupValue: selectedStatus,
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
              RadioListTile<String>(
                title: Text(TranslationKeys.statusCompleted.tr(context)),
                subtitle: const Text('تم توصيل واستكمال الطلب بنجاح'),
                value: 'Completed',
                groupValue: selectedStatus,
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
              RadioListTile<String>(
                title: const Text('مرفوض / ملغي (Cancelled)'),
                subtitle: const Text('تم إلغاء أو رفض الطلب'),
                value: 'Cancelled',
                groupValue: selectedStatus,
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(TranslationKeys.cancel.tr(context)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final provider = context.read<InvoiceProvider>();
                final index = provider.invoices.indexWhere((inv) => inv.invoiceId == invoice.invoiceId);
                if (index != -1) {
                  final updated = InvoiceModel(
                    invoiceId: invoice.invoiceId,
                    storeId: invoice.storeId,
                    items: invoice.items,
                    tax: invoice.tax,
                    shippingCost: invoice.shippingCost,
                    date: invoice.date,
                    status: selectedStatus,
                    shippingAddress: invoice.shippingAddress,
                  );
                  provider.invoices[index] = updated;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم تحديث حالة الطلب إلى "$selectedStatus" بنجاح')),
                );
              },
              icon: const Icon(Icons.check, size: 18),
              label: Text(TranslationKeys.saveChanges.tr(context)),
            ),
          ],
        );
      },
    ),
  );
}

/// Interactive Store Status Update Dialog
void showStoreStatusDialog(BuildContext context, CompanySettingsModel store) {
  String selectedStatus = store.status ?? 'Active';

  showDialog(
    context: context,
    builder: (context) => StatefulWidgetBuilder(
      builder: (context, setState) {
        final theme = Theme.of(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.storefront_rounded, color: theme.primaryColor),
              const SizedBox(width: 10),
              Text('تحديث حالة المتجر "${store.name.get(context)}"'),
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(TranslationKeys.cancel.tr(context)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final provider = context.read<SuperAdminStoresProvider>();
                provider.updateStoreStatus(store.id, selectedStatus);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم تحديث حالة المتجر إلى "$selectedStatus" بنجاح')),
                );
              },
              icon: const Icon(Icons.check, size: 18),
              label: Text(TranslationKeys.saveChanges.tr(context)),
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
