import 'dart:convert';

class VoucherModel{
  String  countryCode;
  int     operatorCode;
  String  operatorName;
  String  sendMoneyName;
  String  simName;
  String  voucherType;
  String? subType;
  int?    voucherCode;
  int?    voucherCategoryCode;
  int     price;
  String? currency;
  String? data;
  String  voucherNameFr;
  String  voucherNameEn;
  String? validity;
  String? paymentMethod;
  String? selfRechargeUssdMoney;
  String? selfRechargeUssdBalance;
  String? ussdCode;

  VoucherModel({ required this.countryCode, required this.operatorCode, required this.operatorName, this.subType,
                 required this.sendMoneyName, required this.voucherType, this.voucherCode, this.voucherCategoryCode,
                 required this.price, required this.voucherNameFr, required this.voucherNameEn, this.validity, required this.currency,
                 this.data, this.paymentMethod, this.selfRechargeUssdMoney, this.selfRechargeUssdBalance, this.ussdCode, required this.simName
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    print('VOUCHER');
    print(json);
    return VoucherModel(
      countryCode:              json["country_code"],
      operatorCode:             json["operator_code"],
      operatorName:             json["operator_name"],
      sendMoneyName:            json["send_money_name"],
      voucherType:              json["voucher_type"],
      simName:                  json["sim_name"],
      voucherCode:              json["voucher_code"],
      subType:                  json["sub_type"],
      voucherCategoryCode:      json["voucher_category_code"],
      price:                    json["price"],
      currency:                 json["currency"],
      data:                     json["data"],
      voucherNameFr:            json["voucher_name_fr"],
      voucherNameEn:            json["voucher_name_en"],
      validity:                 json["validity"],
      paymentMethod:            json["payment_method"],
      selfRechargeUssdMoney:    json["self_recharge_ussd_money"],
      selfRechargeUssdBalance:  json["self_recharge_ussd_balance"],
      ussdCode:                 json["ussd_code"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'country_code':               countryCode,
      'operator_code':              operatorCode,
      'operator_name':              operatorName,
      'send_money_name':            sendMoneyName,
      'voucher_type':               voucherType,
      'sim_name':                   simName,
      'voucher_code':               voucherCode,
      'sub_type':                   subType,
      'voucher_category_code':      voucherCategoryCode,
      'price':                      price,
      'currency':                   currency,
      'data':                       data,
      'voucher_name_fr':            voucherNameFr,
      'voucher_name_en':            voucherNameEn,
      'validity':                   validity,
      'payment_method':             paymentMethod,
      'self_recharge_ussd_money':   selfRechargeUssdMoney,
      'self_recharge_ussd_balance': selfRechargeUssdBalance,
      'ussd_code':                  ussdCode,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'VoucherModel(countryCode: $countryCode, operatorCode: $operatorCode, operatorName: $operatorName,'
           ' sendMoneyName: $sendMoneyName, voucherType: $voucherType, voucherCode: $voucherCode, voucherCategoryCode: $voucherCategoryCode, '
           ' subType: $subType, price: $price, currency: $currency, data: $data, simName: $simName, '
           ' amount: $price, voucherNameFr: $voucherNameFr, voucherNameEn: $voucherNameEn, validity: $validity, paymentMethod: $paymentMethod, '
           ' selfRechargeUssdMoney: $selfRechargeUssdMoney, selfRechargeUssdBalance: $selfRechargeUssdBalance, ussdCode: $ussdCode)';
  }
}