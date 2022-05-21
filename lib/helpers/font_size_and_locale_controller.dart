import 'package:flutter/material.dart';

import 'app_localizations.dart';

class FontSizeAndLocaleController with ChangeNotifier {
  double _value = 0;
  double? _baseTextScaleFactor;
  double get value => _value;
  double? get baseTextScaleFactor => _baseTextScaleFactor;

  Locale? _locale;
  Locale? get locale => _locale;

  void increment() {
    _value = _value + 0.1;
    notifyListeners();
  }

  void decrement() {
    _value = _value - 0.1;
    notifyListeners();
  }

  void set(double val) {
    _value = val;
    notifyListeners();
  }

  void setBaseTextScaleFactor(double val) {
    _baseTextScaleFactor = val;
  }

  void reset() {
    _value = 0;
    notifyListeners();
  }

  void setLocale(Locale locale){
    if(!AppLocalizations.delegate.isSupported(locale)) return;

    _locale = locale;
    notifyListeners();
  }

  void clearLocale(){
    _locale = null;
    notifyListeners();
  }
}