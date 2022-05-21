import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:provider/provider.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'config/app_colors.dart';
import 'config/app_config.dart';
import 'database/storage.dart';
import 'helpers/app_localizations.dart';
import 'helpers/custom_scroll_behavior.dart';
import 'helpers/font_size_and_locale_controller.dart';
import 'view_models/wallet_view_model.dart';
import 'views/splash/splash.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FontSizeAndLocaleController>(create: (BuildContext context) => FontSizeAndLocaleController()),
        ChangeNotifierProvider<InitViewModel>(create: (BuildContext context) => InitViewModel()),
        ChangeNotifierProvider<WalletViewModel>(create: (BuildContext context) => WalletViewModel()),
      ],
      child: App()
    )
  );
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  final Storage storage = Storage();
  Locale? selectedLocale;

  @override
  Widget build(BuildContext context) {
    FontSizeAndLocaleController fontSizeAndLocaleController = Provider.of<FontSizeAndLocaleController>(context, listen: false);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light
    ));

    /*return MaterialApp(
              title: AppConfig.appName,
              debugShowCheckedModeBanner: false,
              navigatorObservers: [defaultLifecycleObserver],
              scrollBehavior: CustomScrollBehavior(),
              theme: ThemeData(
                backgroundColor: AppColors.primaryColor,
                primaryColor:  AppColors.primaryDarkColor,
                primarySwatch: AppColors.materialAccentColor,
                canvasColor:   Colors.transparent,
                appBarTheme: const AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                ),
              ),
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('fr', 'FR'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale == null) {
                  return supportedLocales.first;
                }
                for(var supportedLocale in supportedLocales){
                  if(supportedLocale.languageCode == locale.languageCode && supportedLocale.countryCode == locale.countryCode){
                    return supportedLocale;
                  }
                }
                return supportedLocales.first;
              },
              locale: selectedLocale,
              builder: (BuildContext context, Widget? child){
                final MediaQueryData data = MediaQuery.of(context);
                final scale = data.textScaleFactor.clamp(1.1, 1.1);
                fontSizeAndLocaleController.setBaseTextScaleFactor(scale);
                storage.saveDouble('base_scale', fontSizeAndLocaleController.baseTextScaleFactor!);
                getLocaleAndSize(fontSizeAndLocaleController);
                return Consumer<FontSizeAndLocaleController>(
                  builder: (cnx, value, ch){
                    WidgetsBinding.instance!.addPostFrameCallback((_){ setState(() { selectedLocale = value.locale; });});
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
                      child: Transform.scale(
                          scale: 1,
                          child: child!
                      ),
                    );
                  },
                );
              },
              home: const Splash()
    );*/
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: () =>
       MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        navigatorObservers: [defaultLifecycleObserver],
        scrollBehavior: CustomScrollBehavior(),
        theme: ThemeData(
          backgroundColor: AppColors.primaryColor,
          primaryColor:  AppColors.primaryDarkColor,
          primarySwatch: AppColors.materialAccentColor,
          canvasColor:   Colors.transparent,
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),

        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
        ],

        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],

        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) {
            return supportedLocales.first;
          }

          for(var supportedLocale in supportedLocales){
            if(supportedLocale.languageCode == locale.languageCode && supportedLocale.countryCode == locale.countryCode){
              return supportedLocale;
            }
          }

          return supportedLocales.first;
        },

        locale: selectedLocale,

        builder: (BuildContext context, Widget? child){
          ScreenUtil.setContext(context);
          final MediaQueryData data = MediaQuery.of(context);
          final scale = data.textScaleFactor.clamp(1.1, 1.1);
          fontSizeAndLocaleController.setBaseTextScaleFactor(scale);
          storage.saveDouble('base_scale', fontSizeAndLocaleController.baseTextScaleFactor!);
          getLocaleAndSize(fontSizeAndLocaleController);
          return Consumer<FontSizeAndLocaleController>(
            builder: (cnx, value, ch){
              WidgetsBinding.instance!.addPostFrameCallback((_){ setState(() { selectedLocale = value.locale; });});
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
                child: Transform.scale(
                    scale: 1,
                    child: child!
                ),
              );
            },
          );
        },

        home: const Splash()
      ),
    );
  }

  void getLocaleAndSize(FontSizeAndLocaleController fontSizeAndLocaleController) async{
    double? baseScale;
    int? currentSlide = 0;
    String? locale;

    try{

      baseScale = await storage.getDouble('base_scale');
      currentSlide = await storage.getInteger('current_scale');
      locale = await storage.getString('locale');

    }catch(error){
      if(!AppConfig.isPublished){ print(error); }
    }finally{

      if(locale != null){
        switch(locale){
          case 'en':
            fontSizeAndLocaleController.setLocale(const Locale('en', 'US'));
            break;
          case 'fr':
            fontSizeAndLocaleController.setLocale(const Locale('fr', 'FR'));
            break;
        }
      }

      if(baseScale != fontSizeAndLocaleController.baseTextScaleFactor){
        fontSizeAndLocaleController.reset();
      }else{
        if(currentSlide != null){

          switch (currentSlide.toInt()){
            case 1:
              fontSizeAndLocaleController.set(-0.2);
              break;
            case 2:
              fontSizeAndLocaleController.set(-0.1);
              break;
            case 3:
              fontSizeAndLocaleController.reset();
              break;
            case 4:
              fontSizeAndLocaleController.set(0.1);
              break;
            case 5:
              fontSizeAndLocaleController.set(0.2);
              break;
          }
        }else{
          fontSizeAndLocaleController.reset();
        }
      }
    }
  }
}