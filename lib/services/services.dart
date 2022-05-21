
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/database/storage.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/helper.dart';

class Services{

  final Storage storage = Storage();

  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': '*/*',
  };

  Future<dynamic> get({ required BuildContext context, required  String endPoint, bool? isInit, bool? noTokenCheck}) async {
    String? token;
    if(isInit != null && isInit){
      String? initToken = await storage.getString('init_token');
      if(initToken != null){
        token = initToken;
      }else{
        token = AppConfig.initToken;
      }
    }else{
      token = await storage.getString('token');
    }
    try{
      if(await Helper.isNetAvailable()) {
        if(noTokenCheck == null || noTokenCheck == false){
          token = await checkToken(context, token);
        }
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
          final url = AppConfig.apiURL + endPoint;
          final http.Response response = await http.get(Uri.parse(url), headers: headers);
          if (response.statusCode == 200 || response.statusCode == 204) {
            if (!AppConfig.isPublished) {print('$endPoint response: ${response.body}');}
            if (response.body.isNotEmpty) {
              return json.decode(utf8.decode(response.bodyBytes));
            } else {
              return true;
            }
          } else {
            throw response.body;
          }
        } else {
          throw AppLocalizations.of(context)!.translate('receive_error_description');
        }
      }else{
        throw AppLocalizations.of(context)!.translate('connection_error_description');
      }
    }catch(error){
      if(!AppConfig.isPublished){ print('$endPoint error: $error');}
      throw AppLocalizations.of(context)!.translate('receive_error');
    }
  }

  Future<dynamic> post({ required BuildContext context, required String endPoint, dynamic postData, bool? isInit, bool? noTokenCheck}) async {
    String? token;
    if(isInit != null && isInit == true){
      String? initToken = await storage.getString('init_token');
      if(initToken != null){
        token = initToken;
      }else{
        token = AppConfig.initToken;
      }
    }else{
      token = await storage.getString('access_token');
    }
    try{

      //eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY0OTcwNTc0NiwianRpIjoiZmVhMzg4OTgtMDU3Yi00MTQ1LWIwM2EtMmQ5OTdkOGQ4YzJmIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6eyJ1c2VybmFtZSI6ImFuYXNAYW5hcy5jb20iLCJyb2xlIjoiY3VzdG9tZXIifSwibmJmIjoxNjQ5NzA1NzQ2LCJleHAiOjE2NDk3OTIxNDZ9.wLNo4YecTfikQmrygjjeUc-EJQL9r-hzgYbmfFwZQNI
      if(await Helper.isNetAvailable()) {
        if(noTokenCheck == null || noTokenCheck == false){
          token = await checkToken(context, token);
        }
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
          final url = AppConfig.apiURL + endPoint;
          final http.Response response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(postData ?? {}));
          if(!AppConfig.isPublished)
            print(response.body);
          if (response.statusCode == 200 || response.statusCode == 204) {
            if (!AppConfig.isPublished) {print('$endPoint response: ${response.body}');}
            if (response.body.isNotEmpty) {
              return json.decode(utf8.decode(response.bodyBytes));
            } else {
              return false;
            }
          } else {
            throw json.decode(utf8.decode(response.bodyBytes));
          }
        } else {
          throw AppLocalizations.of(context)!.translate('receive_error_description');
        }
      }else{
        throw AppLocalizations.of(context)!.translate('connection_error_description');
      }
    }catch(error){
      if(!AppConfig.isPublished){ print('$endPoint error: $error');}
      if(error is Map<String, dynamic>){
        throw error['message'];
      }else{
        throw AppLocalizations.of(context)!.translate('receive_error');
      }
    }
  }

  Future<dynamic> refreshToken(BuildContext context) async{
    storage.saveString('init_token', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY1MDc5MzUwMywianRpIjoiYTQwZjQ4NmItZWQ2Yi00YzhlLTkxOWYtYTYxMmE1NGNkMDMzIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6eyJ1c2VybmFtZSI6ImRldi5vbmxpbmV0b3B1cEBnbWFpbC5jb20iLCJyb2xlIjoibW9iaWxlX2luaXQifSwibmJmIjoxNjUwNzkzNTAzLCJleHAiOjE2NTg1Njk1MDN9.5TaspngKHjgFlu4xPtfIBJ0C0OHbotGbMlmhnXpeQa0');
    try{
      if(await Helper.isNetAvailable()) {
        final url = AppConfig.apiURL + 'Mobile/GetInitToken';
        final http.Response response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode({
          'init_secret': AppConfig.initSecret,
          'imei_code':  AppConfig.imei,
          'api_key': AppConfig.apiKey,
        }));
        if (response.statusCode == 200 || response.statusCode == 204) {
          if (!AppConfig.isPublished) {print('Mobile/GetInitToken response: ${response.body}');}
          if (response.body.isNotEmpty) {
            dynamic result = json.decode(utf8.decode(response.bodyBytes))['token'];
            if(result != null && result is String){
              AppConfig.initToken = result;
              storage.saveString('init_token', result);
              storage.saveString('init_token', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY1MDc5MzUwMywianRpIjoiYTQwZjQ4NmItZWQ2Yi00YzhlLTkxOWYtYTYxMmE1NGNkMDMzIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6eyJ1c2VybmFtZSI6ImRldi5vbmxpbmV0b3B1cEBnbWFpbC5jb20iLCJyb2xlIjoibW9iaWxlX2luaXQifSwibmJmIjoxNjUwNzkzNTAzLCJleHAiOjE2NTg1Njk1MDN9.5TaspngKHjgFlu4xPtfIBJ0C0OHbotGbMlmhnXpeQa0');
              return true;
            }
          } else {
            return false;
          }
        } else {
          throw json.decode(utf8.decode(response.bodyBytes));
        }
      }else{
        throw AppLocalizations.of(context)!.translate('connection_error_description');
      }
    }catch(error){
      if(!AppConfig.isPublished){ print('refresh token error: $error');}
      if(error is Map<String, dynamic>){
        throw error['message'];
      }else{
        throw AppLocalizations.of(context)!.translate('receive_error');
      }
    }
  }

  Future<String?> checkToken(BuildContext context, String? token) async{
    String? tk;
    if(token != null){
      if(JwtDecoder.isExpired(token)){
        print('Token Expired');
        dynamic result = await refreshToken(context);
        if (result is bool && result) {
          tk = await storage.getString('init_token');
          if(tk != null){
            return tk;
          }else{
            return null;
          }
        } else {
          return null;
        }
      }else{
        return token;
      }
    }else{
      return null;
    }
  }
}