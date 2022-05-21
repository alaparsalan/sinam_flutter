import 'dart:convert';

class DestinationCountryModel{
  String countryCode;
  String phonePrefix;
  String countryName;
  String localCurrency;
  int phoneLength;
  int minAmount;
  int maxAmount;

  DestinationCountryModel({ required this.countryCode, required this.localCurrency, required this.phonePrefix, required this.countryName,
                            required this.phoneLength, required this.minAmount, required this.maxAmount});

  factory DestinationCountryModel.fromJson(Map<String, dynamic> json) {
    return DestinationCountryModel(
      countryCode: json["country_code"],
      phonePrefix: json["phone_prefix"],
      countryName: json["country_name"],
      phoneLength: json["phone_length"],
      minAmount:   json["min_amount"],
      maxAmount:   json["max_amount"],
      localCurrency:   json["local_currency"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'country_code':   countryCode,
      'phone_prefix':   phonePrefix,
      'country_name':   countryName,
      'phone_length':   phoneLength,
      'min_amount':     minAmount,
      'max_amount':     maxAmount,
      'local_currency': localCurrency,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'DestinationCountryModel(countryCode: $countryCode, phonePrefix: $phonePrefix, countryName: $countryName,'
           ' phoneLength: $phoneLength, minAmount: $minAmount, maxAmount: $maxAmount)';
  }
}