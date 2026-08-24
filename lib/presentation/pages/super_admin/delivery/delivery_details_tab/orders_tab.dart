import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:intl/intl.dart';

class DeliveryOrdersTab extends StatelessWidget {
  final DeliveryModel delivery;

  const DeliveryOrdersTab({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        
        final assignedOrders = orderProvider.allOrders.where((o) => o.deliveryId == delivery.id).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الطلبيات المعينة (${assignedOrders.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: AppDataTable<OrderModel>(
                  items: assignedOrders,
                  isLoading: false,
                  columns: [
                    AppTableColumn<OrderModel>(
                      title: 'رقم الطلب',
                      width: 150,
                      sortable: true,
                      sortKey: (order) => order.id,
                      cellBuilder: (order) => TableTextCell(
                        title: '#${order.id.substring(0, min(8, order.id.length))}',
                        subtitle: DateFormat.yMMMd().format(order.createdAt),
                        isBold: true,
                      ),
                    ),
                    AppTableColumn<OrderModel>(
                      title: 'العميل',
                      width: 200,
                      cellBuilder: (order) => TableTextCell(
                        title: 'العميل #${order.customerId.substring(0, min(6, order.customerId.length))}',
                      ),
                    ),
                    AppTableColumn<OrderModel>(
                      title: 'المبلغ الإجمالي',
                      width: 150,
                      sortable: true,
                      sortKey: (order) => order.storeTotal.toString(),
                      cellBuilder: (order) => Text(
                        '\$${order.storeTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    AppTableColumn<OrderModel>(
                      title: 'الحالة',
                      width: 150,
                      cellBuilder: (order) => TableStatusBadge.fromStatus(order.status.name),
                    ),
                  ],
                  onRowTap: (order) {
                    // Navigate to order details
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

int min(int a, int b) => a < b ? a : b;
