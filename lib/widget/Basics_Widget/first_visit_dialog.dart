import 'package:flutter/material.dart';

class FirstVisitDialog extends StatelessWidget {
  final VoidCallback onClose;

// يحتوي على كود عرض الحوار عند الزيارة الأولى.
  const FirstVisitDialog({required this.onClose, super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Center(
        child: Text(
          'مرحباً!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
      content: Text(
        'تظهر هذه الرسالة مرة واحدة فقط. صفحة المصاريف الأساسية، وهي المصاريف التي تتكرر دائمًا.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClose();
          },
          child: Center(
            child: Text(
              'تم القراءة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
