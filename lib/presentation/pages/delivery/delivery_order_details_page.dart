import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/customer_provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/currency_helper.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/theme/app_colors.dart';
import 'package:z_ecommerce/presentation/widgets/order/order_tracker_widget.dart';

class DeliveryOrderDetailsPage extends StatefulWidget {
  final OrderModel order;

  const DeliveryOrderDetailsPage({super.key, required this.order});

  @override
  State<DeliveryOrderDetailsPage> createState() => _DeliveryOrderDetailsPageState();
}

class _DeliveryOrderDetailsPageState extends State<DeliveryOrderDetailsPage> {
  late OrderModel _currentOrder;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  Future<void> _launchCaller(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMap(String addressQuery, {double? lat, double? lng}) async {
    Uri uri;
    if (lat != null && lng != null) {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    } else {
      final encoded = Uri.encodeComponent(addressQuery);
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _updateStatus(OrderStatus newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await context.read<DeliveryProvider>().updateOrderStatus(
            _currentOrder.id,
            newStatus,
          );
      setState(() {
        _currentOrder = _currentOrder.copyWith(status: newStatus);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('تم تحديث حالة الطلب إلى: ${_getStatusLabel(newStatus)}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ أثناء التحديث: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'بانتظار التأكيد';
      case OrderStatus.confirmed:
        return 'مؤكد من المتجر';
      case OrderStatus.preparing:
        return 'قيد التجهيز';
      case OrderStatus.ready:
        return 'جاهز للاستلام بالمحل';
      case OrderStatus.shipped:
        return 'في الطريق للعميل';
      case OrderStatus.delivered:
        return 'تم التسليم بنجاح';
      case OrderStatus.cancelled:
        return 'ملغي / متعذر';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return Colors.orange;
      case OrderStatus.preparing:
      case OrderStatus.ready:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final business = context.watch<BusinessProvider>().getBusinessById(_currentOrder.businessId);
    final businessName = business?.localization.name.get(context) ?? 'المتجر';
    final businessPhone = business?.ownerPhone ?? '';
    final customer = context.watch<CustomerProvider>().getCustomerById(_currentOrder.customerId);
    final customerPhone = customer?.phone ?? '';
    final customerName = customer?.name ?? _currentOrder.shippingAddressSnapshot?.title ?? 'العميل';
    final address = _currentOrder.shippingAddressSnapshot;

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الشحنة #${_currentOrder.id.substring(0, _currentOrder.id.length.clamp(0, 8))}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_currentOrder.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(_currentOrder.status).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping_rounded,
                        color: _getStatusColor(_currentOrder.status),
                        size: 36,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الحالة الحالية: ${_getStatusLabel(_currentOrder.status)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(_currentOrder.status),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تاريخ الطلب: ${_currentOrder.createdAt.toString().substring(0, 16)}',
                              style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Live Route & Tri-point Radar Tracker
                OrderTrackerWidget(
                  order: _currentOrder,
                  currentStatus: _currentOrder.status,
                  isMobile: true,
                ),

                const SizedBox(height: 20),

                // Store Card (Pickup Location)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.storefront_rounded, color: Colors.blue, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('نقطة الاستلام (المتجر)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(
                                    businessName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            if (businessPhone.isNotEmpty) ...[
                              IconButton.filledTonal(
                                icon: const Icon(Icons.phone_rounded, color: Colors.blue, size: 20),
                                tooltip: 'اتصال',
                                onPressed: () => _launchCaller(businessPhone),
                              ),
                              const SizedBox(width: 6),
                              IconButton.filledTonal(
                                icon: const Icon(Icons.chat_rounded, color: Colors.green, size: 20),
                                tooltip: 'واتساب',
                                onPressed: () => _launchWhatsApp(businessPhone),
                              ),
                              const SizedBox(width: 6),
                              IconButton.filledTonal(
                                icon: const Icon(Icons.navigation_rounded, color: Colors.blueAccent, size: 20),
                                tooltip: 'خرائط جوجل',
                                onPressed: () => _openMap(businessName),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Customer Card (Delivery Location)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.person_pin_circle_rounded, color: Colors.green, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('عنوان التسليم (العميل)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(
                                    customerName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            if (customerPhone.isNotEmpty) ...[
                              IconButton.filledTonal(
                                icon: const Icon(Icons.phone_rounded, color: Colors.blue, size: 20),
                                tooltip: 'اتصال',
                                onPressed: () => _launchCaller(customerPhone),
                              ),
                              const SizedBox(width: 6),
                              IconButton.filledTonal(
                                icon: const Icon(Icons.chat_rounded, color: Colors.green, size: 20),
                                tooltip: 'واتساب',
                                onPressed: () => _launchWhatsApp(customerPhone),
                              ),
                              const SizedBox(width: 6),
                              IconButton.filledTonal(
                                icon: const Icon(Icons.navigation_rounded, color: Colors.green, size: 20),
                                tooltip: 'خرائط جوجل',
                                onPressed: () => _openMap(
                                  address?.getFormattedAddress() ?? '',
                                  lat: address?.latitude,
                                  lng: address?.longitude,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_city_rounded, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                address != null
                                    ? address.getFormattedAddress()
                                    : 'العنوان غير محدد',
                                style: const TextStyle(fontSize: 14, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Order Items Summary
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'محتويات الطرد / الشحنة',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _currentOrder.items.length,
                          separatorBuilder: (context, index) => const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final item = _currentOrder.items[index];
                            return Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${item.quantity}x',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.productName ?? item.offerName ?? 'منتج',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Text(
                                  AppCurrencyHelper.formatDual(item.totalPrice, isArabic: true),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            );
                          },
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('أجرة التوصيل المحصلة:'),
                            Text(
                              AppCurrencyHelper.formatDual(_currentOrder.shippingCost, isArabic: true),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('طريقة الدفع:'),
                            Text(
                              _currentOrder.paymentMethod == PaymentMethod.cashOnDelivery
                                  ? 'الدفع عند الاستلام (COD) - يلزم تحصيل ${AppCurrencyHelper.formatDual(_currentOrder.storeTotal, isArabic: true)}'
                                  : 'مدفوع إلكترونياً ✅',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _currentOrder.paymentMethod == PaymentMethod.cashOnDelivery
                                    ? Colors.amber.shade900
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Action Transition Buttons
                if (_isUpdating)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_currentOrder.status == OrderStatus.confirmed ||
                          _currentOrder.status == OrderStatus.preparing ||
                          _currentOrder.status == OrderStatus.ready) ...[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.inventory_2_rounded),
                          label: const Text('تم استلام الشحنة من المحل (الانتقال للتوصيل)'),
                          onPressed: () => _updateStatus(OrderStatus.shipped),
                        ),
                      ] else if (_currentOrder.status == OrderStatus.shipped) ...[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text('تم تسليم الشحنة للعميل بنجاح ✅'),
                          onPressed: () => _updateStatus(OrderStatus.delivered),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('تعذر التسليم / إلغاء الطلب'),
                          onPressed: () => _updateStatus(OrderStatus.cancelled),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
