import 'package:flutter/material.dart';
import 'package:bilsemki/config.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Config.primaryColor,
      colorScheme: ColorScheme.light(
        primary: Config.primaryColor,
        secondary: Config.secondaryColor,
        error: Config.errorColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: Config.defaultPadding,
            vertical: Config.defaultPadding / 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Config.cardBorderRadius),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Config.cardBorderRadius),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Config.primaryColor,
      colorScheme: ColorScheme.dark(
        primary: Config.primaryColor,
        secondary: Config.secondaryColor,
        error: Config.errorColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: Config.defaultPadding,
            vertical: Config.defaultPadding / 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Config.cardBorderRadius),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Config.cardBorderRadius),
        ),
      ),
    );
  }
}