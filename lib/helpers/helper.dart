
import 'package:flutter/material.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'data_connection_checker.dart';

class Helper{

  static Future<bool> isNetAvailable() async {
    try{
      return await DataConnectionChecker().hasConnection;
    }catch(error){
      if(!AppConfig.isPublished){print(error);}
      return false;
    }
  }

  static bool isNumeric(String string) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
    return numericRegex.hasMatch(string);
  }

  static String printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  static InputDecoration dropDownInputDecoration(){
    return const InputDecoration(
      border: OutlineInputBorder(
          borderSide:  BorderSide(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      enabledBorder: OutlineInputBorder(
          borderSide:  BorderSide(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      focusedBorder:OutlineInputBorder(
          borderSide:  BorderSide(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      errorBorder: OutlineInputBorder(
          borderSide:  BorderSide(color: Colors.redAccent, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      disabledBorder: OutlineInputBorder(
          borderSide:  BorderSide(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      isDense: true,
      contentPadding: EdgeInsets.fromLTRB(22, 20, 15, 12),
      errorMaxLines: 1,
      errorStyle: TextStyle(fontSize: 12, color: Colors.redAccent),
    );
  }

  static InputDecoration roundDropDownInputDecoration(){
    return const InputDecoration(
      filled: true,
      fillColor: Color(0xffaae7ff),
      border: OutlineInputBorder(
          borderSide:  BorderSide(color: Color(0xffaae7ff), width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      enabledBorder: OutlineInputBorder(
          borderSide:  BorderSide(color: Color(0xffaae7ff), width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      focusedBorder:OutlineInputBorder(
          borderSide:  BorderSide(color: Color(0xffaae7ff), width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      errorBorder: OutlineInputBorder(
          borderSide:  BorderSide(color: Colors.redAccent, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      disabledBorder: OutlineInputBorder(
          borderSide:  BorderSide(color: Color(0xffaae7ff), width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      isDense: true,
      contentPadding: EdgeInsets.fromLTRB(22, 20, 15, 12),
      errorMaxLines: 1,
      errorStyle: TextStyle(fontSize: 12, color: Colors.redAccent),
    );
  }

  static InputDecoration registerDropDownInputDecoration({Widget? suffixIcon}){
    return InputDecoration(
      border: OutlineInputBorder(
          borderSide:  BorderSide(color: Colors.grey[300]!, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(10))
      ),
      enabledBorder: OutlineInputBorder(
          borderSide:  BorderSide(color: Colors.grey[300]!, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(10))
      ),
      focusedBorder:OutlineInputBorder(
          borderSide:  BorderSide(color: Colors.grey[300]!, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(10))
      ),
      errorBorder: const OutlineInputBorder(
          borderSide:  BorderSide(color: Colors.redAccent, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      disabledBorder: OutlineInputBorder(
          borderSide:  BorderSide(color: Colors.grey[300]!, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(10))
      ),
      isDense: true,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.fromLTRB(22, 18, 15, 12),
      errorMaxLines: 1,
      errorStyle: const TextStyle(fontSize: 12, color: Colors.redAccent),
    );
  }

  static BoxDecoration appBackgroundDecoration(){
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          AppColors.gradiantBlueColor,
          Colors.white
        ],
      ),
    );
  }

  static String truncate(String text, { length: 7, omission: '...' }) {
    if (length >= text.length) { return text;}
    return text.replaceRange(length, text.length, omission);
  }
}