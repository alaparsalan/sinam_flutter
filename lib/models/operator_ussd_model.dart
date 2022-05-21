import 'dart:convert';

class OperatorUssdModel{
  String countryCode;
  String service;
  String operatorCode;
  String rechargeType;
  String ussdString;
  String successString;
  int    countryPrefix;
  String operatorName;

  OperatorUssdModel({ required this.countryCode, required this.service, required this.operatorCode,
                  required this.rechargeType, required this.ussdString, required this.successString, required this.countryPrefix,
                  required this.operatorName });

  factory OperatorUssdModel.fromJson(Map<String, dynamic> json) {
    return OperatorUssdModel(
      countryCode:   json["country_code"],
      service:       json["service"],
      operatorCode:  json["operator_code"],
      rechargeType:  json["recharge_type"],
      ussdString:    json["ussd_string"],
      successString: json["sucess_string"],
      countryPrefix: json["country_prefix"],
      operatorName:  json["operator_name"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'country_code':   countryCode,
      'service':        service,
      'operator_code':  operatorCode,
      'recharge_type':  rechargeType,
      'ussd_string':    ussdString,
      'sucess_string':  successString,
      'country_prefix': countryPrefix,
      'operator_name':  operatorName,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'OperatorUssdModel(countryCode: $countryCode, service: $service, operatorCode: $operatorCode,'
           ' rechargeType: $rechargeType, ussdString: $ussdString, successString: $successString, countryPrefix: $countryPrefix,'
           ' operatorName: $operatorName)';
  }
}