import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// بطاقة الرصيد اللي في اول الصفحه لما تفتح التطبيق
class BalanceCardWidget extends StatefulWidget {
  final IconData icon;
  final IconData hiddenIcon;
  final String totalBalance;
  final String expenses;
  final String income;
  final String totalBalanceLabel;
  final String expensesLabel;
  final String incomeLabel;

  const BalanceCardWidget({
    Key? key,
    required this.icon,
    required this.hiddenIcon,
    required this.totalBalance,
    required this.expenses,
    required this.income,
    required this.totalBalanceLabel,
    required this.expensesLabel,
    required this.incomeLabel,
  }) : super(key: key);

  @override
  _BalanceCardWidgetState createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {
  bool _isBalanceHidden = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBalanceHidden = _prefs.getBool('isBalanceHidden') ?? false;
    });
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceHidden = !_isBalanceHidden;
      _prefs.setBool('isBalanceHidden', _isBalanceHidden);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(_isBalanceHidden ? widget.hiddenIcon : widget.icon,
                    color: Colors.white),
                onPressed: _toggleBalanceVisibility,
              ),
              Text(
                widget.totalBalanceLabel,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            _isBalanceHidden ? '*******' : widget.totalBalance,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.white),
                  Text(
                    widget.expensesLabel,
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    widget.expenses,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.attach_money, color: Colors.white),
                  Text(
                    widget.incomeLabel,
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    widget.income,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
