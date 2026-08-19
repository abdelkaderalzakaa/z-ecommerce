import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/order/cart_model.dart';
import 'package:z_ecommerce/data/models/order/order_group_model.dart';
import 'package:z_ecommerce/data/models/order/order_item_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Validates cart items against live database data and creates an order group atomically.
  /// Uses a Firestore Transaction to ensure stock is decreased safely without race conditions.
  Future<OrderGroupModel?> checkoutAndCreateOrder({
    required String customerId,
    required Map<String, List<CartItemModel>> cartByStore,
    required PaymentMethod paymentMethod,
    required String shippingAddressSnapshot,
  }) async {
    final orderGroupId = _firestore.collection('order_groups').doc().id;
    
    OrderGroupModel? createdGroup;

    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Re-fetch all products to validate prices, discounts, and stock
        final Map<String, ProductModel> liveProducts = {};
        for (final storeItems in cartByStore.values) {
          for (final item in storeItems) {
            if (item.productId != null && !liveProducts.containsKey(item.productId)) {
              final productDocRef = _firestore.collection('products').doc(item.productId);
              final productSnapshot = await transaction.get(productDocRef);
              
              if (!productSnapshot.exists) {
                throw Exception('Product ${item.productName} no longer exists.');
              }
              liveProducts[item.productId!] = ProductModel.fromMap(
                productSnapshot.data() as Map<String, dynamic>,
                docId: productSnapshot.id,
              );
            }
          }
        }

        // 2. Validate Cart and Prepare Order Documents
        double globalSubtotal = 0.0;
        double globalShippingTotal = 0.0;
        double globalDiscountTotal = 0.0; // Future enhancement: handle cart-level offers
        
        final List<OrderModel> ordersToCreate = [];
        final List<OrderItemModel> orderItemsToCreate = [];
        final Map<DocumentReference, Map<String, dynamic>> productsToUpdate = {};

        for (final entry in cartByStore.entries) {
          final businessId = entry.key;
          final items = entry.value;
          
          if (items.isEmpty) continue;

          final orderId = _firestore.collection('orders').doc().id;
          double storeSubtotal = 0.0;
          double storeShipping = 0.0; // Basic implementation, can be enhanced

          for (final cartItem in items) {
            if (cartItem.productId == null) continue; // Assuming purely product orders for now
            
            final liveProduct = liveProducts[cartItem.productId!];
            if (liveProduct == null || !liveProduct.isActive) {
              throw Exception('Product ${cartItem.productName} is currently unavailable.');
            }

            // Find matching variant
            final variantKey = cartItem.selectedVariant?.variantKey ?? 'standard';
            final int liveVariantIndex = liveProduct.variants.indexWhere((v) => v.variantKey == variantKey);
            
            if (liveVariantIndex == -1) {
              throw Exception('Variant for ${cartItem.productName} no longer exists.');
            }

            final liveVariant = liveProduct.variants[liveVariantIndex];

            // Stock Validation
            if (liveVariant.stock < cartItem.quantity) {
              throw Exception('Insufficient stock for ${cartItem.productName}. Only ${liveVariant.stock} left.');
            }

            // Price & Discount Validation (recalculate)
            final double liveUnitPrice = liveProduct.getPriceForVariant(liveVariant);
            final double liveDiscountAmount = liveVariant.price - liveUnitPrice;
            
            final double itemTotalPrice = liveUnitPrice * cartItem.quantity;

            storeSubtotal += itemTotalPrice;

            // Prepare OrderItem Snapshot
            final orderItem = OrderItemModel(
              id: _firestore.collection('order_items').doc().id,
              orderId: orderId,
              productId: liveProduct.id,
              variantKey: variantKey,
              productName: liveProduct.name,
              variantName: liveVariant.name.isNotEmpty ? liveVariant.name : variantKey,
              productImage: liveProduct.displayImage,
              unitPrice: liveUnitPrice,
              quantity: cartItem.quantity,
              discountAmount: liveDiscountAmount * cartItem.quantity,
              totalPrice: itemTotalPrice,
            );
            orderItemsToCreate.add(orderItem);

            // Prepare Stock Deduction
            // We must update the whole variants array in Firestore
            if (!productsToUpdate.containsKey(_firestore.collection('products').doc(liveProduct.id))) {
              productsToUpdate[_firestore.collection('products').doc(liveProduct.id)] = {
                'variants': List<Map<String, dynamic>>.from(liveProduct.variants.map((v) => v.toMap()))
              };
            }
            
            // Deduct stock in the prepared array
            final preparedVariants = productsToUpdate[_firestore.collection('products').doc(liveProduct.id)]!['variants'] as List<Map<String, dynamic>>;
            preparedVariants[liveVariantIndex]['stock'] = liveVariant.stock - cartItem.quantity;
          }

          // Calculate Store Shipping (if any product is not free shipping, add cost)
          for (final cartItem in items) {
             final liveProduct = liveProducts[cartItem.productId!];
             if (liveProduct != null && !liveProduct.isFreeShipping && liveProduct.shippingCost > storeShipping) {
                storeShipping = liveProduct.shippingCost; 
             }
          }

          globalSubtotal += storeSubtotal;
          globalShippingTotal += storeShipping;

          ordersToCreate.add(OrderModel(
            id: orderId,
            orderGroupId: orderGroupId,
            businessId: businessId,
            customerId: customerId,
            createdAt: DateTime.now(),
            status: OrderStatus.pending,
            subTotal: storeSubtotal,
            shippingCost: storeShipping,
            storeTotal: storeSubtotal + storeShipping,
          ));
        }

        final grandTotal = globalSubtotal + globalShippingTotal - globalDiscountTotal;

        final orderGroup = OrderGroupModel(
          id: orderGroupId,
          customerId: customerId,
          createdAt: DateTime.now(),
          subtotal: globalSubtotal,
          shippingTotal: globalShippingTotal,
          discountTotal: globalDiscountTotal,
          grandTotal: grandTotal,
          paymentMethod: paymentMethod,
          paymentStatus: paymentMethod == PaymentMethod.cashOnDelivery ? PaymentStatus.pending : PaymentStatus.paid,
          shippingAddressSnapshot: shippingAddressSnapshot,
        );

        // 3. Execute all writes
        
        // Write OrderGroup
        transaction.set(_firestore.collection('order_groups').doc(orderGroupId), orderGroup.toMap());

        // Write Orders
        for (final order in ordersToCreate) {
          transaction.set(_firestore.collection('orders').doc(order.id), order.toMap());
        }

        // Write OrderItems
        for (final item in orderItemsToCreate) {
          transaction.set(_firestore.collection('order_items').doc(item.id), item.toMap());
        }

        // Update Products Stock
        productsToUpdate.forEach((docRef, data) {
          transaction.update(docRef, data);
        });

        createdGroup = orderGroup;
      });

      return createdGroup;
    } catch (e) {
      debugPrint('Checkout failed: $e');
      throw Exception('Checkout failed: $e');
    }
  }

  // Basic fetches for future phases
  Stream<List<OrderModel>> streamOrdersByStore(String storeId) {
    return _firestore
        .collection('orders')
        .where('businessId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<OrderModel>> streamOrdersByCustomer(String customerId) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    try {
      final snapshot = await _firestore
          .collection('order_items')
          .where('orderId', isEqualTo: orderId)
          .get();
      return snapshot.docs
          .map((doc) => OrderItemModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching order items: $e');
      return [];
    }
  }

  Future<bool> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus.name,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
    return false;
  }
}
