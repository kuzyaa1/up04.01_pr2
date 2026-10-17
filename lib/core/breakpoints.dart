import 'package:flutter/material.dart';

/// Классы ширины окна, используемые в приложении.
///
/// Спецификация Material 3 описывает пять классов; для учебной работы
/// достаточно трёх границ.
enum ScreenSize { compact, medium, expanded }

/// Ширина, ниже которой таблица заменяется списком карточек.
const double kCompactWidth = 600;

ScreenSize screenSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < kCompactWidth) return ScreenSize.compact;
  if (width < 1200) return ScreenSize.medium;
  return ScreenSize.expanded;
}
