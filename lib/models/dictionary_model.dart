import 'dart:convert';
import 'package:sinam/models/destination_country_model.dart';
import 'package:sinam/models/operator_model.dart';
import 'package:sinam/models/operator_prefix_model.dart';
import 'package:sinam/models/operator_ussd_model.dart';
import 'package:sinam/models/payment_method_model.dart';
import 'package:sinam/models/service_model.dart';
import 'package:sinam/models/transfert_reason_model.dart';
import 'package:sinam/models/voucher_model.dart';
import 'package:sinam/models/wallet_refill_method_model.dart';

import 'saved_number_model.dart';

class DictionaryModel{

  List<DestinationCountryModel>?  destinationCountries;
  List<OperatorModel>?            operators;
  List<OperatorPrefixModel>?      operatorsPrefix;
  List<ServiceModel>?             services;
  List<VoucherModel>?             vouchers;
  List<OperatorUssdModel>?        operatorsUssd;
  List<WalletRefillMethodModel>?  walletRefillMethod;
  List<PaymentMethodModel>?       paymentMethod;
  List<TransferReasonModel>?      transferReasons;

  DictionaryModel({ this.destinationCountries, this.operators, this.operatorsPrefix, this.services, this.vouchers, this.operatorsUssd,
                    this.walletRefillMethod, this.paymentMethod, this.transferReasons });

  factory DictionaryModel.fromJson(Map<String, dynamic> json) {
    return DictionaryModel(
      destinationCountries:   json["desination_countries"].map<DestinationCountryModel>((model) => DestinationCountryModel.fromJson(model)).toList(),
      operators:              json["operators"].map<OperatorModel>((model) => OperatorModel.fromJson(model)).toList(),
      operatorsPrefix:        json["operators_prefix"].map<OperatorPrefixModel>((model) => OperatorPrefixModel.fromJson(model)).toList(),
      services:               json["services"].map<ServiceModel>((model) => ServiceModel.fromJson(model)).toList(),
      vouchers:               json["vouchers"].map<VoucherModel>((model) => VoucherModel.fromJson(model)).toList(),
      operatorsUssd:          json["operators_ussd"].map<OperatorUssdModel>((model) => OperatorUssdModel.fromJson(model)).toList(),
      walletRefillMethod:     json["wallet_refill_method"].map<WalletRefillMethodModel>((model) => WalletRefillMethodModel.fromJson(model)).toList(),
      paymentMethod:          json["payment_method"].map<PaymentMethodModel>((model) => PaymentMethodModel.fromJson(model)).toList(),
      transferReasons:        json["transfert_reasons"].map<TransferReasonModel>((model) => TransferReasonModel.fromJson(model)).toList(),
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'desination_countries': destinationCountries,
      'operators':            operators,
      'operators_prefix':     operatorsPrefix,
      'services':             services,
      'vouchers':             vouchers,
      'operators_ussd':       operatorsUssd,
      'wallet_refill_method': walletRefillMethod,
      'payment_method':       paymentMethod,
      'transfert_reasons':    transferReasons,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'DictionaryModel(destinationCountries: $destinationCountries, operators: $operators, operatorsPrefix: $operatorsPrefix, '
           ' services: $services, vouchers: $vouchers, operatorsUssd: $operatorsUssd, walletRefillMethod: $walletRefillMethod,'
           ' paymentMethod: $paymentMethod, transferReasons: $transferReasons)';
  }
}