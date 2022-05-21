import 'dart:convert';

class TransactionHistoryModel{

  double  amount;
  String? cardNumber;
  String? cardType;
  String? countryName;
  String  customerId;
  String  destinationNumber;
  double  exchangeRate;
  String? operatorMessage;
  String? operatorName;
  String? operatorReference;
  String  orderId;
  String  paymentMethod;
  String? paypalId;
  String? processStatus;
  String  receiverCurrency;
  String  servicdeFr;
  String  serviceEn;
  double  serviceFee;
  double  smsFee;
  double  totalCharge;
  double  totalToReceiver;
  String  transactionCurrency;
  String  transactionDate;
  String  transactionId;
  String? transfertFee;
  String? voucherName;
  String? voucherType;
  String? walletPaymentId;

  TransactionHistoryModel({ required this.amount, this.cardNumber, this.cardType, required this.customerId,
    this.operatorMessage, this.operatorReference, required this.orderId, required this.paymentMethod, this.paypalId,
    required this.receiverCurrency, required this.serviceFee, required this.smsFee, required this.totalCharge, required this.transactionCurrency,
    required this.transactionDate, this.voucherType, this.operatorName, this.countryName, required this.destinationNumber, required this.exchangeRate, this.processStatus,
    required this.servicdeFr, required this.serviceEn, required this.totalToReceiver, this.transfertFee, required this.transactionId, this.voucherName, this.walletPaymentId
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      amount:               double.parse(json["amount"].toString()),
      cardNumber:           json["card_number"],
      cardType:             json["card_type"],
      customerId:           json["customer_id"],
      operatorMessage:      json["operator_message"],
      operatorReference:    json["operator_reference"],
      orderId:              json["order_id"],
      paymentMethod:        json["payment_method"],
      paypalId:             json["paypal_id"],
      receiverCurrency:     json["receiver_currency"],
      serviceFee:           json["service_fee"],
      smsFee:               json["sms_fee"],
      totalCharge:          json["total_charge"],
      transactionCurrency:  json["transaction_currency"],
      transactionDate:      json["transaction_date"],
      destinationNumber:    json["destination_number"],
      exchangeRate:         json["exchange_rate"],
      servicdeFr:           json["servicde_fr"],
      serviceEn:            json["service_en"],
      totalToReceiver:      double.parse(json["total_to_receiver"].toString()),
      transactionId:        json["transaction_id"],
      countryName:          json["country_name"],
      operatorName:         json["operator_name"],
      processStatus:        json["process_status"],
      transfertFee:         json["transfert_fee"],
      voucherName:          json["voucher_name"],
      voucherType:          json["voucher_type"],
      walletPaymentId:      json["wallet_payment_id"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'amount':                amount,
      'card_number':           cardNumber,
      'card_type':             cardType,
      'customer_id':           customerId,
      'operator_message':      operatorMessage,
      'operator_reference':    operatorReference,
      'order_id':              orderId,
      'payment_method':        paymentMethod,
      'paypal_id':             paypalId,
      'receiver_currency':     receiverCurrency,
      'service_fee':           serviceFee,
      'sms_fee':               smsFee,
      'total_charge':          totalCharge,
      'transaction_currency':  transactionCurrency,
      'transaction_date':      transactionDate,
      'destination_number':    destinationNumber,
      'exchange_rate':         exchangeRate,
      'servicde_fr':           servicdeFr,
      'service_en':            serviceEn,
      'total_to_receiver':     totalToReceiver,
      'transaction_id':        transactionId,
      'country_name':          countryName,
      'operator_name':         operatorName,
      'process_status':        processStatus,
      'transfert_fee':         transfertFee,
      'voucher_name':          voucherName,
      'voucher_type':          voucherType,
      'wallet_payment_id':     walletPaymentId,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'TransactionHistoryModel(amount: $amount, cardNumber: $cardNumber, cardType: $cardType, customerId: $customerId, '
           'operatorMessage: $operatorMessage, operatorReference: $operatorReference, orderId: $orderId, '
           'paymentMethod: $paymentMethod, paypalId: $paypalId, receiverCurrency: $receiverCurrency, serviceFee: $serviceFee, '
           'smsFee: $smsFee, totalCharge: $totalCharge, transactionCurrency: $transactionCurrency, transactionDate: $transactionDate, '
           'destinationNumber: $destinationNumber, exchangeRate: $exchangeRate, servicdeFr: $servicdeFr, serviceEn: $serviceEn, totalToReceiver: $totalToReceiver, '
           'transactionId: $transactionId, countryName: $countryName, operatorName: $operatorName, processStatus: $processStatus, transfertFee: $transfertFee, '
           'voucherName: $voucherName, voucherType: $voucherType, walletPaymentId: $walletPaymentId)';
  }
}