import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // إضافة حزمة clipboard
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // لإستخدام jsonEncode و jsonDecode

//  إدارة النفقات
class ExpenseManagerPage extends StatefulWidget {
  @override
  _ExpenseManagerPageState createState() => _ExpenseManagerPageState();
}

class _ExpenseManagerPageState extends State<ExpenseManagerPage> {
  final List<Map<String, dynamic>> _expenses = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editAmountController = TextEditingController();
  final TextEditingController _dialogAmountController = TextEditingController();
  double _totalAmount = 0.0;
  double _availableBalance = 0.0; // خاصية جديدة لتخزين الرصيد المتاح
  int? _editingIndex;
  bool _isAmountFieldEnabled = true; // خاصية للتحكم في تمكين حقل الإدخال

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? expensesData = prefs.getString('expenses');
    if (expensesData != null) {
      List<dynamic> expensesList = jsonDecode(expensesData);
      setState(() {
        _expenses.addAll(expensesList.cast<Map<String, dynamic>>());
        _totalAmount = _expenses.fold(0.0, (sum, item) => sum + item['amount']);
      });
    }

    // تحميل الرصيد المتاح
    double? balance = prefs.getDouble('availableBalance');
    setState(() {
      _availableBalance = balance ?? 0.0;
    });
    // تحميل حالة تمكين حقل الإدخال
    bool? isAmountFieldEnabled = prefs.getBool('isAmountFieldEnabled');
    setState(() {
      _isAmountFieldEnabled = isAmountFieldEnabled ?? true;
    });
  }

  Future<void> _saveExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String expensesData = jsonEncode(_expenses);
    await prefs.setString('expenses', expensesData);

    // حفظ الرصيد المتاح
    await prefs.setDouble('availableBalance', _availableBalance);

    // حفظ حالة تمكين حقل الإدخال
    await prefs.setBool('isAmountFieldEnabled', _isAmountFieldEnabled);
  }

  void _addExpense(String name, double amount) {
    if (_availableBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا يوجد رصيد متاح لإضافة مصروف.')),
      );
      return;
    }
    if (amount > _availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('المبلغ يتجاوز الرصيد المتاح.')),
      );
      return;
    }

    setState(() {
      _expenses.add({'name': name, 'amount': amount});
      _totalAmount += amount;
      _availableBalance -= amount; // خصم المبلغ من الرصيد المتاح
    });
    _nameController.clear();
    _amountController.clear();
    _saveExpenses();
  }

  void _editExpense(int index) {
    final expense = _expenses[index];
    _editNameController.text = expense['name'];
    _editAmountController.text = expense['amount'].toString();
    setState(() {
      _editingIndex = index;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تعديل المصروف'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editNameController,
                decoration: InputDecoration(
                  labelText: 'اسم المصروف',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _editAmountController,
                decoration: InputDecoration(
                  labelText: 'المبلغ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                final String name = _editNameController.text;
                final double amount =
                    double.tryParse(_editAmountController.text) ?? 0;
                if (name.isNotEmpty && amount > 0) {
                  setState(() {
                    _totalAmount -= _expenses[_editingIndex!]['amount'];
                    _availableBalance += _expenses[_editingIndex!]
                        ['amount']; // إعادة المبلغ إلى الرصيد المتاح
                    _expenses[_editingIndex!] = {
                      'name': name,
                      'amount': amount
                    };
                    _totalAmount += amount;
                    _availableBalance -=
                        amount; // خصم المبلغ الجديد من الرصيد المتاح
                  });
                  _editNameController.clear();
                  _editAmountController.clear();
                  _saveExpenses();
                  Navigator.of(context).pop();
                }
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(int index) {
    setState(() {
      _availableBalance +=
          _expenses[index]['amount']; // إضافة المبلغ إلى الرصيد المتاح
      _totalAmount -= _expenses[index]['amount'];
      _expenses.removeAt(index);
    });
    _saveExpenses();
  }

  void _copyExpenseToClipboard(int index) {
    final expense = _expenses[index];
    final expenseText =
        '${expense['name']}: ${expense['amount'].toStringAsFixed(0)}';
    Clipboard.setData(ClipboardData(text: expenseText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم النسخ')),
    );
  }

  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد أنك تريد حذف جميع المصاريف؟'),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('تأكيد'),
              onPressed: () {
                _deleteAllExpenses();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAllExpenses() {
    setState(() {
      _expenses.clear();
      _availableBalance = 0.0;
      _totalAmount = 0.0;
      _isAmountFieldEnabled = true; // إعادة تمكين حقل الإدخال عند الحذف
    });
    _saveExpenses();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حذف جميع المصاريف')),
    );
  }

  void _copyAllExpensesToClipboard() {
    final expensesText = _expenses
        .map((expense) =>
            '${expense['name']}: ${expense['amount'].toStringAsFixed(0)}')
        .join('\n');
    final summaryText = 'المجموع: ${_totalAmount.toStringAsFixed(0)}';
    final textToCopy = '$expensesText\n\n$summaryText';
    Clipboard.setData(ClipboardData(text: textToCopy));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ جميع المصاريف')),
    );
  }

  void _showAmountDialog() {
    _dialogAmountController.text = _availableBalance.toStringAsFixed(0);
    _dialogAmountController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextField(
            controller: _dialogAmountController,
            decoration: InputDecoration(
              labelText: 'أدخل الرصيد',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            enabled: _isAmountFieldEnabled, // تمكين/تعطيل حقل الإدخال
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () {
                    final double amount =
                        double.tryParse(_dialogAmountController.text) ?? 0;
                    if (amount > 0) {
                      setState(() {
                        _availableBalance = amount; // تحديث الرصيد المتاح
                        _isAmountFieldEnabled =
                            false; // إيقاف حقل الإدخال بعد التحديث
                      });
                      _saveExpenses(); // حفظ التعديلات
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('تأكيد'),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'إدارة المصاريف',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAmountDialog, // أضف الزر الجديد هنا
            color: Colors.teal,
          ),
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: _copyAllExpensesToClipboard,
            color: Colors.amber,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: showDeleteConfirmationDialog,
            color: Colors.red,
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF355070),
                Color(0xFF6d597a),
                Color(0xFFb56576),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4.0,
                margin: EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الرصيد المتاح:',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_availableBalance.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'اسم المصروف',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'المبلغ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          final String name = _nameController.text;
                          final double amount =
                              double.tryParse(_amountController.text) ?? 0;
                          if (name.isNotEmpty && amount > 0) {
                            _addExpense(name, amount);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: Text('إضافة مصروف',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              Card(
                elevation: 4.0,
                margin: EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الإجمالي:',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${_totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          backgroundColor: Colors.blue,
                          icon: Icons.edit,
                          onPressed: (context) => _editExpense(index),
                        ),
                        SlidableAction(
                          backgroundColor: Colors.teal,
                          icon: Icons.copy,
                          onPressed: (context) =>
                              _copyExpenseToClipboard(index),
                        ),
                        SlidableAction(
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          onPressed: (context) => _deleteExpense(index),
                        ),
                      ],
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.money, color: Colors.white),
                        ),
                        title: Text(
                          _expenses[index]['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${_expenses[index]['amount'].toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
