// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/add_Expense.dart';
import '../widget/appBar_widget.dart';
import '../widget/elevated_button_widget.dart';
import '../widget/text_formField_widget.dart';
import 'package:flutter/services.dart';
import '../widget/expenses_widget.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double totalBudget = 0;
  double expenses = 0;
  List<Expense> expensesList = [];
  TextEditingController expensesController = TextEditingController();
  TextEditingController budgetController = TextEditingController();
  TextEditingController expensesNameController = TextEditingController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _updateExpenses(double value) {
    setState(() {
      expenses = value;
    });
  }

  void _updateBudget(double value) {
    setState(() {
      totalBudget += value;
    });
  }

  void _addExpense(String name, double amount) {
    double newTotalExpenses = expenses + amount;

    if (newTotalExpenses <= totalBudget) {
      setState(() {
        expensesList.add(Expense(name, amount));
        _saveExpensesList();
        _updateExpenses(newTotalExpenses);
        _saveData();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('المصروفات تتجاوز الميزانية المتاحة'),
        ),
      );
    }
  }

  // recovery data
  void _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      totalBudget = _prefs.getDouble('totalBudget') ?? 0;
      expenses = _prefs.getDouble('expenses') ?? 0;
      List<String>? expensesJsonList = _prefs.getStringList('expensesList');
      if (expensesJsonList != null) {
        expensesList = expensesJsonList.map((json) {
          Map<String, dynamic> expenseMap = jsonDecode(json);
          return Expense(expenseMap['name'], expenseMap['amount']);
        }).toList();
      }
    });
  }

  //  saveData
  void _saveData() {
    _prefs.setDouble('totalBudget', totalBudget);
    _prefs.setDouble('expenses', expenses);
  }

  // حفظ قائمة النفقات
  void _saveExpensesList() {
    List<String> expensesJsonList = expensesList.map((expense) {
      return jsonEncode(expense.toJson());
    }).toList();
    _prefs.setStringList('expensesList', expensesJsonList);
  }

  // Delete one from list
  void _deleteExpense(int index) {
    setState(() {
      Expense deletedExpense = expensesList.removeAt(index);
      _updateExpenses(expenses - deletedExpense.amount);
      _saveExpensesList();
      _saveData();
    });
  }

  // Delete all data
  void _clearData() {
    setState(() {
      totalBudget = 0;
      expenses = 0;
      expensesList.clear();
      _saveData();
      _saveExpensesList();
    });
  }

  // بتستخدم لتحسن اداء التطبيق
  @override
  void dispose() {
    _saveData();
    expensesController.dispose();
    budgetController.dispose();
    expensesNameController.dispose();
    super.dispose();
  }

  //  Add Expense
  bool canAddExpense() {
    return expensesController.text.isNotEmpty &&
        expensesNameController.text.isNotEmpty &&
        (totalBudget > 0 || budgetController.text.isNotEmpty);
  }

  SizedBox sizedBox = SizedBox(height: 10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          // copy List
          IconButton(
            onPressed: () {
              if (expensesList.isNotEmpty) {
                List<String> clipboardData = [];
                for (var expense in expensesList) {
                  if (expense.amount % 1 != 0) {
                    clipboardData.add(
                        '${expense.name} : ${expense.amount.toStringAsFixed(2)}');
                  } else {
                    clipboardData
                        .add('${expense.name} : ${expense.amount.toInt()}');
                  }
                }
                if (expenses % 1 != 0) {
                  clipboardData.add('المجموع : ${expenses.toStringAsFixed(2)}');
                } else {
                  clipboardData.add('المجموع : ${expenses.toInt()}');
                }
                double remaining = totalBudget - expenses;
                if (remaining % 1 != 0) {
                  clipboardData.add('باقي : ${remaining.toStringAsFixed(2)}');
                } else {
                  clipboardData.add('باقي : ${remaining.toInt()}');
                }
                String clipboardText = clipboardData.join('\n');

                Clipboard.setData(ClipboardData(text: clipboardText));

                final snackBar = SnackBar(
                  content: Text('تم نسخ البيانات إلى الحافظة'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                final snackBar = SnackBar(
                  content: Text('لا يوجد بيانات لنسخها'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            icon: Icon(Icons.copy),
          ),
          sizedBox,
          // خاص بحذف جميع البيانات
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'تأكيد المسح',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    content: Text(
                      'هل أنت متأكد أنك تريد مسح جميع البيانات؟ يرجى ضمان نسخ البيانات قبل المسح، حيث لا يمكن استعادة البيانات بعد عملية المسح.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // إغلاق حوار التأكيد
                        },
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _clearData(); // مسح البيانات
                          Navigator.of(context).pop(); // إغلاق حوار التأكيد
                        },
                        child: Text(
                          'مسح',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  sizedBox,
                  // إجمالي المصروفات
                  ExpensesWidget(
                    expenses: 'إجمالي المصروفات: ${_formatAmount(expenses)}',
                  ),
                  // الرصيد المتبقي
                  ExpensesWidget(
                    expenses:
                        'الرصيد المتبقي: ${_formatAmount(totalBudget - expenses)}',
                  ),
                ],
              ),
            ),
            sizedBox,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextFormFieldWidget(
                    controller: expensesNameController,
                    labelText: 'اسم المصروف',
                  ),
                  sizedBox,
                  TextFormFieldWidget(
                    controller: expensesController,
                    keyboardType: TextInputType.number,
                    labelText: 'مبلغ المصروف',
                  ),
                  sizedBox,
                  // خاص بزر اضافه مصروف
                  ElevatedButtonWidget(
                    onPressed: () {
                      if (canAddExpense()) {
                        double enteredExpenses =
                            double.tryParse(expensesController.text) ?? 0;

                        if (enteredExpenses == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('لا يمكن إضافة قيمة 0'),
                            ),
                          );
                        } else {
                          String enteredName = expensesNameController.text;
                          _addExpense(enteredName, enteredExpenses);

                          expensesController.clear();
                          expensesNameController.clear();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(totalBudget > 0
                                ? 'يجب ملء حقلي الإدخال أولاً'
                                : 'يجب إدخال الرصيد أولاً'),
                          ),
                        );
                      }
                    },
                    buttonText: 'أضف المصروف',
                  ),
                  sizedBox,
                  TextFormFieldWidget(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    labelText: 'أدخل الرصيد الإجمالي',
                  ),
                  sizedBox,
                  // خاص بزر تحديث الرصيد او بمعني اضافه رصيد
                  Center(
                    child: ElevatedButtonWidget(
                      onPressed: () {
                        if (budgetController.text.isNotEmpty) {
                          double enteredBudget =
                              double.tryParse(budgetController.text) ??
                                  totalBudget;

                          if (enteredBudget == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('لا يمكن إضافة قيمة 0'),
                              ),
                            );
                          } else {
                            _updateBudget(enteredBudget);
                            _saveData();
                            budgetController.clear();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('يجب إدخال قيمة الرصيد أولاً'),
                            ),
                          );
                        }
                      },
                      buttonText: 'تحديث الرصيد',
                    ),
                  ),
                  sizedBox,
                ],
              ),
            ),
            Column(
              children: [
                if (expensesList.isNotEmpty)
                  Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                ...expensesList.map(
                  // قابل للانزلاق اللي بيعمل تحريك للعنصر ليظهر الانزلاق Slidable
                  (expense) => Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            _deleteExpense(
                                expensesList.indexOf(expense)); // حذف العنصر
                          },
                          backgroundColor: Colors.blue,
                          icon: Icons.delete,
                          label: 'حذف',
                        )
                      ],
                    ),
                    child: Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        // اسم العنصر اللي اتصرف
                        title: Text(
                          expense.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        // بكام العنصر اللي اتصرف
                        subtitle: Text(
                          _formatAmount(expense.amount),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

// الكود ده خاص بعدم عرض القيمه العشريه لو مش موجوده لو موجوده بيتم عرضه
  String _formatAmount(double amount) {
    if (amount != null) {
      if (amount % 1 == 0) {
        // القيمة لا تحتوي على أرقام عشرية
        return '${amount.toInt()} جنيه';
      } else {
        // القيمة تحتوي على أرقام عشرية
        return '${amount.toStringAsFixed(2)} جنيه';
      }
    } else {
      // قيمة الإنفاق فارغة
      return '';
    }
  }
}
