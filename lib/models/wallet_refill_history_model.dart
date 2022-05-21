import 'dart:convert';

class WalletRefillHistoryModel{

  double  amountOfDeposit;
  String? cardNumber;
  String? cardType;
  String  customerId;
  String? mobileOperator;
  String? operatorMessage;
  String? operatorReference;
  String  orderId;
  String  paymentMethod;
  String? paypalEmail;
  String? paypalId;
  String  receiverCurrency;
  double  serviceFee;
  double  smsFee;
  double  totalCharge;
  String  transactionCurrency;
  String  transactionDate;
  double? transferFee;

  WalletRefillHistoryModel({ required this.amountOfDeposit, this.cardNumber, this.cardType, required this.customerId, this.mobileOperator,
    this.operatorMessage, this.operatorReference, required this.orderId, required this.paymentMethod, this.paypalEmail, this.paypalId,
    required this.receiverCurrency, required this.serviceFee, required this.smsFee, required this.totalCharge, required this.transactionCurrency,
    required this.transactionDate, this.transferFee
  });

  factory WalletRefillHistoryModel.fromJson(Map<String, dynamic> json) {
    return WalletRefillHistoryModel(
      amountOfDeposit:      double.parse(json["amount_of_deposit"].toString()),
      cardNumber:           json["card_number"],
      cardType:             json["card_type"],
      customerId:           json["customer_id"],
      mobileOperator:       json["mobile_operator"],
      operatorMessage:      json["operator_message"],
      operatorReference:    json["operator_reference"],
      orderId:              json["order_id"],
      paymentMethod:        json["payment_method"],
      paypalEmail:          json["paypal_email"],
      paypalId:             json["paypal_id"],
      receiverCurrency:     json["receiver_currency"],
      serviceFee:           json["service_fee"],
      smsFee:               json["sms_fee"],
      totalCharge:          json["total_charge"],
      transactionCurrency:  json["transaction_currency"],
      transactionDate:      json["transaction_date"],
      transferFee:          json["transfert_fee"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'amount_of_deposit':     amountOfDeposit,
      'card_number':           cardNumber,
      'card_type':             cardType,
      'customer_id':           customerId,
      'mobile_operator':       mobileOperator,
      'operator_message':      operatorMessage,
      'operator_reference':    operatorReference,
      'order_id':              orderId,
      'payment_method':        paymentMethod,
      'paypal_email':          paypalEmail,
      'paypal_id':             paypalId,
      'receiver_currency':     receiverCurrency,
      'service_fee':           serviceFee,
      'sms_fee':               smsFee,
      'total_charge':          totalCharge,
      'transaction_currency':  transactionCurrency,
      'transaction_date':      transactionDate,
      'transfert_fee':         transferFee,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'WalletRefillHistoryModel(amountOfDeposit: $amountOfDeposit, cardNumber: $cardNumber, cardType: $cardType, customerId: $customerId, '
           'mobileOperator: $mobileOperator, operatorMessage: $operatorMessage, operatorReference: $operatorReference, orderId: $orderId, '
           'paymentMethod: $paymentMethod, paypalEmail: $paypalEmail, paypalId: $paypalId, receiverCurrency: $receiverCurrency, serviceFee: $serviceFee, '
           'smsFee: $smsFee, totalCharge: $totalCharge, transactionCurrency: $transactionCurrency, transactionDate: $transactionDate, transferFee: $transferFee)';
  }
}