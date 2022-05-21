import 'dart:convert';

class CurrencyModel{
  String currencyCode;
  String? currencySymbol;
  CurrencyModel({ required this.currencyCode, this.currencySymbol });
  factory CurrencyModel.fromJson(dynamic json) {
    return CurrencyModel(
      currencyCode: json["currency_code"],
      currencySymbol: json["currency_symbol"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'CurrencyModel(currencyCode: $currencyCode, currencySymbol: $currencySymbol)';
  }
}