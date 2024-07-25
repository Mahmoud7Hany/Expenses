import 'package:flutter/material.dart';

class ItemListTile extends StatelessWidget {
  final String item;
  final VoidCallback onDelete;
  const ItemListTile({required this.item, required this.onDelete, super.key});

// يحتوي على كود عنصر قائمة العرض اللي هيظهر فيها العناصر اللي تم اضافته
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          item,
          style: TextStyle(color: Colors.blue.shade900),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
