import 'package:flutter/material.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';

class ProductGallery extends StatefulWidget {
  final List<String> images; // Can be paths or URLs, using placeholders for now

  const ProductGallery({super.key, required this.images});

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          _MainImage(image: widget.images[_selectedIndex]),
          const SizedBox(height: 12),
          SizedBox(
            height: 106,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                widget.images.length,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == widget.images.length - 1 ? 0 : 12,
                    ),
                    child: _Thumbnail(
                      image: widget.images[index],
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
              widget.images.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == widget.images.length - 1 ? 0 : 14,
                ),
                child: SizedBox(
                  height: 167,
                  child: _Thumbnail(
                    image: widget.images[index],
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
            child: _MainImage(image: widget.images[_selectedIndex]),
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEED),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Center(
        // TODO: Replace with actual image
        child: Icon(
          Icons.checkroom,
          size: 120,
          color: Colors.grey.withValues(alpha: 0.5),
        ),
      ),
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EEED),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            // TODO: Replace with actual image
            child: Icon(
              Icons.checkroom,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
