import 'dart:convert';

class PaymentNumberModel{

  String countryCode;
  String countryDialPrefix;
  int    countryDialCode;
  int    operatorCode;
  String number;

  PaymentNumberModel({ required this.countryCode, required this.countryDialPrefix, required this.countryDialCode, required this.operatorCode, required this.number });
  factory PaymentNumberModel.fromJson(Map<String, dynamic> json) {
    return PaymentNumberModel(
      countryCode:        json["country_code"],
      countryDialPrefix:  json["country_dial_prefix"],
      countryDialCode:    json["country_dial_code"],
      operatorCode:       json["operator_code"],
      number:             json["number"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'country_code':         countryCode,
      'country_dial_prefix':  countryDialPrefix,
      'country_dial_code':    countryDialCode,
      'operator_code':        operatorCode,
      'number':               number,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'PaymentNumberModel(countryCode: $countryCode, countryDialPrefix: $countryDialPrefix, countryDialCode: $countryDialCode, operatorCode: $operatorCode, number: $number)';
  }
}