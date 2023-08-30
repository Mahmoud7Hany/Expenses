// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widget/AppBarWidget.dart';
import '../widget/ElevatedButtonWidget.dart';
import '../widget/TextFormFieldWidget.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Expense {
  final String name;
  final double amount;

  Expense(this.name, this.amount);

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
      };
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

  void _saveData() {
    _prefs.setDouble('totalBudget', totalBudget);
    _prefs.setDouble('expenses', expenses);
  }

  void _saveExpensesList() {
    List<String> expensesJsonList = expensesList.map((expense) {
      return jsonEncode(expense.toJson());
    }).toList();
    _prefs.setStringList('expensesList', expensesJsonList);
  }

  void _deleteExpense(int index) {
    setState(() {
      Expense deletedExpense = expensesList.removeAt(index);
      _updateExpenses(expenses - deletedExpense.amount);
      _saveExpensesList();
      _saveData();
    });
  }

  void _clearData() {
    setState(() {
      totalBudget = 0;
      expenses = 0;
      expensesList.clear();
      _saveData();
      _saveExpensesList();
    });
  }

  bool canAddExpense() {
    return expensesController.text.isNotEmpty &&
        expensesNameController.text.isNotEmpty &&
        (totalBudget > 0 || budgetController.text.isNotEmpty);
  }

  SizedBox sizedBox = SizedBox(height: 10);
  bool showDeleteIcon = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  sizedBox,
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'إجمالي المصروفات: ${_formatAmount(expenses)}',
                            style: TextStyle(fontSize: 18),
                          ),
                          sizedBox,
                          // ElevatedButton(
                          //   onPressed: () {
                          //     setState(() {
                          //       expenses = 0;
                          //       _saveData();
                          //       _saveExpensesList();
                          //     });
                          //   },
                          //   child: Text('مسح المصروفات'),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'الرصيد المتبقي: ${_formatAmount(totalBudget - expenses)}',
                            style: TextStyle(fontSize: 18),
                          ),
                          sizedBox,
                          // sizedBox,
                          // ElevatedButton(
                          //   onPressed: () {
                          //     setState(() {
                          //       totalBudget = 0;
                          //       _saveData();
                          //       _saveExpensesList();
                          //     });
                          //   },
                          //   child: Text('مسح الميزانية'),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showDeleteIcon = !showDeleteIcon;
                        });

                        if (showDeleteIcon) {
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
                                      setState(() {
                                        showDeleteIcon = false;
                                      });
                                      Navigator.of(context)
                                          .pop(); // إغلاق حوار التأكيد
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
                                      setState(() {
                                        showDeleteIcon = false;
                                      });
                                      Navigator.of(context)
                                          .pop(); // إغلاق حوار التأكيد
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
                        }
                      },
                      child: Text('مسح الكل'),
                    ),
                  ),
                ],
              ),
            ),
            sizedBox,
            //  خاص بعمليه النسخ
            ElevatedButton(
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
                  clipboardData.add('المجموع : $expenses');
                  clipboardData.add(
                      'باقي : ${(totalBudget - expenses).toStringAsFixed(2)}');
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
              child: Text('نسخ البيانات إلى الحافظة'),
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
                  (expense) => Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(expense.name),
                      subtitle: Text(_formatAmount(expense.amount)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteExpense(expensesList.indexOf(expense));
                        },
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

  @override
  void dispose() {
    _saveData();
    expensesController.dispose();
    budgetController.dispose();
    expensesNameController.dispose();
    super.dispose();
  }
}
