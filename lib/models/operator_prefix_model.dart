import 'dart:convert';

class OperatorPrefixModel{
  String countryCode;
  int    operatorCode;
  String operatorName;
  String sendMoneyName;
  String phonePrefix;

  OperatorPrefixModel({ required this.countryCode, required this.operatorCode, required this.operatorName,
                  required this.sendMoneyName, required this.phonePrefix });

  factory OperatorPrefixModel.fromJson(Map<String, dynamic> json) {
    return OperatorPrefixModel(
      countryCode:   json["country_code"],
      operatorCode:  json["operator_code"],
      operatorName:  json["operator_name"],
      sendMoneyName: json["send_money_name"],
      phonePrefix:   json["phone_prefix"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'country_code':    countryCode,
      'operator_code':   operatorCode,
      'operator_name':   operatorName,
      'send_money_name': sendMoneyName,
      'phone_prefix':    phonePrefix,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'OperatorModel(countryCode: $countryCode, operatorCode: $operatorCode, operatorName: $operatorName,'
           ' sendMoneyName: $sendMoneyName, phonePrefix: $phonePrefix)';
  }
}