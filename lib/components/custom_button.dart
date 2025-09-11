import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color fontColor;
  final Size? size;
  final IconData? icon;
  final double? iconSize;
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry padding;

  const CustomButton({
    Key? key,
    this.label,
    required this.onPressed,
    this.backgroundColor = Colors.black,
    this.fontColor = Colors.white,
    this.size,
    this.icon,
    this.iconSize = 24,
    this.borderRadius = 16,
    this.elevation = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasIcon = icon != null;
    final bool hasLabel = label != null && label!.isNotEmpty;

    final Widget childContent = hasIcon && hasLabel
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: fontColor),
              const SizedBox(width: 8),
              Text(label!,
                  style:
                      TextStyle(color: fontColor, fontWeight: FontWeight.bold)),
            ],
          )
        : hasIcon
            ? Icon(icon, size: iconSize, color: fontColor)
            : hasLabel
                ? Text(label!,
                    style: TextStyle(
                        color: fontColor, fontWeight: FontWeight.bold))
                : const SizedBox();

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      elevation: elevation,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: fontColor.withOpacity(0.2),
        highlightColor: fontColor.withOpacity(0.1),
        onTap: onPressed,
        child: Container(
          padding: padding,
          alignment: Alignment.center,
          constraints: size != null
              ? BoxConstraints.tight(size!)
              : const BoxConstraints(minHeight: 48),
          child: childContent,
        ),
      ),
    );
  }
}
