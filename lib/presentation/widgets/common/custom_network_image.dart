import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BoxShape shape;
  final BorderRadiusGeometry? borderRadius;
  final Widget? fallbackWidget;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.fallbackWidget,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final defaultFallback = Container(
      width: width,
      height: height,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey.shade500,
          size: (width != null && width! < 30) ? 14 : 24,
        ),
      ),
    );

    Widget imageWidget = imageUrl.isEmpty
        ? (fallbackWidget ?? defaultFallback)
        : Image.network(
            imageUrl,
            width: width,
            height: height,
            fit: fit,
            loadingBuilder: loadingBuilder,
            errorBuilder: errorBuilder ?? (context, error, stackTrace) => fallbackWidget ?? defaultFallback,
          );

    if (shape == BoxShape.circle) {
      return ClipOval(child: imageWidget);
    } else if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }
}
