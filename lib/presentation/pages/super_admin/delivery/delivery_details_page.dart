import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/widgets/templates/details_template.dart';

import 'create_delivery_page.dart';
import 'delivery_details_tab/orders_tab.dart';
import 'delivery_details_tab/overview_tab.dart';
import 'delivery_details_tab/permissions_tab.dart';
import 'delivery_details_tab/ratings_tab.dart';

class DeliveryDetailsPage extends StatelessWidget {
  final String deliveryId;

  const DeliveryDetailsPage({super.key, required this.deliveryId});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(
      builder: (context, provider, child) {
        
        final delivery = provider.getDeliveryById(deliveryId);

        if (delivery == null) {
          return const Scaffold(
            body: Center(child: Text('جهة التوصيل غير موجودة')),
          );
        }

        return DetailsTemplate(
          title: 'تفاصيل جهة التوصيل',
          name: delivery.name,
          subtitle: delivery.phone,
          avatarUrl: delivery.logo,
          fallbackIcon: Icons.local_shipping_rounded,
          statusBadge: TableStatusBadge.fromStatus(delivery.status),
          onEdit: () {
            changeScreen(context, CreateDeliveryPage(deliveryToEdit: delivery));
          },
          onDelete: () {
            // Delete logic
          },
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'الصلاحيات والمتاجر'),
            Tab(text: 'الطلبيات'),
            Tab(text: 'التقييم'),
          ],
          tabViews: [
            DeliveryOverviewTab(delivery: delivery),
            DeliveryPermissionsTab(delivery: delivery),
            DeliveryOrdersTab(delivery: delivery),
            DeliveryRatingsTab(delivery: delivery),
          ],
        );
      },
    );
  }
}
