import 'dart:convert';

class ServiceModel{
  String  serviceNameEn;
  String  serviceNameFr;
  String? redirectURL;

  ServiceModel({ required this.serviceNameEn, required this.serviceNameFr, this.redirectURL });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceNameEn:   json["service_name_en"],
      serviceNameFr:   json["service_name_fr"],
      redirectURL:     json["redirect_url"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'service_name_en':    serviceNameEn,
      'service_name_fr':    serviceNameFr,
      'redirect_url':       redirectURL,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'ServiceModel(serviceNameEn: $serviceNameEn, serviceNameFr: $serviceNameFr, redirectURL: $redirectURL)';
  }
}