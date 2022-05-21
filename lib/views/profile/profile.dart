import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/dialogs/loading_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/app_text_field.dart';
import 'package:sinam/helpers/avatar_view.dart';
import 'package:sinam/helpers/custom_app_bar.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/views/reset_pass/reset_pass.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final _formKey = GlobalKey<FormState>();
  bool submitSt = true;
  String? name, phoneNumber, email;
  late InitViewModel initViewModel;

  @override
  void initState() {
    super.initState();

    initViewModel = context.read<InitViewModel>();
    name = initViewModel.customerName ?? '';
    phoneNumber = (initViewModel.customerPhonePrefix ?? '') + ' ' + (initViewModel.customerNumber ?? '');
    email = initViewModel.customerEmail ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        appBar: AppBar(
          toolbarHeight: 0,
          toolbarOpacity: 0,
          backgroundColor: AppColors.gradiantBlueColor,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: profileBody(),
      ),
    );
  }

  Widget profileBody(){
    return Container(
      height: AppConfig.screenHeight,
      decoration: Helper.appBackgroundDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20.0),
            child: CustomAppBar(
              title: AppLocalizations.of(context)!.translate('profile'),
              submitSt: submitSt,
              innerDrawerKey: null,
              actionButton: AppConfig.offlineSt == false ? SizedBox( width: 45,
                child: TextButton(onPressed: () async{
                  await Future.delayed(const Duration(milliseconds: 250));
                  submitForm();
                }, child: Text(AppLocalizations.of(context)!.translate('save'), style: const TextStyle(fontSize: 12))),
              ) : Container(width: 35),
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(5)),
          Expanded(
            child: FadeInUp(
              from: 10,
              child: Stack(
                children: [
                  Positioned(
                    top: ScreenUtil().setHeight(50),
                    right: 0,
                    left: 0,
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(40), topLeft: Radius.circular(40)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Color(0xffb3e4ff),
                            Color(0xffffffff)
                          ],
                        ),
                      ),
                      child: profileForm(),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    child: Center(child: AvatarView(url: null, width: ScreenUtil().setWidth(110), height: ScreenUtil().setWidth(110)))
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget profileForm(){
    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        controller: ScrollController(),
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6.0, bottom: 5),
                  child: Text(AppLocalizations.of(context)!.translate('full_name')),
                ),
                AppTextField(
                  isEnable: AppConfig.offlineSt ? false : submitSt,
                  borderRadius: 10,
                  backgroundColor: Colors.white,
                  value: name,
                  borderColor: Colors.grey[400],
                  textInputType: TextInputType.text,
                  inputAction: TextInputAction.next,
                  labelText: AppLocalizations.of(context)!.translate('enter_your_full_name'),
                  suffixIcon: Container(width: 0),
                  onChanged: (value){ setState(() { name = value; });},
                  onValidate: (value){
                    if (value.isEmpty) {
                      return AppLocalizations.of(context)!.translate('full_name_empty_validate');
                    }

                    if (value.length < 3) {
                      return AppLocalizations.of(context)!.translate('full_name_len_empty_validate');
                    }
                    return null;
                  },
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 6.0, bottom: 5, top: 20),
                  child: Text(AppLocalizations.of(context)!.translate('phone_number')),
                ),
                AppTextField(
                  isEnable: false,
                  borderRadius: 10,
                  backgroundColor: Colors.white,
                  borderColor: Colors.grey[400],
                  textInputType: TextInputType.phone,
                  inputAction: TextInputAction.next,
                  labelText: AppLocalizations.of(context)!.translate('enter_your_phone_number'),
                  suffixIcon: Container(width: 0),
                  value: phoneNumber,
                  onChanged: (value){ setState(() { phoneNumber = value; });},
                  onValidate: (value){
                    if (value.isEmpty) {
                      return AppLocalizations.of(context)!.translate('phone_number_empty_validate');
                    }
                    if (!value.startsWith('0') && !value.startsWith('+')){
                      return AppLocalizations.of(context)!.translate('phone_validate');
                    }
                    if (value.length < 11) {
                      return AppLocalizations.of(context)!.translate('phone_number_len_validate');
                    }
                    return null;
                  },
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 6.0, bottom: 5, top: 20),
                  child: Text(AppLocalizations.of(context)!.translate('email')),
                ),
                AppTextField(
                  isEnable: false,
                  borderRadius: 10,
                  backgroundColor: Colors.white,
                  borderColor: Colors.grey[400],
                  textInputType: TextInputType.emailAddress,
                  inputAction: TextInputAction.done,
                  value: email,
                  labelText: AppLocalizations.of(context)!.translate('enter_your_email'),
                  suffixIcon: Container(width: 0),
                  onChanged: (value){ setState(() { email = value; });},
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
                ),
                const SizedBox(height: 15 ),
                Center(
                  child: TextButton(
                      onPressed: () async{
                        await Future.delayed(const Duration(milliseconds: 250));
                        if(!AppConfig.offlineSt){
                          AppNavigator.push(context: context, page: const ResetPass());
                        }else{
                          Message.show(context, AppLocalizations.of(context)!.translate('connection_error_description'));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
                        child: Text(AppLocalizations.of(context)!.translate('change_password'), style: TextStyle(
                            fontSize: 14, color: Colors.blue[700]
                        )),
                      )
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submitForm() async{
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {submitSt = false;});
      showDialog(context: context, builder: (context) => const LoadingDialog());
      try{
        dynamic result = await context.read<InitViewModel>().updateProfile(context, postData: {
          'api_key': AppConfig.apiKey,
          'customer_id': initViewModel.customerID,
          'name': name,
          'given_name': name
        });
        Navigator.pop(context);
        setState(() { submitSt = true;});
        if(result is Map<String, dynamic>){
          initViewModel.setCustomerName(name);
          Message.show(context, result['message']);
          await Future.delayed(const Duration(seconds: 4));
          Navigator.pop(context);
        }else{
          Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
        }
      }catch(error){
        if(!AppConfig.isPublished){print('error $error');}
        setState(() { submitSt = true;});
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