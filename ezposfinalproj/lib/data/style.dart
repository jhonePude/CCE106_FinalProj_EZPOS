import 'package:flutter/material.dart';

class AppColors {
  static const Color gradientStart = Color(0xFF003973); 
  static const Color gradientEnd = Color(0xFF00B4DB);   
  static const Color softYellow = Color(0xFFFFF0B3);
  static const Color bgWhite = Color(0xFFFDFCF0);
  static const Color black = Color(0xFF1A1A1A);
  static const Color boxPurple = Color(0xFFEBE3FF);
  static const Color boxBlue = Color(0xFFE1F5FE);
  static const Color boxGreen = Color(0xFFE0F2F1);
  static const Color mintGreen = Color(0xFF00D1A0);
  static const Color errorRed = Color(0xFFFF6B6B);
}

BoxDecoration neoGradientBox({double radius = 0}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColors.gradientStart, AppColors.gradientEnd],
      begin: Alignment.centerLeft, end: Alignment.centerRight,
    ),
    border: const Border(bottom: BorderSide(color: AppColors.black, width: 2)),
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
  );
}

BoxDecoration neoBox({Color color = Colors.white, double radius = 12, double shadow = 4}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.black, width: 2),
    boxShadow: shadow == 0 ? [] : [
      BoxShadow(color: AppColors.black, offset: Offset(shadow, shadow), blurRadius: 0),
    ],
  );
}