
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/database/storage.dart';
import 'package:sinam/helpers/font_size_and_locale_controller.dart';
import '../helpers/app_localizations.dart';

class LanguageDialog extends StatefulWidget {

  final Function(String language) onSelect;
  const LanguageDialog({Key? key,  required this.onSelect }) : super(key: key);

  @override
  _LanguageDialogState createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> with SingleTickerProviderStateMixin {

  AnimationController? controller;
  Animation<double>? scaleAnimation;
  late FontSizeAndLocaleController fontSizeAndLocaleController;
  final Storage storage = Storage();

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller!, curve: Curves.linearToEaseOut);

    controller!.addListener(() {
      setState(() {});
    });

    controller!.forward();

    fontSizeAndLocaleController = context.read<FontSizeAndLocaleController>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: SizedBox(
          width: ScreenUtil().setWidth(360),
          child: ScaleTransition(
            scale: scaleAnimation!,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                          width: double.infinity,
                          height: ScreenUtil().setHeight(60),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 3,
                                  blurRadius: 4,
                                  offset: const Offset(0, 1), // changes position of shadow
                                ),
                              ]
                          ),
                          child: Center(
                            child: Text(AppLocalizations.of(context)!.translate('select_your_language'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.center),
                          )
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () async{
                              if(mounted) {
                                await Future.delayed(
                                const Duration(milliseconds: 250));
                                try{
                                  storage.saveString('locale', 'en');
                                }catch(error){
                                  if(!AppConfig.isPublished){ print('error: $error');}
                                }finally{
                                  widget.onSelect('en');
                                  fontSizeAndLocaleController.setLocale(const Locale('en', 'US'));
                                }
                                Navigator.pop(context);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                              child: Row(
                                children: [
                                  //Image.asset('assets/images/en.png', width: 50, height: 50),
                                  Container(
                                    width: ScreenUtil().setHeight(48),
                                    height: ScreenUtil().setHeight(48),
                                    child: const Center(child: Text('EN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, fontStyle: FontStyle.italic))),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(width: 31),
                                  const Text('English')
                                ],
                              ),
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey[300], thickness: 1),
                          InkWell(
                            onTap: () async{
                              if(mounted){
                                await Future.delayed(const Duration(milliseconds: 250));
                                try{
                                  storage.saveString('locale', 'fr');
                                }catch(error){
                                  if(!AppConfig.isPublished){ print('error: $error');}
                                }finally{
                                  widget.onSelect('fr');
                                  fontSizeAndLocaleController.setLocale(const Locale('fr', 'FR'));
                                }
                                Navigator.pop(context);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                              child: Row(
                                children: [
                                  //Image.asset('assets/images/fr.png', width: 50, height: 50),
                                  Container(
                                    width: ScreenUtil().setHeight(48),
                                    height: ScreenUtil().setHeight(48),
                                    child: const Center(child: Text('FR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, fontStyle: FontStyle.italic))),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(width: 29),
                                  const Text('Français')
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 1, color: Colors.grey[300], thickness: 1),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: ScreenUtil().setHeight(55),
                        child: TextButton(
                            onPressed: () async{
                              await Future.delayed(const Duration(milliseconds: 300));
                              if(mounted){ Navigator.pop(context); }
                            },
                            child: Text(AppLocalizations.of(context)!.translate('cancel'), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.blue[500]), textAlign: TextAlign.center)
                        ),
                      ),
                    ],
                  )
              ),
            ),
          ),
        ),
      ),
    );
  }
}