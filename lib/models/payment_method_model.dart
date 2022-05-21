import 'dart:convert';

class PaymentMethodModel{
  String value;
  PaymentMethodModel({ required this.value });
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      value: json["value"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'value': value,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'PaymentMethodModel(value: $value)';
  }
}