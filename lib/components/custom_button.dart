import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
    final String? label;
    final VoidCallback onPressed;
    final Color? backgroundColor;
    final Size? size;
    final Color? fontColor;
    final IconData? icon;
    final double? iconSize;

    const CustomButton({
        Key? key,
        this.label,
        required this.onPressed,
        this.backgroundColor,
        this.size,
        this.fontColor, 
        this.icon,
        this.iconSize,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
    final ButtonStyle  style = ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            fixedSize: size,
            foregroundColor: fontColor, 
            textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
        ),
    );

    final bool hasIcon = icon != null;
    final bool hasLabel = label != null && label!.isNotEmpty;

    if (hasIcon && !hasLabel){
        return  ElevatedButton(
        style: style.copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          elevation: MaterialStateProperty.all(0),
          
        ),
        onPressed: onPressed,
        child: Icon(icon, size: iconSize),
      );
    }

    else if (hasIcon && hasLabel){
        return ElevatedButton.icon(
        style: style,
        onPressed: onPressed,
        icon: Icon(icon!, size: iconSize),
        label: Text(label!),
      );
    }

    else if (!hasIcon && hasLabel){
      return ElevatedButton(
        style: style,
        onPressed: onPressed,
        child: Text(label!),
      );
    }
    else {
        return ElevatedButton(
        style: style,
        onPressed: onPressed,
        child: Text("Button"),
      );
    }
    }
}