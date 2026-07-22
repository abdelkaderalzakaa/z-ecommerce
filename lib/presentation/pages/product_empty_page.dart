import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/company_provider.dart';
import '../global/router/app_routes.dart';

class ProductEmptyPage extends StatelessWidget {
  const ProductEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.production_quantity_limits, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('The product you are looking for does not exist.', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final cid = context.read<CompanyProvider>().companySettings?.id ?? 'cmp_001';
                context.go(AppRoutes.toHome(cid));
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
