import 'package:flutter/material.dart';

class AppColors {

  static const Color primaryColor       = Color(0xffe5f0ff);
  static const Color primaryDarkColor   = Color(0xffCEE4FF);
  static const Color accentColor        = Color(0xff3081c3);

  static const Color gradiantBlueColor  = Color(0xff5db8e6);

  static const Color white              = Colors.white;
  static Color boxShadow                = Colors.grey.withOpacity(0.5);
  static Color? lightGrey               = Colors.grey[400];
  static Color? lightText               = Colors.grey[300];
  static Color? normalText              = Colors.grey[500];

  static const Color menuItemColor      = Colors.white38;
  static const Color menuLineColor      = Color(0xff073A6D);
  static const Color veryLightGrey      = Color(0xffF5F5F5);

  static  MaterialColor materialAccentColor = const MaterialColor(0xff002366, _materialAccentColorMap);

  static const Map<int, Color> _materialAccentColorMap = {
     50:Color.fromRGBO(0,35,102, .1),
    100:Color.fromRGBO(0,35,102, .2),
    200:Color.fromRGBO(0,35,102, .3),
    300:Color.fromRGBO(0,35,102, .4),
    400:Color.fromRGBO(0,35,102, .5),
    500:Color.fromRGBO(0,35,102, .6),
    600:Color.fromRGBO(0,35,102, .7),
    700:Color.fromRGBO(0,35,102, .8),
    800:Color.fromRGBO(0,35,102, .9),
    900:Color.fromRGBO(0,35,102,  1),
  };
}