import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> actions; // إضافة متغير actions

  const CustomAppBar({
    Key? key,
    required this.actions,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // حجم الـ AppBar

  @override
  Widget build(BuildContext context) {
    return AnimatedAppBar(
        actions: actions); // تمرير النص والعناصر إلى AnimatedAppBar
  }
}

class AnimatedAppBar extends StatefulWidget {
  final List<Widget> actions; // إضافة متغير actions

  const AnimatedAppBar({super.key, required this.actions});

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
              Color(0xFF6D214F), // اللون البنفسجي الداكن
              Color(0xFF54C6D0), // اللون الأزرق الفاتح
              Color(0xFFA73982), // اللون الوردي الداكن
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
          title: const Text(
            'المصاريف',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
