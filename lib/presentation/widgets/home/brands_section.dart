import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import '../../../data/providers/business_provider.dart';
import '../../../data/models/product/brand_model.dart';
import '../../global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/pages/categories_page.dart';

class BrandsSection extends StatefulWidget {
  const BrandsSection({super.key});

  @override
  State<BrandsSection> createState() => _BrandsSectionState();
}

class _BrandsSectionState extends State<BrandsSection> {
  late final ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        double currentScroll = _scrollController.position.pixels;
        // Scroll forward slowly by 1 pixel every 30ms
        _scrollController.jumpTo(currentScroll + 1.0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyData = context.watch<CompanyProvider>().companySettings;
    final brands = companyData?.brands ?? [];

    if (brands.isEmpty) return const SizedBox();

    return Container(
      color: Theme.of(context).primaryColor,
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics:
            const NeverScrollableScrollPhysics(), // Prevent manual scroll interference
        itemBuilder: (context, index) {
          final brand = brands[index % brands.length];
          return Center(
            child: _BrandItem(
              brand: brand,
              businessId: companyData?.id ?? 'cmp_001',
            ),
          );
        },
      ),
    );
  }
}

class _BrandItem extends StatelessWidget {
  final BrandModel brand;
  final String businessId;
  const _BrandItem({required this.brand, required this.businessId});

  @override
  Widget build(BuildContext context) {
    final isItalic =
        brand.name.toUpperCase() == 'VERSACE' ||
        brand.name.toUpperCase() == 'GUCCI';

    return GestureDetector(
      onTap: () {
        changeScreen(context, const CategoriesPage());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            brand.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
