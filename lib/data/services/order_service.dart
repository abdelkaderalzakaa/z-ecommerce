import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/order/cart_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Validates cart items against live database data and creates an order atomically.
  /// Uses a Firestore Transaction to ensure stock is decreased safely without race conditions.
  Future<OrderModel?> checkoutAndCreateOrder({
    required String customerId,
    required Map<String, List<CartItemModel>> cartByStore,
    required PaymentMethod paymentMethod,
    required AddressModel? shippingAddressSnapshot,
  }) async {
    OrderModel? createdOrder;
    String? transactionError;

    try {
      await _firestore.runTransaction((transaction) async {
        try {
          // 1. Re-fetch all products to validate prices, discounts, and stock
          final Map<String, ProductModel> liveProducts = {};
          for (final storeItems in cartByStore.values) {
            for (final item in storeItems) {
              if (item.productId != null && !liveProducts.containsKey(item.productId)) {
                final productDocRef = _firestore.collection('products').doc(item.productId);
                final productSnapshot = await transaction.get(productDocRef);
                
                if (!productSnapshot.exists) {
                  transactionError = 'Product ${item.productName} no longer exists.';
                  return;
                }
                liveProducts[item.productId!] = ProductModel.fromMap(
                  productSnapshot.data() as Map<String, dynamic>,
                  docId: productSnapshot.id,
                );
              }
            }
          }

          if (transactionError != null) return;

          // 2. Validate Cart and Prepare Order Documents
          final List<OrderModel> ordersToCreate = [];
          final Map<DocumentReference, Map<String, dynamic>> productsToUpdate = {};

          for (final entry in cartByStore.entries) {
            final businessId = entry.key;
            final items = entry.value;
            
            if (items.isEmpty) continue;

            final orderId = _firestore.collection('orders').doc().id;
            double storeSubtotal = 0.0;
            double storeShipping = 0.0; 
            double storeDiscountTotal = 0.0; 
            final List<CartItemModel> finalItems = [];

            for (final cartItem in items) {
              if (cartItem.productId == null) continue; // Assuming purely product orders for now
              
              final liveProduct = liveProducts[cartItem.productId!];
              if (liveProduct == null || !liveProduct.isActive) {
                transactionError = 'Product ${cartItem.productName} is currently unavailable.';
                return;
              }

              // Find matching variant
              final variantKey = cartItem.selectedVariant?.variantKey ?? liveProduct.defaultVariant.variantKey;
              final int liveVariantIndex = liveProduct.variants.indexWhere((v) => v.variantKey == variantKey);
              
              if (liveVariantIndex == -1) {
                transactionError = 'Variant for ${cartItem.productName} no longer exists.';
                return;
              }

              final liveVariant = liveProduct.variants[liveVariantIndex];

              // Stock Validation (-1 indicates unlimited stock)
              if (liveVariant.stock != -1 && liveVariant.stock < cartItem.quantity) {
                transactionError = 'Insufficient stock for ${cartItem.productName}. Only ${liveVariant.stock} left.';
                return;
              }

              // Price & Discount Validation (recalculate)
              final double liveUnitPrice = liveProduct.getPriceForVariant(liveVariant);
              final double liveDiscountAmount = liveVariant.price - liveUnitPrice;
              
              final double itemTotalPrice = liveUnitPrice * cartItem.quantity;

              storeSubtotal += itemTotalPrice;
              storeDiscountTotal += (liveDiscountAmount * cartItem.quantity);

              // Prepare updated CartItemModel with live prices
              final updatedItem = CartItemModel(
                id: _firestore.collection('order_items').doc().id, // Generate a unique ID for this line item
                type: cartItem.type,
                productId: cartItem.productId,
                productName: cartItem.productName,
                productImage: cartItem.productImage,
                businessId: cartItem.businessId,
                selectedVariant: liveVariant,
                offerId: cartItem.offerId,
                offerName: cartItem.offerName,
                displayPrice: liveVariant.price, // Save original price here, total price will subtract discount
                discountAmount: liveDiscountAmount * cartItem.quantity,
                quantity: cartItem.quantity,
              );
              finalItems.add(updatedItem);

              // Prepare Stock Deduction
              if (!productsToUpdate.containsKey(_firestore.collection('products').doc(liveProduct.id))) {
                productsToUpdate[_firestore.collection('products').doc(liveProduct.id)] = {
                  'variants': List<Map<String, dynamic>>.from(liveProduct.variants.map((v) => v.toMap()))
                };
              }
              
              // Deduct stock in the prepared array if not unlimited
              final preparedVariants = productsToUpdate[_firestore.collection('products').doc(liveProduct.id)]!['variants'] as List<Map<String, dynamic>>;
              if (liveVariant.stock != -1) {
                preparedVariants[liveVariantIndex]['stock'] = liveVariant.stock - cartItem.quantity;
              }
            }

            // Calculate Store Shipping (if any product is not free shipping, add cost)
            for (final cartItem in items) {
               final liveProduct = liveProducts[cartItem.productId!];
               if (liveProduct != null && !liveProduct.isFreeShipping && liveProduct.shippingCost > storeShipping) {
                  storeShipping = liveProduct.shippingCost; 
               }
            }

            final grandTotal = storeSubtotal + storeShipping - storeDiscountTotal;

            final order = OrderModel(
              id: orderId,
              businessId: businessId,
              customerId: customerId,
              createdAt: DateTime.now(),
              status: OrderStatus.pending,
              items: finalItems,
              subTotal: storeSubtotal,
              shippingCost: storeShipping,
              discountTotal: storeDiscountTotal,
              storeTotal: grandTotal,
              paymentMethod: paymentMethod,
              paymentStatus: paymentMethod == PaymentMethod.cashOnDelivery ? PaymentStatus.pending : PaymentStatus.paid,
              shippingAddressSnapshot: shippingAddressSnapshot,
            );

            ordersToCreate.add(order);
          }

          // 3. Execute all writes
          
          // Write Orders
          for (final order in ordersToCreate) {
            transaction.set(_firestore.collection('orders').doc(order.id), order.toMap());
          }

          // Update Products Stock
          productsToUpdate.forEach((docRef, data) {
            transaction.update(docRef, data);
          });

          if (ordersToCreate.isNotEmpty) {
            createdOrder = ordersToCreate.first;
          }
        } catch (innerE, innerStack) {
          debugPrint('Inner transaction error: $innerE');
          debugPrint('Inner stack: $innerStack');
          transactionError = 'An unexpected error occurred during checkout.';
          return;
        }
      });

      if (transactionError != null) {
        throw Exception(transactionError);
      }

      return createdOrder;
    } catch (e, stack) {
      debugPrint('Checkout failed caught in outer block: $e');
      debugPrint('Stack: $stack');
      throw Exception('Checkout failed: $e');
    }
  }
  // Basic fetches for future phases
  Stream<List<OrderModel>> streamAllOrders() {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromMap(Map<String, dynamic>.from(data as Map), docId: doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
  Stream<List<OrderModel>> streamOrdersByStore(String storeId) {
    return _firestore
        .collection('orders')
        .where('businessId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromMap(Map<String, dynamic>.from(data as Map), docId: doc.id);
      }).toList();
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
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromMap(Map<String, dynamic>.from(data as Map), docId: doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
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
      if (kDebugMode) {
        print('Error updating order status: $e');
      }
      return false;
    }
  }

  Future<bool> updateOrderAddress({
    required String orderId,
    required AddressModel newAddress,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'shippingAddressSnapshot': newAddress.toMap(),
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating order address: $e');
      }
      return false;
    }
  }

  Future<bool> updateOrderDelivery({
    required String orderId,
    required String? deliveryId,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'deliveryId': deliveryId,
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating order delivery: $e');
      }
      return false;
    }
  }
}
