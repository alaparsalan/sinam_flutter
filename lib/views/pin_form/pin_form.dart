import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/database/storage.dart';
import 'package:sinam/dialogs/loading_dialog.dart';
import 'package:sinam/dialogs/message_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/app_text_field.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/view_models/wallet_view_model.dart';
import 'package:sinam/views/welcome/welcome.dart';

class PinForm extends StatefulWidget {
  final bool? isUpdate;
  final bool? isOptional;
  final bool? backSt;
  final String? from;
  final Function()? onFinish;

  const PinForm(
      {Key? key,
      this.isUpdate,
      this.isOptional,
      this.backSt,
      this.from,
      this.onFinish})
      : super(key: key);

  @override
  _PinFormState createState() => _PinFormState();
}

class _PinFormState extends State<PinForm> {
  final Storage storage = Storage();
  final _formKey = GlobalKey<FormState>();
  String? pin, pinRepeat, oldPin;
  bool submitSt = true;
  late InitViewModel initViewModel;

  @override
  void initState() {
    super.initState();
    initViewModel = context.read<InitViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.backSt != null && widget.backSt! == true) {
          Navigator.pop(context);
        }
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
          body: pinFormBody(),
        ),
      ),
    );
  }

  Widget pinFormBody() {
    return Container(
      height: AppConfig.screenHeight,
      decoration: Helper.appBackgroundDecoration(),
      child: Stack(
        children: [
          if (widget.backSt != null && widget.backSt! == true)
            Positioned(
                left: 15,
                top: 15,
                child: SizedBox(
                    width: 50,
                    height: 50,
                    child: TextButton(
                        onPressed: () async {
                          await Future.delayed(
                              const Duration(milliseconds: 250));
                          Navigator.pop(context);
                        },
                        child: FadeInLeft(
                            from: 10,
                            child: const Icon(
                              Icons.keyboard_arrow_left,
                              size: 35,
                              color: Colors.white,
                            ))))),
          Align(alignment: Alignment.topCenter, child: topLogo()),
          Align(
              alignment: Alignment.topCenter,
              child: FadeIn(
                  child: Container(
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(120)),
                      child: Image.asset('assets/images/slogo.png',
                          width: ScreenUtil().setWidth(70))))),
          Align(
              alignment: Alignment.topCenter,
              child: Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(220)),
                  child: pinContainer())),
        ],
      ),
    );
  }

  Widget topLogo() {
    return FadeInDown(
      from: 30,
      child: Container(
          width: ScreenUtil().setWidth(180),
          height: ScreenUtil().setHeight(130),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: Align(
                alignment: Alignment.center,
                child: Text(
                    AppLocalizations.of(context)!.translate(
                        widget.isUpdate != null && widget.isUpdate! == true
                            ? 'update_wallet_pin'
                            : 'create_wallet_pin'),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey[700]),
                    textAlign: TextAlign.center)),
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xfff8fdff),
                Color(0xffc0e8fd),
              ],
            ),
          )),
    );
  }

  Widget pinContainer() {
    return FadeInUp(
      from: 30,
      child: FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          controller: ScrollController(),
          child: Container(
              margin:
                  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(18.0),
                  vertical: ScreenUtil().setHeight(20)),
              width: double.maxFinite,
              height: ScreenUtil().setHeight(570),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isUpdate != null && widget.isUpdate! == true)
                      Column(
                        children: [
                          AppTextField(
                            isEnable: submitSt,
                            borderRadius: 10,
                            toggleVisibleSt: true,
                            isPassword: true,
                            borderColor: Colors.grey[300],
                            labelText: AppLocalizations.of(context)!
                                .translate('old_wallet_pin'),
                            textInputType: TextInputType.number,
                            onValidate: (value) {
                              if (value.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .translate('old_pin_empty_validate');
                              }
                              return null;
                            },
                            onChanged: (value) {
                              oldPin = value;
                            },
                            suffixIcon: Container(
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.lock_rounded,
                                  color: Colors.white, size: 23),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  color: AppColors.accentColor),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    AppTextField(
                      isEnable: submitSt,
                      borderRadius: 10,
                      toggleVisibleSt: true,
                      isPassword: true,
                      borderColor: Colors.grey[300],
                      labelText:
                          AppLocalizations.of(context)!.translate('wallet_pin'),
                      textInputType: TextInputType.number,
                      onValidate: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('pin_empty_validate');
                        }
                        return null;
                      },
                      onChanged: (value) {
                        pin = value;
                      },
                      suffixIcon: Container(
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.lock_rounded,
                            color: Colors.white, size: 23),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            color: AppColors.accentColor),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      isEnable: submitSt,
                      borderRadius: 10,
                      toggleVisibleSt: true,
                      isPassword: true,
                      borderColor: Colors.grey[300],
                      labelText: AppLocalizations.of(context)!
                          .translate('wallet_pin_repeat'),
                      textInputType: TextInputType.number,
                      onValidate: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('pin_repeat_empty_validate');
                        }

                        if (value != pin) {
                          return AppLocalizations.of(context)!
                              .translate('pin_repeat_validate');
                        }
                        return null;
                      },
                      onChanged: (value) {
                        pinRepeat = value;
                      },
                      suffixIcon: Container(
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.lock_rounded,
                            color: Colors.white, size: 23),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            color: AppColors.accentColor),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          GradiantButton(
                              title: AppLocalizations.of(context)!.translate(
                                  widget.isUpdate != null &&
                                          widget.isUpdate! == true
                                      ? 'update'
                                      : 'create'),
                              radius: 40,
                              width: MediaQuery.of(context).size.width - 150,
                              onPressed: () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 250));
                                if (submitSt) {
                                  submitForm();
                                }
                              }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if ((widget.isUpdate == null || widget.isUpdate == false) &&
                        widget.isOptional != null &&
                        widget.isOptional! == true)
                      Center(
                        child: TextButton(
                            onPressed: () async {
                              await Future.delayed(
                                  const Duration(milliseconds: 250));
                              if(widget.from == 'confirm'){
                              String? customerID =
                                  await storage.getString('customer_id');
                              if (customerID != null) {
                                if (widget.onFinish != null) {
                                  widget.onFinish!();
                                }
                                getData(customerID);
                              }
                              /*AppNavigator.pushReplace(
                                  context: context, page: const Welcome());*/
                              }else{
                                Navigator.pop(context);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 5.0),
                              child: Text(
                                  AppLocalizations.of(context)!
                                      .translate('skip_wallet_pin'),
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.blue[700])),
                            )),
                      )
                  ],
                ),
              )),
        ),
      ),
    );
  }

  void submitForm() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {
        submitSt = false;
      });
      showDialog(context: context, builder: (context) => const LoadingDialog());
      try {
        String? customerID = await storage.getString('customer_id');

        dynamic result;
        if (widget.isUpdate != null && widget.isUpdate! == true) {
          result = await Provider.of<WalletViewModel>(context, listen: false)
              .changeWalletPin(context,
                  customerID: customerID!,
                  oldPin: oldPin!.trim(),
                  newPin: pin!.trim());
        } else {
          result = await Provider.of<WalletViewModel>(context, listen: false)
              .createWalletPin(
            context,
            customerID: customerID!,
            pin: pin!.trim(),
          );
        }

        setState(() {
          submitSt = true;
        });
        Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 500));
        if (result is bool && result == false) {
          Message.show(
              context, AppLocalizations.of(context)!.translate('went_wrong'));
        } else {
          if (result is String) {
            Message.show(context, result);
          } else {
            if (result['message'] != null && result['message'] != '') {
              showDialog(
                  context: context,
                  builder: (context) =>
                      MessageDialog(title: result['message']));
              if (initViewModel.initModel != null) {
                initViewModel.initModel!.customerPinCreated = 1;
              }
              if (widget.onFinish != null) {
                widget.onFinish!();
              }
              getData(customerID);
            }
          }
        }
      } catch (error) {
        if (!AppConfig.isPublished) {
          print('$error');
        }
        setState(() {
          submitSt = true;
        });
        if (error == 'connection_error_description') {
          String? connectionError;
          if (AppConfig.selectedLanguage == 'en') {
            if (AppConfig.connectionErrorEn != null) {
              connectionError = AppConfig.connectionErrorEn;
            }
          } else {
            if (AppConfig.connectionErrorFr != null) {
              connectionError = AppConfig.connectionErrorFr;
            }
          }
          Message.show(
              context,
              AppLocalizations.of(context)!
                  .translate(connectionError ?? error.toString()));
        } else {
          Message.show(context, error.toString());
        }
      }
    }
  }

  Future<void> getData(String customerID) async {
    try {
      await Provider.of<InitViewModel>(context, listen: false)
          .getInit(context, customerID);
      await Provider.of<InitViewModel>(context, listen: false)
          .getDictionary(context, customerID);
      await Future.delayed(const Duration(milliseconds: 250));
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 250));
      if (widget.onFinish != null) {
        widget.onFinish!();
      }
      if (widget.from == 'confirm') {
        AppNavigator.pushReplace(context: context, page: const Welcome());
      } else {
        Navigator.pop(context);
      }
    } catch (error) {
      if (!AppConfig.isPublished) {
        print('$error');
      }
      setState(() {
        submitSt = true;
      });
      Navigator.pop(context);
      if (error == 'connection_error_description') {
        String? connectionError;
        if (AppConfig.selectedLanguage == 'en') {
          if (AppConfig.connectionErrorEn != null) {
            connectionError = AppConfig.connectionErrorEn;
          }
        } else {
          if (AppConfig.connectionErrorFr != null) {
            connectionError = AppConfig.connectionErrorFr;
          }
        }
        Message.show(
            context,
            AppLocalizations.of(context)!
                .translate(connectionError ?? error.toString()));
      } else {
        Message.show(
            context, AppLocalizations.of(context)!.translate(error.toString()));
      }
    }
  }
}
