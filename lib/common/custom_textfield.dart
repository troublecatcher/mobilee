import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/app/const.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool? obscureText;
  final String? Function(String?) validationCallback;
  final Widget? prefix;
  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.keyboardType,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText,
    required this.validationCallback,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        validator: validationCallback,
        obscureText: obscureText ?? false,
        keyboardType: keyboardType,
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
          prefix: prefix,
          prefixIcon: Icon(
            prefixIcon,
            color: primaryColor,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
