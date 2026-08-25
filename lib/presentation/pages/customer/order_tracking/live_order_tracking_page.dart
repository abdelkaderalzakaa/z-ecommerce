import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/currency_helper.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class LiveOrderTrackingPage extends StatelessWidget {
  final String orderId;
  final OrderModel? initialOrder;

  const LiveOrderTrackingPage({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  Future<void> _launchCaller(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    if (phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderProvider = context.watch<OrderProvider>();

    // Lookup order live from customer orders or all orders stream
    final liveOrder = orderProvider.customerOrders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => orderProvider.allOrders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => initialOrder ?? OrderModel.empty(),
      ),
    );

    final business = context.watch<BusinessProvider>().getBusinessById(liveOrder.businessId);
    final businessName = business?.localization.name.get(context) ?? 'المتجر';
    final businessPhone = business?.ownerPhone ?? '';

    final deliveryEntity = liveOrder.deliveryId != null
        ? context.watch<DeliveryProvider>().getDeliveryById(liveOrder.deliveryId!)
        : null;

    final driverName = liveOrder.deliveryDriverName ?? deliveryEntity?.name ?? 'مندوب التوصيل';
    final driverPhone = liveOrder.deliveryDriverPhone ?? deliveryEntity?.phone ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'تتبع مباشر للطلب #${orderId.substring(0, orderId.length.clamp(0, 8))}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Real-Time Status Hero Card
                _buildLiveHeroHeader(context, liveOrder),

                const SizedBox(height: 24),

                // 5-Step Animated Tracker Stepper
                _buildTrackingTimelineStepper(context, liveOrder),

                const SizedBox(height: 24),

                // Active Driver Card (shown when assigned or in-transit)
                if (liveOrder.status == OrderStatus.shipped ||
                    liveOrder.status == OrderStatus.ready ||
                    liveOrder.deliveryId != null) ...[
                  _buildDriverContactCard(
                    context,
                    driverName: driverName,
                    driverPhone: driverPhone,
                    isInTransit: liveOrder.status == OrderStatus.shipped,
                  ),
                  const SizedBox(height: 16),
                ],

                // Store Information Card
                _buildStoreCard(
                  context,
                  businessName: businessName,
                  businessPhone: businessPhone,
                ),

                const SizedBox(height: 16),

                // Order Items & Financial Summary
                _buildOrderSummaryCard(context, liveOrder),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveHeroHeader(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    final status = order.status;

    Color bg;
    Color border;
    IconData icon;
    String title;
    String subtitle;

    switch (status) {
      case OrderStatus.pending:
        bg = Colors.amber.withOpacity(0.12);
        border = Colors.amber;
        icon = Icons.hourglass_top_rounded;
        title = 'تم استلام طلبك وبانتظار موافقة المتجر';
        subtitle = 'يقوم المتجر الآن بمراجعة طلبك وتأكيده';
        break;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        bg = Colors.blue.withOpacity(0.12);
        border = Colors.blue;
        icon = Icons.outdoor_grill_rounded;
        title = 'جاري تجهيز طلبك في المتجر الآن 🍳';
        subtitle = 'المتجر يقوم بتجهيز وتغليف المنتجات بعناية';
        break;
      case OrderStatus.ready:
        bg = Colors.teal.withOpacity(0.12);
        border = Colors.teal;
        icon = Icons.inventory_2_rounded;
        title = 'طلبك جاهز بالمحل وبانتظار استلام المندوب 📦';
        subtitle = 'المندوب في طريقه لاستلام الشحنة من المتجر';
        break;
      case OrderStatus.shipped:
        bg = Colors.purple.withOpacity(0.12);
        border = Colors.purple;
        icon = Icons.directions_bike_rounded;
        title = 'المندوب في الطريق إليك الآن 🛵💨';
        subtitle = 'شحنتك خرجت مع المندوب وستصلك قريباً';
        break;
      case OrderStatus.delivered:
        bg = Colors.green.withOpacity(0.12);
        border = Colors.green;
        icon = Icons.check_circle_rounded;
        title = 'تم تسليم طلبك بنجاح! بالهناء والعافية 🎉';
        subtitle = 'نشكرك على تسوقك معنا ونتمنى لك يوماً سعيداً';
        break;
      case OrderStatus.cancelled:
        bg = Colors.red.withOpacity(0.12);
        border = Colors.red;
        icon = Icons.cancel_rounded;
        title = 'تم إلغاء الطلب';
        subtitle = order.deliveryNotes ?? 'تم إلغاء الطلب من قبل المتجر أو العميل';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: border.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: border, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
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
        ],
      ),
    );
  }

  Widget _buildTrackingTimelineStepper(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    final status = order.status;

    int currentStep = 0;
    if (status == OrderStatus.pending) currentStep = 0;
    if (status == OrderStatus.confirmed || status == OrderStatus.preparing) currentStep = 1;
    if (status == OrderStatus.ready) currentStep = 2;
    if (status == OrderStatus.shipped) currentStep = 3;
    if (status == OrderStatus.delivered) currentStep = 4;

    final steps = [
      {'title': 'تم تأكيد الطلب', 'subtitle': 'تم إرسال الطلب للمتجر', 'icon': Icons.receipt_long_rounded},
      {'title': 'قيد التجهيز', 'subtitle': 'جاري إعداد وتجهيز الطلب', 'icon': Icons.outdoor_grill_rounded},
      {'title': 'جاهز للاستلام', 'subtitle': 'جاهز وبانتظار المندوب', 'icon': Icons.inventory_2_rounded},
      {'title': 'في الطريق إليك', 'subtitle': 'المندوب في مسار التوصيل', 'icon': Icons.two_wheeler_rounded},
      {'title': 'تم التسليم', 'subtitle': 'وصل الطرد واستُلم بنجاح', 'icon': Icons.check_circle_rounded},
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مراحل خط سير وتجهيز الطلب',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final isPassed = index <= currentStep && status != OrderStatus.cancelled;
                final isCurrent = index == currentStep && status != OrderStatus.cancelled;
                final isLast = index == steps.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrent
                                  ? theme.primaryColor
                                  : isPassed
                                      ? Colors.green
                                      : (theme.brightness == Brightness.dark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200),
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: theme.primaryColor.withOpacity(0.35),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              steps[index]['icon'] as IconData,
                              color: isPassed ? Colors.white : Colors.grey,
                              size: 18,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: isPassed && index < currentStep
                                    ? Colors.green
                                    : (theme.brightness == Brightness.dark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade300),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                steps[index]['title'] as String,
                                style: TextStyle(
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 14,
                                  color: isCurrent
                                      ? theme.primaryColor
                                      : isPassed
                                          ? theme.textTheme.bodyLarge?.color
                                          : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                steps[index]['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverContactCard(
    BuildContext context, {
    required String driverName,
    required String driverPhone,
    required bool isInTransit,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.blue.withOpacity(0.3)),
      ),
      color: Colors.blue.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.withOpacity(0.15),
              child: const Icon(Icons.two_wheeler_rounded, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        driverName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isInTransit ? Colors.green.withOpacity(0.15) : Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isInTransit ? 'في الطريق إليك' : 'تم التعيين',
                          style: TextStyle(
                            color: isInTransit ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('مندوب توصيل معتمد', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (driverPhone.isNotEmpty) ...[
              IconButton.filledTonal(
                icon: const Icon(Icons.phone_rounded, color: Colors.blue, size: 20),
                tooltip: 'اتصال بالمندوب',
                onPressed: () => _launchCaller(driverPhone),
              ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                icon: const Icon(Icons.chat_rounded, color: Colors.green, size: 20),
                tooltip: 'واتساب المندوب',
                onPressed: () => _launchWhatsApp(driverPhone),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(
    BuildContext context, {
    required String businessName,
    required String businessPhone,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.primaryColor.withOpacity(0.12),
              child: Icon(Icons.storefront_rounded, color: theme.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('المتجر المرسل', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    businessName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (businessPhone.isNotEmpty) ...[
              IconButton(
                icon: const Icon(Icons.phone_rounded, color: Colors.blue, size: 20),
                onPressed: () => _launchCaller(businessPhone),
              ),
              IconButton(
                icon: const Icon(Icons.chat_rounded, color: Colors.green, size: 20),
                onPressed: () => _launchWhatsApp(businessPhone),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    final isCod = order.paymentMethod == PaymentMethod.cashOnDelivery;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ملخص الطلب والدفع',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text('${item.quantity}x ', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item.productName ?? item.offerName ?? 'منتج',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      AppCurrencyHelper.formatDual(item.totalPrice, isArabic: true),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('أجرة التوصيل:'),
                Text(
                  AppCurrencyHelper.formatDual(order.shippingCost, isArabic: true),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي الكلي:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  AppCurrencyHelper.formatDual(order.storeTotal, isArabic: true),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCod ? Colors.amber.withOpacity(0.12) : Colors.green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isCod ? Icons.payments_rounded : Icons.check_circle_rounded,
                    color: isCod ? Colors.amber.shade900 : Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCod ? 'الدفع نقداً عند الاستلام (COD)' : 'تم الدفع إلكترونياً بنجاح ✅',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isCod ? Colors.amber.shade900 : Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
