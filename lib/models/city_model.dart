import 'dart:convert';

class CityModel{
  String name;
  CityModel({ required this.name });
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json["name"],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'name': name,
    };
  }
  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'CityModel(name: $name)';
  }
}