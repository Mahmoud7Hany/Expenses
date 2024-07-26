import 'package:calculate/models/Debt_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding and decoding JSON

// صفحة إدارة الديون
class DebtManagementPage extends StatefulWidget {
  @override
  _DebtManagementPageState createState() => _DebtManagementPageState();
}

class _DebtManagementPageState extends State<DebtManagementPage> {
  final List<Debt> _debts = [];
  final List<Debt> _filteredDebts = [];
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _dueDate;
  DateTime? _receiptDate;
  int? _editingIndex;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtList = prefs.getStringList('debts') ?? [];
    setState(() {
      _debts.clear();
      _filteredDebts.clear();
      for (var debtString in debtList) {
        final debtMap = jsonDecode(debtString) as Map<String, dynamic>;
        _debts.add(Debt.fromMap(debtMap));
      }
      _filterDebts();
    });
  }

  Future<void> _saveDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtList = _debts.map((debt) => jsonEncode(debt.toMap())).toList();
    await prefs.setStringList('debts', debtList);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _addOrUpdateDebt() {
    final description = _descriptionController.text;
    final amount = double.tryParse(_amountController.text);

    if (description.isEmpty) {
      _showErrorDialog('يرجى إدخال الوصف');
      return;
    }

    if (amount == null || amount <= 0) {
      _showErrorDialog('يرجى إدخال مبلغ أكبر من 0');
      return;
    }
    if (_receiptDate == null) {
      _showErrorDialog('يرجى اختيار تاريخ الاستلام');
      return;
    }
    if (_dueDate == null) {
      _showErrorDialog('يرجى اختيار تاريخ الدفع');
      return;
    }

    setState(() {
      if (_editingIndex != null) {
        _debts[_editingIndex!] = Debt(
          description: description,
          amount: amount,
          dueDate: _dueDate!,
          receiptDate: _receiptDate!,
        );
        _editingIndex = null;
      } else {
        _debts.add(Debt(
          description: description,
          amount: amount,
          dueDate: _dueDate!,
          receiptDate: _receiptDate!,
        ));
      }
      _descriptionController.clear();
      _amountController.clear();
      _dueDate = null;
      _receiptDate = null;
      _filterDebts();
    });
    _saveDebts();
  }

  void _selectDueDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null && selectedDate != _dueDate) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  void _selectReceiptDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null && selectedDate != _receiptDate) {
      setState(() {
        _receiptDate = selectedDate;
      });
    }
  }

  void _deleteDebt(int index) {
    setState(() {
      _debts.removeAt(index);
      _filterDebts();
    });
    _saveDebts();
  }

  void _editDebt(int index) {
    final debt = _filteredDebts[index];
    _descriptionController.text = debt.description;
    _amountController.text = debt.amount.toString();
    _dueDate = debt.dueDate;
    _receiptDate = debt.receiptDate;
    setState(() {
      _editingIndex = _debts.indexOf(debt); // Update the editing index
      _isSearching = false; // Exit search mode
      _searchQuery = ''; // Clear search query
      _filterDebts(); // Update the filtered debts list
    });
  }

  void _filterDebts() {
    setState(() {
      _filteredDebts.clear();
      _filteredDebts.addAll(
        _debts.where(
          (debt) => debt.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()),
        ),
      );
    });
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterDebts();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _filterDebts();
      }
    });
  }

  double _calculateTotalAmount() {
    return _filteredDebts.fold(0.0, (sum, debt) => sum + debt.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'بحث...',
                  border: InputBorder.none,
                ),
                onChanged: _onSearchQueryChanged,
                style: TextStyle(color: Colors.white),
              )
            : Text(
                'إدارة الديون',
                style: TextStyle(
                  color: Colors.white,
                  // fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            color: Colors.white,
            onPressed: _toggleSearch,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isSearching) ...[
              Card(
                elevation: 4.0,
                margin: EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'الوصف',
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'المبلغ',
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _receiptDate != null
                                  ? 'تاريخ الاستلام: ${_receiptDate!.toLocal().toShortDateString()}'
                                  : 'تاريخ الاستلام',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          ElevatedButton(
                            onPressed: _selectReceiptDate,
                            child: Text('اختر تاريخ الاستلام'),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _dueDate != null
                                  ? 'تاريخ الدفع: ${_dueDate!.toLocal().toShortDateString()}'
                                  : 'تاريخ الدفع',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          ElevatedButton(
                            onPressed: _selectDueDate,
                            child: Text('اختر تاريخ الدفع'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: _addOrUpdateDebt,
                        child: Text(_editingIndex != null
                            ? 'تحديث الدين'
                            : 'إضافة دين'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Card(
                elevation: 4.0,
                margin: EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإجمالي:',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${_calculateTotalAmount().toStringAsFixed(2)}', // Use currency symbol or format as needed
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: _filteredDebts.length,
                itemBuilder: (ctx, index) {
                  final debt = _filteredDebts[index];
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          backgroundColor: Colors.blue,
                          icon: Icons.edit,
                          label: 'تعديل',
                          onPressed: (context) => _editDebt(index),
                        ),
                        SlidableAction(
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          label: 'حذف',
                          onPressed: (context) => _deleteDebt(index),
                        ),
                      ],
                    ),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2.0,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        title: Text(debt.description),
                        subtitle: Text(
                          'المبلغ: ${debt.amount}\nتاريخ الاستلام: ${debt.receiptDate.toLocal().toShortDateString()}\nتاريخ الدفع: ${debt.dueDate.toLocal().toShortDateString()}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension DateFormatting on DateTime {
  String toShortDateString() {
    return '${this.day}/${this.month}/${this.year}';
  }
}
