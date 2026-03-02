import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final double borderRadius;
  final bool isLoading;
  final Widget? icon;
  final Color? borderColor;
  final double borderWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onTap,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 25),
    this.backgroundColor = const Color(0xFF16056B),
    this.textColor = Colors.white,
    this.fontSize = 18,
    this.borderRadius = 1000,
    this.isLoading = false,
    this.icon,
    this.borderColor,
    this.borderWidth = 1
  });

  @override
  Widget build(BuildContext context) {
    final Color currentColor = isLoading
        ? Colors.grey
        : backgroundColor;
    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderColor != null ? Border.all(
              color: borderColor!,
              width: borderWidth,
            )
            : null
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      SizedBox(width: 1)
                    ],
                    Text(
                        text,
                        style: GoogleFonts.itim(
                          color: textColor,
                          fontSize: fontSize,
                        ),
                      ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}