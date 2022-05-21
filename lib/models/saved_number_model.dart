import 'dart:convert';

class SavedNumberModel{
  String recipientNumber;
  String countryCode;
  String countryIsoCode;
  int    operatorCode;
  SavedNumberModel({ required this.recipientNumber, required this.countryCode, required this.countryIsoCode, required this.operatorCode });
  factory SavedNumberModel.fromJson(Map<String, dynamic> json) {
    return SavedNumberModel(
      recipientNumber:  json["recipient_number"],
      countryCode:      json["country_code"] ?? '+228',
      countryIsoCode:   json["country_iso_code"] ?? 'TG',
      operatorCode:     json["operator_code"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'recipient_number': recipientNumber,
      'country_code':     countryCode,
      'country_iso_code': countryIsoCode,
      'operator_code':    operatorCode,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'SavedNumberModel(recipientNumber: $recipientNumber, countryCode: $countryCode, countryIsoCode: $countryIsoCode, operatorCode: $operatorCode)';
  }
}