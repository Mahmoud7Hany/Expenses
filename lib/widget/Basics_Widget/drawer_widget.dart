import 'package:calculate/pages/basics_page.dart';
import 'package:calculate/pages/debt_management_page.dart';
import 'package:calculate/pages/expense_manager_page.dart';
import 'package:flutter/material.dart';

// هذه صفحة القائمة الجانبية التي في الصفحة الرئيسية
class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF355070), // اللون البنفسجي الداكن
                  Color(0xFF6d597a), // اللون الأزرق الفاتح
                  Color(0xFFb56576), // اللون الوردي الداكن
                ],
                begin: Alignment
                    .topLeft, // يمكنك تغيير هذه القيمة لتغيير اتجاه التدرج
                end: Alignment
                    .bottomRight, // يمكنك تغيير هذه القيمة لتغيير اتجاه التدرج
              ),
            ),
            child: Center(
              child: Text(
                'المصاريف',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.addchart, color: Colors.green),
            title: Text('المصاريف الأساسية'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BasicsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.arrow_outward, color: Colors.green),
            title: Text('الديون'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DebtManagementPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet, color: Colors.green),
            title: Text('إدارة النفقات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExpenseManagerPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
