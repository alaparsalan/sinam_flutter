import 'dart:convert';

class CurrencyExchangeRateModel{
  String customerCurrency;
  String? destinationCurrency;
  double? rate;
  CurrencyExchangeRateModel({ required this.customerCurrency, required this.destinationCurrency, required this.rate });
  factory CurrencyExchangeRateModel.fromJson(dynamic json) {
    return CurrencyExchangeRateModel(
      customerCurrency: json["customer_currency"],
      destinationCurrency: json["destination_currency"],
      rate: json["rate"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'customer_currency': customerCurrency,
      'destination_currency': destinationCurrency,
      'rate': rate,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'CurrencyExchangeRateModel(customerCurrency: $customerCurrency, destinationCurrency: $destinationCurrency, rate: $rate)';
  }
}