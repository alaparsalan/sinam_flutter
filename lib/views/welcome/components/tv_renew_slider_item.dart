import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/views/recharge/recharge.dart';
import 'package:url_launcher/url_launcher.dart';

class TvRenewSliderItem extends StatelessWidget {
  const TvRenewSliderItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Center(child: Image.asset('assets/images/tv_renew.png', width: AppConfig.screenWidth - ScreenUtil().setWidth(120))),
        const SizedBox(height: 12),
        SizedBox(
          width: MediaQuery.of(context).size.width - ScreenUtil().setWidth(160),
          child: Text(AppLocalizations.of(context)!.translate('tv_renewal_description'), style: TextStyle(overflow: TextOverflow.ellipsis, color: Colors.grey[700]!), textAlign: TextAlign.center, maxLines: 3)),
        const SizedBox(height: 30),
        GradiantButton(
            title: AppLocalizations.of(context)!.translate('tv_renew'),
            radius: 40,
            width: MediaQuery.of(context).size.width - ScreenUtil().setWidth(160),
            onPressed: () async{
              await Future.delayed(const Duration(milliseconds: 250));
              openURL(AppConfig.tvRenewURL, context);
            }
        ),
      ],
    );
  }

  void openURL(String url, BuildContext context) async{
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        Message.show(context, AppLocalizations.of(context)!.translate('browser_error'));
      }
    } catch (error) {
      if(!AppConfig.isPublished){ print('error: $error'); }
    }
  }
}
