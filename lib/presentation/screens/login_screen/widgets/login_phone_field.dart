import 'package:flutter/material.dart';
import '../../../../generated/l10n.dart';

class LoginNameField extends StatelessWidget {
  final TextEditingController controller; // Add this

  const LoginNameField({
    super.key,
    required this.controller, // Add this
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // Use the controller
      keyboardType:
          TextInputType.text, // Changed from phone to text for username
      decoration: InputDecoration(
        labelText: S.of(context).userName,
        prefixIcon: const Icon(Icons.person),
        hintText: S.of(context).enterYourName,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return S.of(context).pleaseEnterYourName;
        }
        return null;
      },
    );
  }
}
