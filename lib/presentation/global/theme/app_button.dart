import 'package:flutter/material.dart';

enum FormatButtonApp { outline, elevated, text, unique, icon }

class ButtonApp extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  final FormatButtonApp format;
  final IconData? icon;
  final Color? color;
  final double fontSize;
  final double radius;
  final bool isFullWidth;
  final bool isLoading;

  const ButtonApp({
    super.key,
    required this.label,
    this.onPressed,
    this.format = FormatButtonApp.elevated,
    this.icon,
    this.color,
    this.fontSize = 14,
    this.radius = 25,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null && !isLoading;
    final baseColor = isDisabled
        ? Colors.black26
        : color ?? Theme.of(context).primaryColor;

    EdgeInsets padding = EdgeInsets.fromLTRB(5, 5, 5, 5);
    // If fontSize is null, the Text widget inherits the size from the Button's Theme
    final labelWidget = Text(
      label,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.normal),
    );

    final double iconSize = fontSize + 2;

    Widget? iconWidget;
    if (isLoading) {
      iconWidget = SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: format == FormatButtonApp.elevated
              ? const AlwaysStoppedAnimation<Color>(Colors.white)
              : AlwaysStoppedAnimation<Color>(baseColor),
        ),
      );
    } else if (icon != null) {
      iconWidget = Container(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: iconSize, color: baseColor),
      );
    }

    // Disable button if loading
    final currentOnPressed = isLoading ? null : onPressed;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    final iconContainerColor = Colors.white;

    Widget buttonWidget;
    switch (format) {
      case FormatButtonApp.outline:
        final style = OutlinedButton.styleFrom(
          foregroundColor: baseColor,
          backgroundColor: Colors.transparent,
          side: BorderSide(color: baseColor),
          shape: shape,
          padding: padding,
        );
        buttonWidget = iconWidget != null
            ? OutlinedButton.icon(
                onPressed: currentOnPressed,
                icon: iconWidget,
                label: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: labelWidget,
                ),
                style: style,
              )
            : OutlinedButton(
                onPressed: currentOnPressed,
                style: style,
                child: labelWidget,
              );
        break;
      case FormatButtonApp.text:
        final style = TextButton.styleFrom(
          foregroundColor: baseColor,
          backgroundColor:
              Colors.transparent, // Fix: Prevent global theme bleed
          shape: shape,
          padding: padding,
        );

        buttonWidget = iconWidget != null
            ? TextButton.icon(
                onPressed: currentOnPressed,
                icon: iconWidget,
                label: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: labelWidget,
                ),
                style: style,
              )
            : TextButton(
                onPressed: currentOnPressed,
                style: style,
                child: labelWidget,
              );
        break;
      case FormatButtonApp.unique:
        // TextButton natively supports tinted backgrounds while keeping perfect, smooth ripple animations derived from the foregroundColor.
        final style = TextButton.styleFrom(
          backgroundColor: isDisabled
              ? baseColor.withOpacity(0.05)
              : baseColor.withOpacity(0.15),
          foregroundColor: baseColor,
          shape: shape,
          padding: padding,
        );

        buttonWidget = iconWidget != null
            ? TextButton.icon(
                onPressed: currentOnPressed,
                icon: Container(
                  decoration: BoxDecoration(
                    color: iconContainerColor,

                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: iconWidget,
                ),
                label: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: labelWidget,
                ),
                style: style,
              )
            : TextButton(
                onPressed: currentOnPressed,
                style: style,
                child: labelWidget,
              );
        break;
      case FormatButtonApp.icon:
        buttonWidget = Container(
          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: baseColor),
          ),
          child: InkWell(
            radius: radius,
            borderRadius: BorderRadius.circular(radius),
            onTap: currentOnPressed,
            child: iconWidget,
          ),
        );
        break;
      case FormatButtonApp.elevated:
        final style = ElevatedButton.styleFrom(
          disabledBackgroundColor: baseColor,
          backgroundColor: baseColor,
          foregroundColor: Colors.white,
          shape: shape,
          padding: padding,
        );

        buttonWidget = iconWidget != null
            ? ElevatedButton.icon(
                onPressed: currentOnPressed,
                icon: Container(
                  decoration: BoxDecoration(
                    color: iconContainerColor,
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: iconWidget,
                ),
                label: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: labelWidget,
                ),
                style: style,
              )
            : ElevatedButton(
                onPressed: currentOnPressed,
                style: style,
                child: labelWidget,
              );
        break;
    }

    if (isFullWidth) {
      buttonWidget = SizedBox(width: double.infinity, child: buttonWidget);
    }

    return Padding(padding: const EdgeInsets.all(2.5), child: buttonWidget);
  }
}
