import 'package:flutter/material.dart';

class SideMenu {
  int     id;
  String  title;
  Icon    icon;
  String? url;
  String  page;
  bool    active = false;

  SideMenu({required this.id, required this.title, required this.icon, this.url, required this.page});

  factory SideMenu.fromJson(Map<String,dynamic> json) {
    return SideMenu(
      id:     json['id'],
      title:  json['title'],
      icon:   json['icon'],
      url:    json['url'],
      page:   json['page'],
    );
  }
}