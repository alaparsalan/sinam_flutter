import 'dart:convert';

class OperatorModel{
  String countryCode;
  int    operatorCode;
  String operatorName;
  String simName;
  String sendMoneyName;
  String? sendMoneyFlag;

  OperatorModel({ required this.countryCode, required this.operatorCode, required this.operatorName,
                  required this.sendMoneyName, required this.simName, this.sendMoneyFlag });

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      countryCode:   json["country_code"],
      operatorCode:  json["operator_code"],
      operatorName:  json["operator_name"],
      sendMoneyName: json["send_money_name"],
      simName:       json["sim_name"],
      sendMoneyFlag: json["send_money_flag"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'country_code':    countryCode,
      'operator_code':   operatorCode,
      'operator_name':   operatorName,
      'send_money_name': sendMoneyName,
      'sim_name':        simName,
      'send_money_flag': sendMoneyFlag,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'OperatorModel(countryCode: $countryCode, operatorCode: $operatorCode, operatorName: $operatorName,'
           ' sendMoneyName: $sendMoneyName, simName: $simName, sendMoneyFlag: $sendMoneyFlag)';
  }
}