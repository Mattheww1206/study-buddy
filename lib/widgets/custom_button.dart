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
    this.borderRadius = 12,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(1000)
          ),
          child: Center(
            child: Text(text,
            style: GoogleFonts.itim(
              color: textColor,
              fontSize: fontSize,
            ),
            ),
          ),
        ),
      ),
    );
    
  }


}