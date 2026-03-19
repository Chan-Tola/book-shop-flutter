import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
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
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      // Matches the specific font in the reference
      style: const TextStyle(color: Color(0xFF1E2A3A), fontSize: 14),
      decoration: InputDecoration(
        hintText: widget.hintText,
        // Pale placeholder color
        hintStyle: const TextStyle(color: Color(0xFFC0CAD9), fontSize: 14),
        // Soft grey prefix icon color
        prefixIcon: Icon(
          widget.prefixIcon,
          color: const Color(0xFFC0CAD9),
          size: 20,
        ),
        // The password "eye" icon if needed
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFFC0CAD9),
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : null,
      ),
    );
  }
}
