import 'dart:convert';

class TransferReasonModel{

  String transferReasonFr;
  String transferReasonEn;

  TransferReasonModel({ required this.transferReasonFr, required this.transferReasonEn });
  factory TransferReasonModel.fromJson(Map<String, dynamic> json) {
    return TransferReasonModel(
      transferReasonFr: json["transfer_reason_fr"],
      transferReasonEn: json["transfer_reason_en"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'transfer_reason_fr': transferReasonFr,
      'transfer_reason_en': transferReasonEn,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'TransferReasonModel(transferReasonFr: $transferReasonFr)';
  }
}