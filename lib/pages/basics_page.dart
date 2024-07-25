import 'package:calculate/widget/Basics_Widget/first_visit_dialog.dart';
import 'package:calculate/widget/Home_Widget/appBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// دي صفحه المصاريف الاساسيه
class BasicsPage extends StatefulWidget {
  const BasicsPage({super.key});

  @override
  _BasicsPageState createState() => _BasicsPageState();
}

class _BasicsPageState extends State<BasicsPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  List<Map<String, String>> _items = [];
  bool _isEditing = false;
  bool _isFirstVisit = false;
  int _sum = 0;

  @override
  void initState() {
    super.initState();
    _checkFirstVisit();
    _loadItems();
  }

  Future<void> _checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstVisit = prefs.getBool('isFirstVisit') ?? true;

    if (isFirstVisit) {
      setState(() {
        _isFirstVisit = true;
      });
      await prefs.setBool('isFirstVisit', false);
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('items', jsonEncode(_items));
    await prefs.setInt('sum', _sum);
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsData = prefs.getString('items');
    final sum = prefs.getInt('sum') ?? 0;

    if (itemsData != null) {
      setState(() {
        _items = List<Map<String, String>>.from(jsonDecode(itemsData)
            .map((item) => Map<String, String>.from(item)));
        _sum = sum;
      });
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _addItem() {
    if (_textController.text.isNotEmpty && _numberController.text.isNotEmpty) {
      final int? value = int.tryParse(_numberController.text);
      if (value != null) {
        setState(() {
          _items.add({
            'text': _textController.text,
            'number': _numberController.text,
          });
          _sum += value;
          _textController.clear();
          _numberController.clear();
          _isEditing = false;
        });
        _saveItems();
      }
    }
  }

  void _removeItem(int index) {
    final int? value = int.tryParse(_items[index]['number']!);
    if (value != null) {
      setState(() {
        _sum -= value;
        _items.removeAt(index);
      });
      _saveItems();
    }
  }

  void _clearAllItems() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد أنك تريد حذف جميع العناصر؟'),
          actions: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // إغلاق مربع الحوار
                    },
                    child: Text('إلغاء'),
                  ),
                  SizedBox(width: 50),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _items.clear();
                        _sum = 0;
                      });
                      _saveItems();
                      Navigator.of(context).pop(); // إغلاق مربع الحوار
                    },
                    child: Text('حذف'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _copyAllItems() {
    String allItems = _items
        .map((item) => '${item['text']!}\n${item['number']!}')
        .join('\n\n');
    allItems += '\n\nالمجموع: $_sum';
    Clipboard.setData(ClipboardData(text: allItems));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ')),
    );
  }

  void _copyItem(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // رساله تظهر مره واحده فقط عند فتح الصفحه لاول مره
    if (_isFirstVisit) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return FirstVisitDialog(
                onClose: () {
                  setState(() {
                    _isFirstVisit = false;
                  });
                },
              );
            },
          );
        },
      );
    }
    return Scaffold(
      appBar: CustomAppBar(
        textAppBar: 'المصاريف الأساسية',
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            color: Colors.amber,
            onPressed: _copyAllItems,
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            color: Colors.red,
            onPressed: _clearAllItems,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(left: 16, right: 16, top: 16),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'المجموع: $_sum',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _toggleEditing,
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'قم بالضغط هنا للإضافة',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade200, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'الاسم',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade200, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _numberController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'المبلغ',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _addItem,
                    child: Text(
                      'إضافة',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                String itemText =
                    '${_items[index]['text']!}\n${_items[index]['number']!} جنيه';
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: 'حذف',
                        onPressed: (context) => _removeItem(index),
                      ),
                    ],
                  ),
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(14),
                      title: Text(
                        itemText,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.copy, color: Colors.blue),
                            onPressed: () => _copyItem(itemText),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
