import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/company_settings_model.dart';
import 'package:z_ecommerce/data/models/localized_string.dart';
import 'package:z_ecommerce/data/providers/company_provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../global/translate/translation_keys.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final companyData = context.watch<CompanyProvider>().companySettings;

    if (companyData == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Area (Image & Details)
          if (isMobile) ...[
            _HeroCardsCarousel(companyData: companyData),
            const SizedBox(height: 24),
            _HeroDetails(companyData: companyData, isMobile: true),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _HeroCardsCarousel(companyData: companyData)),
                const SizedBox(width: 48),
                Expanded(flex: 7, child: _HeroDetails(companyData: companyData, isMobile: false)),
              ],
            ),
          ],
          const SizedBox(height: 48),
          
          // Bottom Area (Map & Branches)
          _HeroBottomSection(companyData: companyData, isMobile: isMobile),
        ],
      ),
    );
  }
}

class _HeroCardsCarousel extends StatefulWidget {
  final CompanySettingsModel companyData;
  const _HeroCardsCarousel({required this.companyData});

  @override
  State<_HeroCardsCarousel> createState() => _HeroCardsCarouselState();
}

class _HeroCardsCarouselState extends State<_HeroCardsCarousel> {
  int _currentIndex = 0;
  late final PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final cards = widget.companyData.heroCards ?? [];
      if (cards.isEmpty || !_pageController.hasClients) return;
      
      int nextIndex = _currentIndex + 1;
      if (nextIndex >= cards.length) {
        nextIndex = 0;
      }
      
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.companyData.heroCards ?? [];

    if (cards.isEmpty) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: Icon(Icons.info_outline, size: 64, color: Colors.grey)),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 400,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: cards.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final card = cards[index];
                return Container(
                  color: const Color(0xFF2E6B40), // Green shade as requested
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        card.value.get(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        card.label.get(context),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // Page Indicators
        if (cards.length > 1)
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cards.length, (index) {
                final isActive = _currentIndex == index;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _HeroDetails extends StatelessWidget {
  final CompanySettingsModel companyData;
  final bool isMobile;
  
  const _HeroDetails({required this.companyData, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating
        if (companyData.rate > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1), // Light yellow
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  companyData.rate.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star, color: Colors.amber, size: 18),
              ],
            ),
          ),
        
        const SizedBox(height: 24),
        
        // Title
        Text(
          companyData.slogan.get(context),
          style: TextStyle(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.displayLarge?.color,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Description
        Text(
          companyData.description.get(context),
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            height: 1.6,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Statistics
        Builder(
          builder: (context) {
            final stats = <StoreStatistic>[];
            if (companyData.visitor != null) {
              stats.add(StoreStatistic(value: LocalizedString(ar: '${companyData.visitor}', en: '${companyData.visitor}'), label: const LocalizedString(ar: 'الزيارات', en: 'Visits'), icon: 'visits'));
            }
            if (companyData.orders != null) {
              stats.add(StoreStatistic(value: LocalizedString(ar: '${companyData.orders}', en: '${companyData.orders}'), label: const LocalizedString(ar: 'الطلبات', en: 'Orders'), icon: 'orders'));
            }
            if (companyData.followers != null) {
              stats.add(StoreStatistic(value: LocalizedString(ar: '${companyData.followers}', en: '${companyData.followers}'), label: const LocalizedString(ar: 'المتابعين', en: 'Followers'), icon: 'followers'));
            }
            
            if (stats.isEmpty) return const SizedBox.shrink();
            
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: stats.asMap().entries.map((entry) {
                final index = entry.key;
                final stat = entry.value;
                return Expanded(
                  child: Row(
                    children: [
                      if (index > 0)
                        Container(
                          height: 40,
                          width: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                      Expanded(
                        child: Column(
                          children: [
                            Icon(_getIconData(stat.icon), size: 24, color: Theme.of(context).iconTheme.color),
                            const SizedBox(height: 8),
                            Text(
                              stat.label.get(context),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stat.value.get(context),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                }).toList(),
              ),
            );
          }
        ),  const SizedBox(height: 32),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up_alt_outlined),
                label: const Text('إعجاب'), // Assuming RTL context usually, or use translations if available
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('متابعة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF232B25), // Dark greenish black matching the design
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'visits':
        return Icons.view_agenda_outlined;
      case 'orders':
        return Icons.shopping_bag_outlined;
      case 'followers':
        return Icons.person_outline;
      default:
        return Icons.info_outline;
    }
  }
}

class _HeroBottomSection extends StatelessWidget {
  final CompanySettingsModel companyData;
  final bool isMobile;
  
  const _HeroBottomSection({required this.companyData, required this.isMobile});

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branches = companyData.addresses ?? [];
    
    return isMobile
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (branches.isNotEmpty) _buildMapCard(context, branches.first),
                ...branches.map((branch) => _buildBranchCard(context, branch)),
              ],
            ),
          )
        : Row(
            children: [
              if (branches.isNotEmpty) Expanded(flex: 2, child: _buildMapCard(context, branches.first)),
              ...branches.map((branch) => Expanded(flex: 3, child: _buildBranchCard(context, branch))),
            ],
          );
  }

  Widget _buildMapCard(BuildContext context, CompanyAddressModel address) {
    return GestureDetector(
      onTap: () => _openGoogleMaps(address.latitude, address.longitude),
      child: Container(
        margin: const EdgeInsets.only(left: 16),
        height: 180,
        width: 150,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 48),
            const SizedBox(height: 16),
            const Text('الخريطة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCard(BuildContext context, CompanyAddressModel branch) {
    return Container(
      margin: const EdgeInsets.only(left: 16), // Margin for spacing between cards
      height: 180,
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        image: branch.imageUrl.isNotEmpty ? DecorationImage(
          image: NetworkImage(branch.imageUrl),
          fit: BoxFit.cover,
        ) : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: branch.imageUrl.isNotEmpty ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ) : null,
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.address.get(context),
                    style: TextStyle(
                      color: branch.imageUrl.isNotEmpty ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
