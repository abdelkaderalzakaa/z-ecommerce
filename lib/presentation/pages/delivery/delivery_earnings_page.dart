import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/currency_helper.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';

class DeliveryEarningsPage extends StatelessWidget {
  const DeliveryEarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final isAr = localeProvider.locale.languageCode == 'ar';

    final deliveryProvider = context.watch<DeliveryProvider>();
    final deliveredOrders = deliveryProvider.deliveredOrders;

    final totalEarnings = deliveryProvider.totalDeliveredEarnings;
    final todayEarnings = deliveryProvider.todayDeliveredEarnings;

    // Calculate COD collections
    final codTotal = deliveredOrders
        .where((o) => o.paymentMethod == PaymentMethod.cashOnDelivery)
        .fold<double>(0.0, (sum, o) => sum + o.storeTotal);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isAr ? 'المحفظة وأرباح التوصيل' : 'Delivery Wallet & Earnings'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'إجمالي مستحقات وأجور التوصيل' : 'Total Delivery Earnings',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppCurrencyHelper.formatUSD(totalEarnings),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppCurrencyHelper.formatLBP(totalEarnings, isArabic: isAr),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isAr
                              ? 'أرباح اليوم: ${AppCurrencyHelper.formatUSD(todayEarnings)} (${AppCurrencyHelper.formatLBP(todayEarnings, isArabic: true)})'
                              : 'Today: ${AppCurrencyHelper.formatUSD(todayEarnings)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isAr ? '${deliveredOrders.length} طلبات مكتملة' : '${deliveredOrders.length} Completed',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // COD and Financial Distribution Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.payments_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isAr ? 'مقبوضات كاش (COD)' : 'Cash Collected (COD)',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppCurrencyHelper.formatUSD(codTotal),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppCurrencyHelper.formatLBP(codTotal, isArabic: isAr),
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAr ? 'مبالغ تم تحصيلها نقداً' : 'Cash collected upon delivery',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.credit_card_rounded, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isAr ? 'مدفوعات إلكترونية' : 'Digital Earnings',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppCurrencyHelper.formatUSD(totalEarnings),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppCurrencyHelper.formatLBP(totalEarnings, isArabic: isAr),
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAr ? 'محولة للمحفظة الرقمية' : 'Transferred to digital wallet',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Delivered Orders History Table / Feed
            Text(
              isAr ? 'سجل الشحنات المكتملة والمستحقات' : 'Completed Deliveries & Payouts',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (deliveredOrders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                ),
                child: Center(
                  child: Text(
                    isAr ? 'لا توجد طلبات مسلمة حتى الآن لعرض سجل الأرباح' : 'No delivered orders yet',
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: deliveredOrders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final order = deliveredOrders[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr
                                      ? 'طلب #${order.id.substring(0, order.id.length.clamp(0, 8))}'
                                      : 'Order #${order.id.substring(0, order.id.length.clamp(0, 8))}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isAr
                                      ? 'التسليم إلى: ${order.shippingAddressSnapshot?.city.get(context) ?? 'المدينة'} • ${order.createdAt.toString().substring(0, 10)}'
                                      : 'Delivery to: ${order.shippingAddressSnapshot?.city.get(context) ?? 'City'} • ${order.createdAt.toString().substring(0, 10)}',
                                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '+${AppCurrencyHelper.formatDual(order.shippingCost, isArabic: isAr)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                order.paymentMethod == PaymentMethod.cashOnDelivery
                                    ? (isAr ? 'نقدي (COD)' : 'Cash (COD)')
                                    : (isAr ? 'إلكتروني' : 'Prepaid'),
                                style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
