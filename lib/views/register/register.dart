import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/dialogs/loading_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/app_text_field.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/models/city_model.dart';
import 'package:sinam/models/currency_model.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/views/landing/landing.dart';
import 'package:sinam/views/totp_confirm/totp_confirm.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final _formKey = GlobalKey<FormState>();
  String? name, email, phone, password, rePassword;
  bool submitSt = true;
  String? selectedCountryCode;
  late String selectedLanguage;

  Map<String, String> sexList = {
    'M': 'Male',
    'F': 'Female',
  };
  String? selectedSex;

  List<CityModel> cityList = [];
  String? selectedCity;

  List<CurrencyModel> currencyList = [];
  String? selectedCurrency;

  @override
  void initState() {
    super.initState();
    selectedCountryCode = context.read<InitViewModel>().initModel!.countryPrefix;
    List<CityModel> lst = context.read<InitViewModel>().cities ?? [];
    currencyList = context.read<InitViewModel>().currencies ?? [];

    // remove duplicates from city list;
    final jsonList = lst.map((item) => jsonEncode(item)).toList();
    final uniqueJsonList = jsonList.toSet().toList();
    final uniqueResult = uniqueJsonList.map((item) => jsonDecode(item)).toList();

    for (var element in uniqueResult) {
      cityList.add(CityModel(
        name: jsonDecode(element)['name']
      ));
    }}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedLanguage = AppLocalizations.of(context)!.locale.toString().split('_')[0];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AppNavigator.pushReplace(context: context, page: const Landing());
        return false;
      },
      child: FocusWatcher(
        child: Scaffold(
          backgroundColor: AppColors.primaryColor,
          appBar: AppBar(
            toolbarHeight: 0,
            toolbarOpacity: 0,
            backgroundColor: AppColors.gradiantBlueColor,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          body: registerBody(),
        ),
      ),
    );
  }

  Widget registerBody(){
    return Container(
      height: AppConfig.screenHeight,
      decoration: Helper.appBackgroundDecoration(),
      child: Stack(
        children: [
          Positioned(left: 15, top: 15, child: SizedBox(width: 50, height: 50, child: TextButton(
              onPressed: () async{
                await Future.delayed(const Duration(milliseconds: 250));
                if(submitSt){ AppNavigator.pushReplace(context: context, page: const Landing()); }
              },
              child: FadeInLeft(from: 10, child: const Icon(Icons.keyboard_arrow_left, size: 35, color: Colors.white,)))
          )),
          Align(alignment: Alignment.topCenter, child: topLogo()),
          Align(alignment: Alignment.topCenter, child: FadeIn(child: Container(margin: EdgeInsets.only(top: ScreenUtil().setHeight(80)), child: Image.asset('assets/images/slogo.png' ,width: ScreenUtil().setWidth(50))))),
          Align(alignment: Alignment.topCenter, child: Container(margin: EdgeInsets.only(top: ScreenUtil().setHeight(150)), child: registerContainer())),
        ],
      ),
    );
  }

  Widget topLogo(){
    return FadeInDown(
      from: 30,
      child: Container(
          width: ScreenUtil().setWidth(180),
          height: ScreenUtil().setHeight(90),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15.0), vertical: ScreenUtil().setHeight(10)),
            child: Align(alignment: Alignment.center, child: Text(AppLocalizations.of(context)!.translate('register'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey[700]),)),
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30)
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xfff8fdff),
                Color(0xffc0e8fd),
              ],
            ),
          )
      ),
    );
  }

  Widget registerContainer(){
    return FadeInUp(
      from: 30,
      child: FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          controller: ScrollController(),
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(18.0), vertical: ScreenUtil().setHeight(20)),
              width: double.maxFinite,
              //height: screenHeight/1.43,
              constraints: BoxConstraints(minHeight: AppConfig.screenHeight/2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!.translate('full_name'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                          const SizedBox(width: 4),
                          const Text('*', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                        ],
                      ),
                    ),
                    AppTextField(
                      isEnable: submitSt,
                      borderRadius: 10,
                      borderColor: Colors.grey[300],
                      labelText: AppLocalizations.of(context)!.translate('enter_your_full_name'),
                      textInputType: TextInputType.text,
                      onValidate: (value){
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)!.translate('full_name_empty_validate');
                        }

                        if(value.length < 3){
                          return AppLocalizations.of(context)!.translate('full_name_len_empty_validate');
                        }
                        return null;
                      },
                      onChanged: (value){ name = value; },
                      suffixIcon: Container(
                        width: 40, height: 40,
                        child: const Icon(Icons.person, color: Colors.white, size: 23),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: AppColors.accentColor),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!.translate('phone_number'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                          const SizedBox(width: 4),
                          const Text('*', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                        ],
                      ),
                    ),
                    AppTextField(
                      isEnable: submitSt,
                      borderRadius: 10,
                      borderColor: Colors.grey[300],
                      labelText: AppLocalizations.of(context)!.translate('enter_your_phone_number'),
                      textInputType: TextInputType.phone,
                      onValidate: (value){
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)!.translate('phone_number_empty_validate');
                        }
                        if(!Helper.isNumeric(value)){
                          return AppLocalizations.of(context)!.translate('phone_validate');
                        }
                        if (value.length < 7) {
                          return AppLocalizations.of(context)!.translate('phone_validate');
                        }
                        return null;
                      },
                      onChanged: (value){ phone = value; },
                      prefixIcon: CountryCodePicker(
                        onChanged: (countryCode) => setState(() {selectedCountryCode = countryCode.code;}),
                        initialSelection: selectedCountryCode,
                        favorite: const ['+228','+33'],
                        flagWidth: 25,
                        showCountryOnly: true,
                        alignLeft: false,
                        dialogSize: Size(AppConfig.screenWidth - 60, AppConfig.screenHeight - 290)
                      ),
                      suffixIcon: Container(
                        width: 40, height: 40,
                        child: const Icon(Icons.phone_android_rounded, color: Colors.white, size: 23),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: AppColors.accentColor),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!.translate('email'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                          const SizedBox(width: 4),
                          const Text('*', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                        ],
                      ),
                    ),
                    AppTextField(
                      isEnable: submitSt,
                      borderRadius: 10,
                      borderColor: Colors.grey[300],
                      labelText: AppLocalizations.of(context)!.translate('enter_your_email'),
                      textInputType: TextInputType.emailAddress,
                      onValidate: (value){
                        Pattern pattern = '[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}';
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)!.translate('email_empty_validate');
                        }
                        if (value.length < 3) {
                          return AppLocalizations.of(context)!.translate('email_len_validate');
                        }
                        if (!RegExp(pattern.toString()).hasMatch(value)){
                          return AppLocalizations.of(context)!.translate('email_validate');
                        }
                        return null;
                      },
                      onChanged: (value){ email = value; },
                      suffixIcon: Container(
                        width: 40, height: 40,
                        child: const Icon(Icons.email_rounded, color: Colors.white, size: 23),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: AppColors.accentColor),
                      ),
                    ),
                    const SizedBox(height: 15),
                    sexSelectView(),
                    const SizedBox(height: 15),
                    citySelectView(),
                    const SizedBox(height: 15),
                    currencySelectView(),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!.translate('password'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                          const SizedBox(width: 4),
                          const Text('*', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                        ],
                      ),
                    ),
                    AppTextField(
                      isEnable: submitSt,
                      borderRadius: 10,
                      borderColor: Colors.grey[300],
                      labelText: AppLocalizations.of(context)!.translate('enter_your_password'),
                      toggleVisibleSt: true,
                      isPassword: true,
                      inputAction: TextInputAction.next,
                      onValidate: (value){
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)!.translate('password_empty_validate');
                        }
                        if (value.length < 6) {
                          return AppLocalizations.of(context)!.translate('password_len_validate');
                        }
                        return null;
                      },
                      onChanged: (value){ password = value; },
                      suffixIcon: Container(
                        width: 40, height: 40,
                        child: const Icon(Icons.lock_rounded, color: Colors.white, size: 23),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: AppColors.accentColor),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!.translate('password_repeat'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                          const SizedBox(width: 4),
                          const Text('*', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                        ],
                      ),
                    ),
                    AppTextField(
                      isEnable: submitSt,
                      borderRadius: 10,
                      borderColor: Colors.grey[300],
                      labelText: AppLocalizations.of(context)!.translate('enter_your_password'),
                      toggleVisibleSt: true,
                      isPassword: true,
                      inputAction: TextInputAction.done,
                      onValidate: (value){
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)!.translate('password_repeat_empty_validate');
                        }
                        if (value.length < 6) {
                          return AppLocalizations.of(context)!.translate('password_repeat_len_validate');
                        }
                        if(value != password){
                          return AppLocalizations.of(context)!.translate('password_repeat_validate');
                        }
                        return null;
                      },
                      onFieldSubmitted: (value){ rePassword = value; submitForm(); },
                      onChanged: (value){ rePassword = value; },
                      suffixIcon: Container(
                        width: 40, height: 40,
                        child: const Icon(Icons.lock_rounded, color: Colors.white, size: 23),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: AppColors.accentColor),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: GradiantButton(
                          title: AppLocalizations.of(context)!.translate('register'),
                          radius: 40,
                          width: MediaQuery.of(context).size.width - 150,
                          onPressed: () async{
                            await Future.delayed(const Duration(milliseconds: 250));
                            if(submitSt){ submitForm();}
                          }
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              )
          ),
        ),
      ),
    );
  }

  Widget sexSelectView(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(AppLocalizations.of(context)!.translate('gender'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ),
        const SizedBox(height: 5),
        Focus(
          descendantsAreFocusable: false,
          child: Container(
            margin: const EdgeInsets.all(2),
            child: DropdownButtonFormField(
              style: const TextStyle(fontSize: 17, color: Colors.grey),
              isExpanded: true,
              iconEnabledColor: Colors.grey[600],
              decoration: Helper.registerDropDownInputDecoration(
                suffixIcon: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  width: 40, height: 40,
                  child: const Icon(Icons.male_rounded, color: Colors.white, size: 23),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: AppColors.accentColor),
                )
              ),
              items: sexList.map((String key, String value) {
                return MapEntry(value, DropdownMenuItem<String>(
                  value: key,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text(value, style: const TextStyle(color: Colors.black)),
                  ),
                ));
              }).values.toList(),
              dropdownColor: Colors.grey[200],
              hint: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(AppLocalizations.of(context)!.translate('select_your_gender'), style: TextStyle(color: Colors.grey[500], fontSize: 15)),
              ),
              onChanged: submitSt ? (value) => setState(() { selectedSex = value.toString(); FocusManager.instance.primaryFocus!.unfocus(); } ) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget citySelectView(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(AppLocalizations.of(context)!.translate('city'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ),
        const SizedBox(height: 5),
        Focus(
          descendantsAreFocusable: false,
          child: Container(
            margin: const EdgeInsets.all(2),
            child: DropdownButtonFormField(
              style: const TextStyle(fontSize: 17, color: Colors.grey),
              iconEnabledColor: Colors.grey[600],
              decoration: Helper.registerDropDownInputDecoration(
                suffixIcon: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  width: 40, height: 40,
                  child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 23),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: AppColors.accentColor),
                )
              ),
              isExpanded: true,
              items: cityList.map((CityModel model) => DropdownMenuItem<String>(
                value: model.name.toString(),
                child: Text(model.name, style: TextStyle(color: Colors.grey[700], fontSize: 14, overflow: TextOverflow.fade))
              )).toSet().toList(),
              dropdownColor: Colors.grey[200],
              hint: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(AppLocalizations.of(context)!.translate('select_your_city'), style: TextStyle(color: Colors.grey[500], fontSize: 15)),
              ),
              onChanged: submitSt ? (value) => setState(() { selectedCity = value.toString(); FocusManager.instance.primaryFocus!.unfocus(); } ) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget currencySelectView(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Row(
            children: [
              Text(AppLocalizations.of(context)!.translate('currency'), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Focus(
          descendantsAreFocusable: false,
          child: Container(
            margin: const EdgeInsets.all(2),
            child: DropdownButtonFormField(
              isExpanded: true,
              style: const TextStyle(fontSize: 17, color: Colors.grey),
              iconEnabledColor: Colors.grey[600],
              decoration: Helper.registerDropDownInputDecoration(
                suffixIcon: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  width: 40, height: 40,
                  child: const Icon(Icons.money, color: Colors.white, size: 23),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: AppColors.accentColor),
                )
              ),
              items: currencyList.map((CurrencyModel model) => DropdownMenuItem<String>(
                value: model.currencyCode,
                child: Text(model.currencyCode, style: TextStyle(color: Colors.grey[700], fontSize: 14))
              )).toList(),
              dropdownColor: Colors.grey[200],
              hint: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(AppLocalizations.of(context)!.translate('select_your_currency'), style: TextStyle(color: Colors.grey[500], fontSize: 15)),
              ),
              onChanged: submitSt ? (value) => setState(() { selectedCurrency = value.toString(); FocusManager.instance.primaryFocus!.unfocus(); } ) : null,
              validator: (value) {
                if (value == null) {
                  return AppLocalizations.of(context)!.translate('currency_empty_validate');
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  void submitForm() async{
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      showDialog(context: context, builder: (context) => const LoadingDialog());
      try{
        dynamic result = await Provider.of<InitViewModel>(context, listen: false).registration(context,
          name: name!.trim(),
          city: selectedCity,
          sexCode: selectedSex,
          email: email!.trim(),
          phone: phone!.trim(),
          password: password!.trim(),
          prefix: selectedCountryCode!,
          currencyCode: selectedCurrency,
          language: selectedLanguage
        );
        if(result is Map<String, dynamic>){
          Navigator.pop(context);
          AppNavigator.push(context: context, page: TotpConfirm(data: result));
        }else{
          setState(() {submitSt = true;});
          Navigator.pop(context);
          Message.show(context, result.toString());
        }
      }catch(error){
        if(!AppConfig.isPublished){print('$error');}
        if(error == 'connection_error_description'){
          String? connectionError;
          if(AppConfig.selectedLanguage == 'en'){
            if(AppConfig.connectionErrorEn != null){
              connectionError = AppConfig.connectionErrorEn;
            }
          }else{
            if(AppConfig.connectionErrorFr != null){
              connectionError = AppConfig.connectionErrorFr;
            }
          }
          Message.show(context, AppLocalizations.of(context)!.translate(connectionError ?? error.toString()));
        }else{
          Message.show(context, AppLocalizations.of(context)!.translate(error.toString()));
        }
      }
    }
  }
}
