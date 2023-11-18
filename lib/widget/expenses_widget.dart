// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';

class ExpensesWidget extends StatelessWidget {
  ExpensesWidget({super.key, required this.expenses});
  String? expenses;
  final SizedBox sizedBox = SizedBox(height: 10);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              expenses!,
              style: TextStyle(fontSize: 18),
            ),
            sizedBox,
          ],
        ),
      ),
    );
  }
}
