import 'cart_model.dart';
import 'address_model.dart';

class InvoiceModel {
  final String invoiceId;
  final String storeId; // Added storeId
  final List<CartItemModel> items;
  final double discount;
  final double tax;
  final double shippingCost;
  final DateTime date;
  final String status;
  final AddressModel shippingAddress;

  InvoiceModel({
    required this.invoiceId,
    required this.storeId,
    required this.items,
    this.discount = 0.0,
    required this.tax,
    required this.shippingCost,
    required this.date,
    this.status = 'Pending',
    required this.shippingAddress,
  });

  double get subTotal =>
      items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
      
  double get total => subTotal - discount + tax + shippingCost;
}
