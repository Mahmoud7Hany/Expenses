import 'package:flutter/material.dart';

class ElevatedButtonWidget extends StatelessWidget {
  final Function() onPressed;
  final String buttonText;

  const ElevatedButtonWidget({
    required this.onPressed,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(buttonText),
    );
  }
}
