import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar(
      {Key? key, required this.actions, required this.textAppBar})
      : super(key: key);
  final List<Widget> actions; // إضافة متغير actions
  final String textAppBar;
  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // حجم الـ AppBar

  @override
  Widget build(BuildContext context) {
    return AnimatedAppBar(
      actions: actions,
      textAppBar: textAppBar,
    ); // تمرير النص والعناصر إلى AnimatedAppBar
  }
}

class AnimatedAppBar extends StatefulWidget {
  final List<Widget> actions; // إضافة متغير actions
  final String textAppBar;

  const AnimatedAppBar(
      {super.key, required this.actions, required this.textAppBar});

  @override
  _AnimatedAppBarState createState() => _AnimatedAppBarState();
}

class _AnimatedAppBarState extends State<AnimatedAppBar> {
  bool isAppBarVisible = false;

  @override
  void initState() {
    super.initState();
    // قم بتأخير ظهور الـ AppBar لمدة 300 مللي ثانية
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        isAppBarVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isAppBarVisible ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF355070), // اللون البنفسجي الداكن
              Color(0xFF6d597a), // اللون الأزرق الفاتح
              Color(0xFFb56576), // اللون الوردي الداكن
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AppBar(
          // leading: Text(widget.buttonText),
          actions: widget.actions,
          centerTitle: true,
          backgroundColor: const Color.fromARGB(0, 99, 98, 98),
          elevation: 0,
          title: Text(
            widget.textAppBar,
            style: TextStyle(
              color: Colors.white,
              // fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
