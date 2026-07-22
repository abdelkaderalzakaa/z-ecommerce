import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/company_provider.dart';
import '../global/router/app_routes.dart';

class CartEmptyPage extends StatelessWidget {
  const CartEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart is Empty')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("Looks like you haven't added anything to your cart yet.", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final cid = context.read<CompanyProvider>().companySettings?.id ?? 'cmp_001';
                context.go(AppRoutes.toShop(cid));
              },
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}
