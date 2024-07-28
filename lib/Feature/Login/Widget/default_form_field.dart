import 'package:flutter/material.dart';

class DefaultFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType type;
  final Function? onSubmit;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? onValidate;
  final VoidCallback? suffixPressed;
  final String label;
  final String hint;
  final bool isPassword;
  final IconData? suffix;

  const DefaultFormField({
    Key? key,
    required this.controller,
    required this.type,
    this.onSubmit,
    this.onChanged,
    this.onTap,
    required this.onValidate,
    this.suffixPressed,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.suffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      onChanged: onChanged,
      onTap: onTap,
      validator: onValidate,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white, // Background color
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black), // Label text color
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
            vertical: 15.0, horizontal: 12.0), // Padding
        suffixIcon: IconButton(
          onPressed: suffixPressed,
          icon: Icon(suffix),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
