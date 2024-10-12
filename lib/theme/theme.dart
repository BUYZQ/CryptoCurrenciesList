import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  primaryColor: Colors.yellow,
  useMaterial3: true,
  scaffoldBackgroundColor: const Color.fromARGB(255, 31, 31, 31),
  dividerColor: Colors.white12,
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    scrolledUnderElevation: 0,
    elevation: 0,
    foregroundColor: Colors.white,
    backgroundColor: Color.fromARGB(255, 31, 31, 31),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 22,
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: const TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyMedium: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    labelSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Colors.white.withOpacity(0.6),
    ),
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.white,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.yellow,
  ),
);
