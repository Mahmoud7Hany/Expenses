import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculate/models/format_amount.dart';
import 'package:calculate/widget/Home_Widget/balance_card_widget.dart';
import 'package:calculate/widget/Home_Widget/drawer_widget.dart';
import 'package:calculate/widget/Home_Widget/appBar_widget.dart';
import 'package:calculate/widget/Home_Widget/elevated_button_widget.dart';
import 'package:calculate/widget/Home_Widget/text_formField_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../provider/expense_provider.dart';

// Home Page
class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController expensesController = TextEditingController();
    TextEditingController budgetController = TextEditingController();
    TextEditingController expensesNameController = TextEditingController();

    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          // متغير للتحكم في ظهور حقل الإدخال وزر التحديث
          bool isBudgetSet = expenseProvider.totalBudget > 0;

          return Scaffold(
            appBar: CustomAppBar(
              textAppBar: 'المصاريف',
              actions: [
                if (expenseProvider.expensesList.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      if (expenseProvider.expensesList.isNotEmpty) {
                        List<String> clipboardData = [];

                        // إعداد بيانات النسخ مع التحقق من الأرقام العشرية
                        for (var expense in expenseProvider.expensesList) {
                          if (expense.amount % 1 != 0) {
                            clipboardData.add(
                                '${expense.name} : ${expense.amount.toStringAsFixed(2)}');
                          } else {
                            clipboardData.add(
                                '${expense.name} : ${expense.amount.toInt()}');
                          }
                        }

                        // إضافة المجموع إلى البيانات
                        double expenses = expenseProvider.expenses;
                        if (expenses % 1 != 0) {
                          clipboardData
                              .add('المجموع : ${expenses.toStringAsFixed(2)}');
                        } else {
                          clipboardData.add('المجموع : ${expenses.toInt()}');
                        }

                        // حساب الرصيد المتبقي وإضافته إلى البيانات
                        double remaining =
                            expenseProvider.totalBudget - expenses;
                        if (remaining % 1 != 0) {
                          clipboardData
                              .add('باقي : ${remaining.toStringAsFixed(2)}');
                        } else {
                          clipboardData.add('باقي : ${remaining.toInt()}');
                        }

                        // نسخ البيانات إلى الحافظة
                        Clipboard.setData(
                            ClipboardData(text: clipboardData.join('\n')));

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('تم نسخ البيانات إلى الحافظة')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('لا يوجد بيانات لنسخها')),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy),
                    color: Colors.amber,
                  ),
                if (expenseProvider.expensesList.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('تأكيد المسح'),
                            content: const Text(
                                'هل أنت متأكد أنك تريد مسح جميع البيانات؟'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('إلغاء',
                                    style: TextStyle(color: Colors.red)),
                              ),
                              TextButton(
                                onPressed: () {
                                  expenseProvider.clearData();
                                  Navigator.of(context).pop();
                                  // إعادة إظهار حقل الإدخال وزر التحديث
                                  isBudgetSet = false;
                                },
                                child: const Text('مسح',
                                    style: TextStyle(color: Colors.white)),
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.red),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete_forever, size: 26),
                    color: Colors.red,
                  ),
              ],
            ),
            drawer: const DrawerWidget(),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: BalanceCardWidget(
                      icon: Icons.remove_red_eye,
                      hiddenIcon: Icons.remove_red_eye_outlined,
                      totalBalance:
                          '${formatAmount(expenseProvider.totalBudget - expenseProvider.expenses)}',
                      expenses: '${formatAmount(expenseProvider.expenses)}',
                      income: '${expenseProvider.lastEnteredBudget} جنيه',
                      totalBalanceLabel: 'إجمالي الرصيد',
                      expensesLabel: 'مصروف',
                      incomeLabel: 'دخل',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // إظهار حقل "اسم المصروف" و"مبلغ المصروف" وزر "أضف المصروف" فقط إذا تم تعيين الميزانية
                        if (isBudgetSet) ...[
                          TextFormFieldWidget(
                            controller: expensesNameController,
                            labelText: 'اسم المصروف',
                          ),
                          const SizedBox(height: 10),
                          TextFormFieldWidget(
                            controller: expensesController,
                            keyboardType: TextInputType.number,
                            labelText: 'مبلغ المصروف',
                          ),
                          const SizedBox(height: 10),
                          ElevatedButtonWidget(
                            onPressed: () {
                              if (expensesController.text.isNotEmpty &&
                                  expensesNameController.text.isNotEmpty) {
                                double amount =
                                    double.parse(expensesController.text);
                                String name = expensesNameController.text;
                                expenseProvider.addExpense(name, amount);

                                expensesController.clear();
                                expensesNameController.clear();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('يجب ملء حقلي الإدخال')),
                                );
                              }
                            },
                            buttonText: 'أضف المصروف',
                          ),
                          const SizedBox(height: 10),
                        ],
                        // إظهار حقل الإدخال وزر التحديث فقط إذا لم يتم تعيين الميزانية
                        if (!isBudgetSet) ...[
                          TextFormFieldWidget(
                            controller: budgetController,
                            keyboardType: TextInputType.number,
                            labelText: 'أدخل الرصيد الإجمالي',
                          ),
                          const SizedBox(height: 10),
                          ElevatedButtonWidget(
                            onPressed: () {
                              if (budgetController.text.isNotEmpty) {
                                double budget =
                                    double.parse(budgetController.text);
                                expenseProvider.updateBudget(budget);
                                budgetController.clear();
                                // إخفاء حقل الإدخال وزر التحديث بعد تعيين الميزانية
                                isBudgetSet = true;
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('يجب إدخال قيمة الرصيد أولاً'),
                                  ),
                                );
                              }
                            },
                            buttonText: 'إضافة الرصيد',
                          ),
                        ],
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  if (expenseProvider.expensesList.isNotEmpty)
                    const Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ...expenseProvider.expensesList.map((expense) {
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              expenseProvider.deleteExpense(expenseProvider
                                  .expensesList
                                  .indexOf(expense));
                            },
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            label: 'حذف',
                          )
                        ],
                      ),
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            expense.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18),
                          ),
                          subtitle: Text(
                            formatAmount(expense.amount),
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
