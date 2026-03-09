import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText; // Inalis ang 'late' dahil initialized na sa constructor
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final String? errorText;
  final Color? fillColor; // 1. Idinagdag na property

  const CustomTextfield({ // Inilagay ang 'const'
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.errorText,
    this.fillColor, // 2. Idinagdag sa constructor
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Inalis ang horizontal padding dito dahil may padding na ang Card sa LoginPage
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        hintText: widget.hintText,
        errorText: widget.errorText,
        hintStyle: const TextStyle(fontSize: 18),
        filled: true,
        // 3. Ginagamit ang widget.fillColor kung meron, kung wala default ay grey[200]
        fillColor: widget.fillColor ?? Colors.grey[200],
        errorMaxLines: 2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(
          fontSize: 14, // Bahagyang linait para hindi masyadong malaki sa loob ng card
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: Colors.red,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
      ),
    );
  }
}