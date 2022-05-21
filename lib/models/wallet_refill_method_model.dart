import 'dart:convert';

class WalletRefillMethodModel{
  String value;
  WalletRefillMethodModel({ required this.value });
  factory WalletRefillMethodModel.fromJson(Map<String, dynamic> json) {
    return WalletRefillMethodModel(
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
    return 'WalletRefillMethodModel(value: $value)';
  }
}