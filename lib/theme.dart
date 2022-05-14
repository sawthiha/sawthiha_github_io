part of 'main.dart';

abstract class ColorPalette  {

  static const primary = Color(0xff303030);
  static const contrast = Color(0xfffafafa);
  static const accent = Color(0xff0094FF);

}

final themeData = ThemeData(
  primaryColor: ColorPalette.primary,
);
