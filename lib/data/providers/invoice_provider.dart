import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import '../models/cart_model.dart';
import '../models/address_model.dart';
import 'dart:math';

class InvoiceProvider extends ChangeNotifier {
  final List<InvoiceModel> _invoices = [];
  List<InvoiceModel> get invoices => _invoices;

  void generateInvoice({
    required String storeId,
    required List<CartItemModel> items,
    double discount = 0,
    double tax = 0,
    double shippingCost = 15.0,
    required AddressModel shippingAddress,
  }) {
    if (items.isEmpty) return;

    final newInvoice = InvoiceModel(
      invoiceId: 'INV-${Random().nextInt(999999).toString().padLeft(6, '0')}',
      storeId: storeId,
      items: List.from(items), // Create a copy of current items
      discount: discount,
      tax: tax,
      shippingCost: shippingCost,
      date: DateTime.now(),
      status: 'Pending',
      shippingAddress: shippingAddress,
    );

    _invoices.add(newInvoice);
    notifyListeners();
  }
}