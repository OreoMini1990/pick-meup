import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 브랜드 컬러
  static const Color brandPink = Color(0xFFFF2D70);
  static const Color brandDark = Color(0xFF111111);
  static const Color brandBg = Color(0xFFF9F9FB);
  static const Color brandGray = Color(0xFFEDEDEF);
  static const Color brandWhite = Color(0xFFFFFFFF);
  
  // 그라데이션
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandPink, Color(0xFFFF6B9D)],
  );
  
  // 텍스트 스타일
  static TextStyle get heading1 => GoogleFonts.notoSans(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: brandDark,
  );
  
  static TextStyle get heading2 => GoogleFonts.notoSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: brandDark,
  );
  
  static TextStyle get heading3 => GoogleFonts.notoSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: brandDark,
  );
  
  static TextStyle get body1 => GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: brandDark,
  );
  
  static TextStyle get body2 => GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: brandDark.withOpacity(0.7),
  );
  
  static TextStyle get button => GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: brandWhite,
  );
  
  static TextStyle get caption => GoogleFonts.notoSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: brandDark.withOpacity(0.6),
  );

  // 라이트 테마
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandPink,
        brightness: Brightness.light,
        primary: brandPink,
        secondary: const Color(0xFFFF6B9D),
        surface: brandWhite,
        background: brandBg,
        error: const Color(0xFFE53E3E),
      ),
      
      // 앱바 테마
      appBarTheme: AppBarTheme(
        backgroundColor: brandWhite,
        foregroundColor: brandDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: heading3,
        surfaceTintColor: Colors.transparent,
      ),
      
      // 카드 테마
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: brandWhite,
        shadowColor: brandDark.withOpacity(0.1),
      ),
      
      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPink,
          foregroundColor: brandWhite,
          elevation: 0,
          shadowColor: brandPink.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: button,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandPink,
          side: const BorderSide(color: brandPink, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: button.copyWith(color: brandPink),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brandPink,
          foregroundColor: brandWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: button,
        ),
      ),
      
      // 텍스트 테마
      textTheme: TextTheme(
        headlineLarge: heading1,
        headlineMedium: heading2,
        headlineSmall: heading3,
        bodyLarge: body1,
        bodyMedium: body2,
        labelLarge: button,
        bodySmall: caption,
      ),
      
      // 스캐폴드 테마
      scaffoldBackgroundColor: brandBg,
      
      // 인풋 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brandWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: brandGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandPink, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: body2,
      ),
      
      // 아이콘 테마
      iconTheme: const IconThemeData(
        color: brandDark,
        size: 24,
      ),
      
      // 리플 효과
      splashFactory: InkRipple.splashFactory,
    );
  }
  
  // 다크 테마
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandPink,
        brightness: Brightness.dark,
        primary: brandPink,
        secondary: const Color(0xFFFF6B9D),
        surface: const Color(0xFF1A1A1A),
        background: brandDark,
        error: const Color(0xFFE53E3E),
      ),
      
      scaffoldBackgroundColor: brandDark,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF1A1A1A),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
    );
  }
}
