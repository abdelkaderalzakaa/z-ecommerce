import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';

class OrderTrackerWidget extends StatelessWidget {
  final OrderStatus currentStatus;
  final bool isMobile;

  const OrderTrackerWidget({
    super.key,
    required this.currentStatus,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (currentStatus == OrderStatus.cancelled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.accent),
        ),
        child: Column(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.accent, size: 48),
            const SizedBox(height: 16),
            Text(
              'تم إلغاء هذا الطلب',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accent),
            ),
          ],
        ),
      );
    }

    // Define the sequence of statuses
    final statuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    // Some businesses use 'ready' instead of 'shipped'. If the order is ready, 
    // we inject it into the pipeline instead of shipped.
    if (currentStatus == OrderStatus.ready) {
      statuses[3] = OrderStatus.ready;
    }

    final currentIndex = statuses.indexOf(currentStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مسار الطلبية',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (isMobile)
            _buildHorizontalTracker(context, statuses, currentIndex)
          else
            _buildVerticalTracker(context, statuses, currentIndex),
        ],
      ),
    );
  }

  Widget _buildVerticalTracker(BuildContext context, List<OrderStatus> statuses, int currentIndex) {
    return Column(
      children: List.generate(statuses.length, (index) {
        return _buildStep(
          context,
          status: statuses[index],
          isCompleted: index <= currentIndex,
          isLast: index == statuses.length - 1,
          isVertical: true,
        );
      }),
    );
  }

  Widget _buildHorizontalTracker(BuildContext context, List<OrderStatus> statuses, int currentIndex) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(statuses.length, (index) {
          return _buildStep(
            context,
            status: statuses[index],
            isCompleted: index <= currentIndex,
            isLast: index == statuses.length - 1,
            isVertical: false,
          );
        }),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required OrderStatus status,
    required bool isCompleted,
    required bool isLast,
    required bool isVertical,
  }) {
    final activeColor = AppColors.green;
    final inactiveColor = Theme.of(context).dividerColor;
    final color = isCompleted ? activeColor : inactiveColor;

    String label = '';
    IconData icon = Icons.circle;

    switch (status) {
      case OrderStatus.pending:
        label = 'قيد الانتظار';
        icon = Icons.access_time;
        break;
      case OrderStatus.confirmed:
        label = 'تم التأكيد';
        icon = Icons.check_circle_outline;
        break;
      case OrderStatus.preparing:
        label = 'جاري التجهيز';
        icon = Icons.inventory_2_outlined;
        break;
      case OrderStatus.ready:
        label = 'جاهز للاستلام';
        icon = Icons.storefront_outlined;
        break;
      case OrderStatus.shipped:
        label = 'مشحون';
        icon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.delivered:
        label = 'تم التوصيل';
        icon = Icons.home_outlined;
        break;
      default:
        break;
    }

    if (isVertical) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? color.withOpacity(0.1) : Colors.transparent,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: color,
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? Theme.of(context).textTheme.bodyLarge?.color : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: 100, // Fixed width for horizontal items
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? color : Colors.transparent,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? color.withOpacity(0.1) : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: isLast ? Colors.transparent : color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                color: isCompleted ? Theme.of(context).textTheme.bodyLarge?.color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
  }
}
