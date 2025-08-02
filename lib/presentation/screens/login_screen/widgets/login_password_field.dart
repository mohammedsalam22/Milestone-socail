import 'package:flutter/material.dart';
import '../../../../generated/l10n.dart';

class LoginPasswordField extends StatefulWidget {
  final TextEditingController controller; // Add this

  const LoginPasswordField({
    super.key,
    required this.controller, // Add this
  });

  @override
  State<LoginPasswordField> createState() => _LoginPasswordFieldState();
}

class _LoginPasswordFieldState extends State<LoginPasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller, // Use the controller
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: S.of(context).password,
        prefixIcon: const Icon(Icons.lock),
        hintText: S.of(context).enterYourPassword,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: _toggleVisibility,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return S.of(context).pleaseEnterYourPassword;
        }
        if (value.length < 6) {
          return S.of(context).passwordMinLength;
        }
        return null;
      },
    );
  }
}
