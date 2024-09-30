// lib/widgets/toggle_button.dart

import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  ToggleButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text,
          style: TextStyle(
            color: const Color.fromRGBO(67, 254, 120, 1),
          )),
    );
  }
}
