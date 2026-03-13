import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool isPassword;

  const CustomInput({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      // Matches the specific font in the reference
      style: const TextStyle(color: Color(0xFF1E2A3A), fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        // Pale placeholder color
        hintStyle: const TextStyle(color: Color(0xFFC0CAD9), fontSize: 14),
        // Soft grey prefix icon color
        prefixIcon: Icon(prefixIcon, color: const Color(0xFFC0CAD9), size: 20),
        // The password "eye" icon if needed
        suffixIcon: isPassword
            ? const Icon(
                Icons.visibility_off_outlined,
                color: Color(0xFFC0CAD9),
                size: 18,
              )
            : null,
      ),
    );
  }
}
