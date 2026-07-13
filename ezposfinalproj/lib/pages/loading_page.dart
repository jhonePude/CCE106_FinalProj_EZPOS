import 'package:flutter/material.dart';
import '../data/style.dart';

class LoadingPage extends StatefulWidget {
  final String message;
  final Widget nextPage;
  const LoadingPage({super.key, required this.message, required this.nextPage});
  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget.nextPage)));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.bgWhite, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(padding: const EdgeInsets.all(25), decoration: neoBox(color: AppColors.softYellow), child: const CircularProgressIndicator(color: AppColors.black, strokeWidth: 5)),
      const SizedBox(height: 25),
      Text(widget.message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    ])));
  }
}