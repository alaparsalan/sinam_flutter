
import 'package:intl/intl.dart';
import 'package:sim_data/sim_data.dart';
import 'package:sinam/models/side_menu.dart';

class AppConfig {
  static const String appName = 'Sinam';

  static const String googleStoreVersion = '1.0.0';
  static const String appleStoreVersion = '1.0.0';
  static const String appVersion = '1.0.0';
  static const String apiVersion = '1';

  static String? apiKey = 'Th1s#1S,For:M0bil3D3vel0pMent;()nly!';
  static String? initSecret = '\$pbkdf2-sha256\$29000\$.B8jpJQSYmztfS9l7L0XQg\$sQDbCw6zPQz9NxJembbKh0onH/.e/htqLzufGAL02dw';
  static String? countryCode;
  static String? initToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY0MjY4ODA5MywianRpIjoiNWFlZjNiODMtOWFmNy00MTcyLWIwZDQtNWU1MTBmYmY5OTIyIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6eyJ1c2VybmFtZSI6Im1vYmlsZS5kZXYiLCJyb2xlIjoibW9iaWxlX2luaXQifSwibmJmIjoxNjQyNjg4MDkzLCJleHAiOjE2NTA0NjQwOTN9.OqMQgs9WZrKvuR4FuVd_2yQG63l5hLJX0gkyQKmmMR8';

  static const bool isPublished = false;
  static String apiURL = 'https://hubformobiletopup.online/';

  static List<SideMenu>? sideMenu;

  static late double screenWidth, screenHeight;
  static String? isoCountryCode;
  static String? carrierName;
  static SimData? simData;
  static String? imei;

  static late String selectedLanguage;
  static bool offlineSt = false;
  static bool allowResendTotpCode = true;
  static int resendTotpCodeWaitTime = 59;

  static String whatsapp = '123456789';
  static String telegram = 'https://telegram.org';

  static String payBillsURL = '';
  static String cashPowerURL = '';
  static String tvRenewURL = '';

  static String? connectionErrorEn;
  static String? connectionErrorFr;
  static var numberFormat = NumberFormat("###,###.0#", "en_US");

  static bool forceLogoutSt = false;
  static bool confirmPaymentSt = false;
  static Map<String, dynamic>? confirmPaymentPostData;
}