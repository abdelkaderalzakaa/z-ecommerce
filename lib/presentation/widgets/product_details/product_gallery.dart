import 'package:flutter/material.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';

class ProductGallery extends StatefulWidget {
  final List<String> images;

  const ProductGallery({super.key, required this.images});

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final listImages = widget.images.isEmpty ? ['placeholder'] : widget.images;
    if (_selectedIndex >= listImages.length) {
      _selectedIndex = 0;
    }

    if (listImages.length <= 1) {
      return SizedBox(
        height: isMobile ? 350 : 530,
        child: _MainImage(image: listImages.first),
      );
    }

    if (isMobile) {
      return Column(
        children: [
          _MainImage(image: listImages[_selectedIndex]),
          const SizedBox(height: 12),
          SizedBox(
            height: 106,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                listImages.length,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == listImages.length - 1 ? 0 : 12,
                    ),
                    child: _Thumbnail(
                      image: listImages[index],
                      isSelected: _selectedIndex == index,
                      onTap: () => setState(() => _selectedIndex = index),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 152,
          child: Column(
            children: List.generate(
              listImages.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == listImages.length - 1 ? 0 : 14,
                ),
                child: SizedBox(
                  height: 167,
                  child: _Thumbnail(
                    image: listImages[index],
                    isSelected: _selectedIndex == index,
                    onTap: () => setState(() => _selectedIndex = index),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 530,
            child: _MainImage(image: listImages[_selectedIndex]),
          ),
        ),
      ],
    );
  }
}

class _MainImage extends StatelessWidget {
  final String image;

  const _MainImage({required this.image});

  @override
  Widget build(BuildContext context) {
    final hasUrl = image.startsWith('http');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEED),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        image: hasUrl ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover) : null,
      ),
      child: !hasUrl
          ? Center(
              child: Icon(
                Icons.checkroom,
                size: 120,
                color: Colors.grey.withOpacity(0.5),
              ),
            )
          : null,
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const _Thumbnail({
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = image.startsWith('http');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EEED),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: 1.5,
            ),
            image: hasUrl ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover) : null,
          ),
          child: !hasUrl
              ? Center(
                  child: Icon(
                    Icons.checkroom,
                    size: 48,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
