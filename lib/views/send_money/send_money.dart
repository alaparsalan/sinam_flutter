import 'package:animate_do/animate_do.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:sinam/config/app_colors.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/dialogs/fail_dialog.dart';
import 'package:sinam/dialogs/loading_dialog.dart';
import 'package:sinam/dialogs/message_dialog.dart';
import 'package:sinam/dialogs/send_money_dialog.dart';
import 'package:sinam/dialogs/success_dialog.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_navigator.dart';
import 'package:sinam/helpers/app_text_field.dart';
import 'package:sinam/helpers/custom_app_bar.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/helper.dart';
import 'package:sinam/helpers/menu.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/helpers/recent_item.dart';
import 'package:sinam/models/destination_country_model.dart';
import 'package:sinam/models/dictionary_model.dart';
import 'package:sinam/models/init_model.dart';
import 'package:sinam/models/operator_model.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:sinam/views/help/help.dart';
import 'package:sinam/views/history/history.dart';
import 'package:sinam/views/recharge/recharge.dart';
import 'package:sinam/views/wallet_refill/wallet_refill.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class SendMoney extends StatefulWidget {
  const SendMoney({Key? key}) : super(key: key);

  @override
  _SendMoneyState createState() => _SendMoneyState();
}

class _SendMoneyState extends State<SendMoney> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();
  PhoneContact? phoneContact;
  bool submitSt = true;
  bool? termsSt = true;
  String? selectedCountryCode;
  String? selectedPhonePrefix;
  String? phoneNumber, name, amount;
  List<String> availableCountries = [];
  List<String> favoriteCountries = [];
  List<Widget> recentList = [];
  DictionaryModel? dictionaryModel;
  InitModel? initModel;
  int phoneLength = 7;
  bool localRestrict = false;

  Map<int, String> operatorList = {};
  int? selectedOperatorList;

  List<String> transferReasonsList = [];
  String? selectedReason;

  TextEditingController phoneNumberController = TextEditingController();

  bool fromContact = false;

  @override
  void initState() {
    super.initState();
    selectedCountryCode =
        (context.read<InitViewModel>().initModel!.countryPrefix);

    dictionaryModel = context.read<InitViewModel>().dictionaryModel;
    initModel = context.read<InitViewModel>().initModel;

    if (initModel!.internationalEnabled == 0) {
      localRestrict = true;
    }

    initModel!.nationalEnabled = 1;

    if (dictionaryModel != null) {
      if (dictionaryModel!.destinationCountries != null &&
          dictionaryModel!.destinationCountries!.isNotEmpty) {
        for (var element in dictionaryModel!.destinationCountries!) {
          availableCountries.add(element.phonePrefix);
          if (element.phonePrefix == '+228' || element.phonePrefix == '+33') {
            favoriteCountries.add(element.phonePrefix);
          }
        }
        if (initModel!.nationalEnabled != null &&
            initModel!.nationalEnabled == 1 &&
            initModel!.countryPrefix != null) {
          selectedCountryCode = initModel!.customerCountryCode;
          selectedPhonePrefix = initModel!.customerPhonePrefix;
        } else {
          selectedCountryCode =
              dictionaryModel!.destinationCountries![0].countryCode;
          selectedPhonePrefix =
              dictionaryModel!.destinationCountries![0].phonePrefix;
        }
      }
      loadOperators();
      loadReasons();
    }

    if (initModel != null) {
      loadRecent();
      checkInternationalMoneyTransfer();
    }
  }

  void loadOperators({int? operatorCode}) {
    operatorList.clear();
    selectedOperatorList = null;
    if (dictionaryModel!.operators != null &&
        dictionaryModel!.operators!.isNotEmpty) {
      for (var element in dictionaryModel!.operators!) {
        if (initModel!.nationalEnabled != null &&
            initModel!.nationalEnabled == 0) {
          if (element.countryCode == selectedCountryCode &&
              (initModel!.globalSim1Name == element.simName ||
                  initModel!.globalSim1Name == element.simName)) {
            operatorList[element.operatorCode] = element.sendMoneyName;
          }
        } else {
          if (element.countryCode == selectedCountryCode) {
            operatorList[element.operatorCode] = element.sendMoneyName;
          }
        }
      }
      if (operatorList.isNotEmpty) {
        if (operatorCode != null) {
          selectedOperatorList = operatorCode;
        } else {
          selectedOperatorList = operatorList.entries.first.key;
        }
      }
      setState(() {});
    }
    checkInternationalMoneyTransfer();
  }

  void loadRecent() {
    if (initModel!.savedNumbers != null &&
        initModel!.savedNumbers!.isNotEmpty) {
      for (var element in initModel!.savedNumbers!) {
        recentList.add(GestureDetector(
          onTap: () async {
            if (availableCountries.contains(element.countryCode)) {
              setState(() {
                phoneContact = null;
                selectedPhonePrefix = element.countryCode;
                if (dictionaryModel!.destinationCountries != null &&
                    dictionaryModel!.destinationCountries!.isNotEmpty) {
                  for (var cc in dictionaryModel!.destinationCountries!) {
                    if (cc.phonePrefix == element.countryCode) {
                      selectedCountryCode = cc.countryCode;
                    }
                  }
                }
                selectedPhonePrefix = element.countryCode;
                phoneNumberController.text = element.recipientNumber;
                phoneNumber = element.recipientNumber;
              });
              getValidPhoneLength();
              loadOperators(
                operatorCode: element.operatorCode,
              );
            } else {
              Message.show(context, 'selected_number_not_supported');
              setState(() {
                phoneNumber = null;
                phoneNumberController.text = '';
              });
            }
          },
          child: RecentItem(
              number: element,
              avatar: dictionaryModel!.operators!
                  .where((e) => e.operatorCode == element.operatorCode)
                  .first
                  .sendMoneyFlag),
        ));
      }
    }
  }

  void getValidPhoneLength() {
    if (dictionaryModel!.destinationCountries != null &&
        dictionaryModel!.destinationCountries!.isNotEmpty) {
      for (var element in dictionaryModel!.destinationCountries!) {
        if (element.phonePrefix == selectedPhonePrefix) {
          setState(() {
            phoneLength = element.phoneLength;
          });
        }
      }
    }
  }

  void loadReasons() {
    transferReasonsList.clear();
    if (dictionaryModel!.transferReasons != null &&
        dictionaryModel!.transferReasons!.isNotEmpty) {
      for (var element in dictionaryModel!.transferReasons!) {
        transferReasonsList.add(AppConfig.selectedLanguage == 'en'
            ? element.transferReasonEn
            : element.transferReasonFr);
      }
    }
  }

  void checkInternationalMoneyTransfer() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (initModel!.customerVerified == 0) {
      if (selectedPhonePrefix != initModel!.customerPhonePrefix &&
          initModel!.notificationMessage != null) {
        showDialog(
            context: context,
            builder: (cntx) => MessageDialog(
                title:
                    AppLocalizations.of(context)!.translate('verify_message'),
                onDonePressed: () async {
                  await Future.delayed(const Duration(milliseconds: 800));
                  openURL(initModel!.profileUpdateUrl);
                }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setSideMenu();
    return FocusWatcher(
      child: InnerDrawer(
        key: _innerDrawerKey,
        onTapClose: true,
        swipe: true,
        colorTransitionScaffold: Colors.transparent,
        offset: const IDOffset.only(bottom: 0.0, right: 0.5, left: 0.0),
        borderRadius: 30,
        rightAnimationType: InnerDrawerAnimation.quadratic,
        backgroundDecoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xff0957c5),
              Color(0xff359cd9),
            ],
          ),
        ),
        // default  Theme.of(context).backgroundColor
        rightChild: menuInit(),
        scaffold: Scaffold(
          backgroundColor: AppColors.primaryColor,
          appBar: AppBar(
            toolbarHeight: 0,
            toolbarOpacity: 0,
            backgroundColor: AppColors.gradiantBlueColor,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          body: sendMoneyBody(),
        ),
      ),
    );
  }

  Widget sendMoneyBody() {
    return Container(
      height: AppConfig.screenHeight,
      decoration: Helper.appBackgroundDecoration(),
      child: Padding(
        //padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20.0),
        padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(20.0),
            bottom: ScreenUtil().setHeight(10.0),
            right: ScreenUtil().setWidth(15.0),
            left: ScreenUtil().setWidth(15.0)),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomAppBar(
                title: AppLocalizations.of(context)!.translate('send_money'),
                submitSt: submitSt,
                innerDrawerKey: _innerDrawerKey,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FadeInUp(
                  from: 10,
                  child: FadingEdgeScrollView.fromSingleChildScrollView(
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          phoneNumberView(),
                          recentView(),
                          amountView(),
                          termsView(),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Builder(builder: (context) {
                bool valid = true;
                if (phoneNumberController.text.trim().isEmpty) {
                  valid = false;
                }
                if (selectedOperatorList == null) {
                  valid = false;
                }
                if (selectedReason == null) {
                  valid = false;
                }
                if (amount == null || amount!.trim().isEmpty) {
                  valid = false;
                }
                DestinationCountryModel? destination = dictionaryModel!
                    .destinationCountries
                    ?.where(
                        (element) => element.countryCode == selectedCountryCode)
                    .toList()[0];
                if (double.parse(amount == '' ? '0.0' : amount ?? '0.0') >
                        getExchangedAmount(
                            destination!, destination.minAmount.toDouble()) &&
                    double.parse(amount == '' ? '0.0' : amount ?? '0.0') <
                        getExchangedAmount(
                            destination, destination.maxAmount.toDouble())) {
                } else {
                  valid = false;
                }
                return FadeInUp(
                  from: 10,
                  child: GradiantButton(
                      title: AppLocalizations.of(context)!.translate('send'),
                      radius: 40,
                      startColor:
                          valid ? null : Colors.black54.withOpacity(0.3),
                      endColor: valid ? null : Colors.black54.withOpacity(0.3),
                      width: ScreenUtil().setWidth(230),
                      onPressed: () async {
                        await Future.delayed(const Duration(milliseconds: 250));
                        submitForm();
                      }),
                );
              }),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget phoneNumberView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xffcbf5ff),
            Color(0xffdefdff),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.translate('phone_number'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () async {
                  final PhoneContact contact =
                      await FlutterContactPicker.pickPhoneContact();
                  if (contact.phoneNumber != null) {
                    bool found = false;
                    if (dictionaryModel != null) {
                      if (dictionaryModel!.destinationCountries != null &&
                          dictionaryModel!.destinationCountries!.isNotEmpty) {
                        for (var element
                            in dictionaryModel!.destinationCountries!) {
                          if (contact.phoneNumber!.number!.startsWith('+')) {
                            if (contact.phoneNumber!.number!
                                .contains(element.phonePrefix)) {
                              setState(() {
                                found = true;
                                phoneContact = contact;
                                name = contact.fullName;
                                phoneNumber = contact.phoneNumber!.number!
                                    .replaceAll(element.phonePrefix, '')
                                    .replaceAll(' ', '');
                                phoneNumberController.text = phoneNumber!;
                                selectedPhonePrefix = element.phonePrefix;
                                selectedCountryCode = element.countryCode;
                              });
                              getValidPhoneLength();
                              loadOperators();
                            }
                          } else if (contact.phoneNumber!.number!
                              .startsWith('00')) {
                            if (contact.phoneNumber!.number!
                                .replaceFirst('00', '+')
                                .replaceAll(' ', '')
                                .contains(element.phonePrefix)) {
                              setState(() {
                                found = true;
                                phoneContact = contact;
                                name = contact.fullName;
                                phoneNumber = contact.phoneNumber!.number!
                                    .replaceFirst('00', '+')
                                    .replaceAll(' ', '')
                                    .replaceAll(element.phonePrefix, '');
                                phoneNumberController.text = phoneNumber!;
                                selectedPhonePrefix = element.phonePrefix;
                                selectedCountryCode = element.countryCode;
                              });
                              getValidPhoneLength();
                              loadOperators();
                            }
                          } else if (contact.phoneNumber!.number![0] == '0' &&
                              contact.phoneNumber!.number![1] != '0') {
                            setState(() {
                              found = true;
                              phoneContact = contact;
                              name = contact.fullName;
                              phoneNumber = contact.phoneNumber!.number!
                                  .replaceFirst('0', '')
                                  .replaceAll(' ', '');
                              phoneNumberController.text = phoneNumber!;
                              selectedPhonePrefix = element.phonePrefix;
                              selectedCountryCode = element.countryCode;
                            });
                            getValidPhoneLength();
                            loadOperators();
                          }
                        }
                        if (!found) {
                          setState(() {
                            phoneContact = contact;
                            name = contact.fullName;
                            phoneNumber = contact.phoneNumber!.number!
                                .replaceAll(' ', '');
                            phoneNumberController.text = phoneNumber!;
                          });
                          /*setState(() {
                            phoneContact = null;
                            name = null;
                            phoneNumber = null;
                            phoneNumberController.text = '';
                          });
                          Message.show(context, AppLocalizations.of(context)!.translate('selected_number_not_supported'));*/
                        } else {
                          fromContact = true;
                        }
                      } else {
                        Message.show(
                            context,
                            AppLocalizations.of(context)!
                                .translate('receive_error'));
                      }
                    } else {
                      Message.show(
                          context,
                          AppLocalizations.of(context)!
                              .translate('receive_error'));
                    }
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.translate('contacts'),
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          Row(
            children: [
              //if(phoneContact == null)
              Row(
                children: [
                  Container(
                    height: 52,
                    margin: const EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey[500]!))),
                    child: CountryCodePicker(
                        onChanged: (countryCode) {
                          setState(() {
                            selectedCountryCode = countryCode.code;
                            selectedPhonePrefix = countryCode.dialCode!;
                          });
                          loadOperators();
                        },
                        initialSelection: selectedCountryCode,
                        favorite: favoriteCountries,
                        countryFilter: localRestrict
                            ? [initModel!.countryPrefix!]
                            : availableCountries,
                        showCountryOnly: true,
                        alignLeft: false,
                        dialogSize: Size(AppConfig.screenWidth - 60,
                            AppConfig.screenHeight - 290)),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
              Expanded(
                  child: TextFormField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      phoneContact = null;
                      name = null;
                    });
                  } else {
                    setState(() {
                      phoneNumber = value;
                    });
                  }
                  if(fromContact) {
                    fromContact = false;
                  }
                },
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  hintText: '2654822145',
                ),
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context)!
                        .translate('phone_number_empty_validate');
                  }
                  if (!Helper.isNumeric(value)) {
                    return AppLocalizations.of(context)!
                        .translate('phone_validate');
                  }
                  if (value.length < 7) {
                    return AppLocalizations.of(context)!
                        .translate('phone_validate');
                  }
                  print(value.substring(0, 2));
                  print(dictionaryModel!.operatorsPrefix!.where((element) => element.operatorCode == selectedOperatorList).map((e) => e.phonePrefix).toList());
                  if((!fromContact) && !(dictionaryModel!.operatorsPrefix!.where((element) => element.operatorCode == selectedOperatorList).map((e) => e.phonePrefix).toList().contains(value.substring(0, 2)))) {
                    return AppLocalizations.of(context)!
                        .translate('phone_validate');
                  }

                  return null;
                },
              )),
            ],
          ),
          const SizedBox(height: 15)
        ],
      ),
    );
  }

  Widget recentView() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xffdffdff),
            Color(0xfff0ffff),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.translate('recent'),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          recentList.isEmpty
              ? Text(AppLocalizations.of(context)!.translate('nothing_to_show'),
                  style: TextStyle(color: Colors.grey[500]))
              : FadingEdgeScrollView.fromSingleChildScrollView(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    controller: ScrollController(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: recentList,
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget amountView() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xfff8ffff),
            Color(0xffffffff),
          ],
        ),
      ),
      child: Column(
        children: [
          Focus(
            descendantsAreFocusable: false,
            child: DropdownButtonFormField(
              style: const TextStyle(fontSize: 17, color: Colors.grey),
              iconEnabledColor: Colors.grey[600],
              decoration: Helper.dropDownInputDecoration(),
              items: operatorList
                  .map((int index, String value) {
                    return MapEntry(
                        value,
                        DropdownMenuItem<String>(
                          value: index.toString(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3.0),
                            child: Row(
                              children: [
                                Image.network(
                                  dictionaryModel!.operators!
                                      .where((element) =>
                                          element.sendMoneyName == value)
                                      .first
                                      .sendMoneyFlag!,
                                  width: 40,
                                ),
                                const SizedBox(width: 8),
                                Text(value,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14)),
                              ],
                            ),
                          ),
                        ));
                  })
                  .values
                  .toList(),
              value: selectedOperatorList.toString(),
              dropdownColor: Colors.white,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(
                    AppLocalizations.of(context)!
                        .translate('select_your_operator'),
                    style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ),
              onChanged: submitSt
                  ? (value) => setState(() {
                        selectedOperatorList = int.parse(value.toString());
                        FocusManager.instance.primaryFocus!.unfocus();
                      })
                  : null,
              validator: (value) {
                if (value == null) {
                  return AppLocalizations.of(context)!
                      .translate('select_your_operator');
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 18),
          Focus(
            descendantsAreFocusable: false,
            child: DropdownButtonFormField(
              style: const TextStyle(fontSize: 17, color: Colors.grey),
              iconEnabledColor: Colors.grey[600],
              decoration: Helper.dropDownInputDecoration(),
              items: transferReasonsList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text(value,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14)),
                  ),
                );
              }).toList(),
              value: selectedReason,
              dropdownColor: Colors.grey[200],
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(
                    AppLocalizations.of(context)!
                        .translate('select_transfer_reason'),
                    style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ),
              onChanged: submitSt
                  ? (value) => setState(() {
                        selectedReason = value.toString();
                        FocusManager.instance.primaryFocus!.unfocus();
                      })
                  : null,
              validator: (value) {
                if (value == null) {
                  return AppLocalizations.of(context)!
                      .translate('select_transfer_reason');
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: 5.0,
                    bottom: (dictionaryModel != null &&
                            dictionaryModel!.destinationCountries != null)
                        ? 20
                        : 0),
                child: Text(
                    AppLocalizations.of(context)!.translate('amount') + ' :',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      labelText: '',
                      textInputFormatter: [
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            final text = newValue.text;
                            if (text.isNotEmpty) double.parse(text);
                            return newValue;
                          } catch (e) {}
                          return oldValue;
                        }),
                      ],
                      borderRadius: 10,
                      borderColor: Colors.grey[500],
                      textInputType: TextInputType.number,
                      inputAction: TextInputAction.done,
                      onChanged: (value) {
                        setState(() {
                          amount = value;
                        });
                      },
                      suffixIcon: Container(width: 0),
                      onValidate: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('amount_empty_validate');
                        }
                        return null;
                      },
                    ),
                    if (dictionaryModel != null &&
                        dictionaryModel!.destinationCountries != null)
                      Builder(builder: (context) {
                        DestinationCountryModel? destination = dictionaryModel!
                            .destinationCountries
                            ?.where((element) =>
                                element.countryCode == selectedCountryCode)
                            .toList()[0];
                        if (destination != null) {
                          return Text(
                              'You can send between ${getExchangedAmount(destination, destination.minAmount.toDouble()).toStringAsFixed(3)}${(initModel!.customerSelectedCurrencySymbol)} - ${getExchangedAmount(destination, destination.maxAmount.toDouble()).toStringAsFixed(3)}${initModel!.customerSelectedCurrencySymbol}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87.withOpacity(0.75),
                              ));
                        }
                        return const SizedBox();
                      }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double getExchangedAmount(
      DestinationCountryModel destination, double amount) {
    return initModel!.customerSelectedCurrencyCode == destination.localCurrency
        ? amount
        : (amount /
            (initModel!.currencyExchangeRate
                .where((element) =>
                    element.customerCurrency ==
                        initModel!.customerSelectedCurrencyCode &&
                    element.destinationCurrency == destination.localCurrency)
                .first
                .rate!));
  }

  Widget termsView() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: GestureDetector(
        onTap: () => setState(() {
          termsSt = termsSt != null ? !termsSt! : true;
        }),
        child: Row(
          children: [
            Checkbox(
                value: termsSt,
                onChanged: (value) => setState(() {
                      termsSt = value;
                    })),
            Text(AppLocalizations.of(context)!.translate('terms_agree'),
                style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 2),
            Expanded(
              child: GestureDetector(
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 250));
                    if (context.read<InitViewModel>().getTermsUrl != null) {
                      openURL(context.read<InitViewModel>().getTermsUrl!);
                    } else {
                      Message.show(
                          context,
                          AppLocalizations.of(context)!
                              .translate('went_wrong'));
                    }
                  },
                  child: Text(
                      AppLocalizations.of(context)!
                          .translate('terms_and_policies'),
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          overflow: TextOverflow.ellipsis),
                      maxLines: 1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget menuInit() {
    return Menu(goToPage: (page) async {
      switch (page) {
        case 'welcome':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          Navigator.pop(context);
          break;
        case 'recharge':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          AppNavigator.pushReplace(context: context, page: const Recharge());
          break;
        case 'send_money':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          break;
        case 'pay_bills':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          openURL(AppConfig.payBillsURL);
          break;
        case 'cash_power':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          openURL(AppConfig.cashPowerURL);
          break;
        case 'tv_renew':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          openURL(AppConfig.tvRenewURL);
          break;
        case 'wallet':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          AppNavigator.pushReplace(
              context: context, page: const WalletRefill());
          break;
        case 'history':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          AppNavigator.pushReplace(context: context, page: const History());
          break;
        case 'help':
          await Future.delayed(const Duration(milliseconds: 400));
          _innerDrawerKey.currentState!.close();
          await Future.delayed(const Duration(milliseconds: 400));
          AppNavigator.pushReplace(context: context, page: const Help());
          break;
      }
    });
  }

  void setSideMenu() {
    for (var element in AppConfig.sideMenu!) {
      if (element.id == 3) {
        element.active = true;
      } else {
        element.active = false;
      }
    }
  }

  void submitForm() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      DestinationCountryModel? destination = dictionaryModel!
          .destinationCountries
          ?.where((element) => element.countryCode == selectedCountryCode)
          .toList()[0];
      if (double.parse(amount == '' ? '0.0' : amount ?? '0.0') >
              getExchangedAmount(
                  destination!, destination.minAmount.toDouble()) &&
          double.parse(amount == '' ? '0.0' : amount ?? '0.0') <
              getExchangedAmount(
                  destination, destination.maxAmount.toDouble())) {
        if (termsSt != null && termsSt!) {
          if (initModel!.customerVerified == 0 &&
              selectedPhonePrefix != initModel!.customerPhonePrefix &&
              initModel!.notificationMessage != null) {
            showDialog(
                context: context,
                builder: (cntx) => MessageDialog(
                    title: AppLocalizations.of(context)!
                        .translate('verify_message'),
                    onDonePressed: () async {
                      await Future.delayed(const Duration(milliseconds: 800));
                      openURL(initModel!.profileUpdateUrl);
                    }));
          } else {
            List<OperatorModel> operators = dictionaryModel!.operators!
                .where(
                    (element) => element.operatorCode == selectedOperatorList)
                .toList();
            if (operators.isEmpty) {
              return Message.show(context, 'Unsupported operator');
            }

            try {
              showDialog(
                  context: context,
                  builder: (context) => SendMoneyDialog(
                        name: name,
                        operator: operatorList[selectedOperatorList]!,
                        explain: selectedReason,
                        phoneNumber: phoneNumber!,
                        amount: amount!,
                        countryCode: selectedCountryCode,
                        onPaypalClicked: () async {
                          print(initModel!.globalSim1Name);
                          print(operators.first.simName);
                          initModel!.customerCountryCode = selectedCountryCode;
                          operators.first.simName = initModel!.globalSim1Name!;
                          if (initModel!.customerCountryCode ==
                              selectedCountryCode) {
                            if (operators.first.simName ==
                                initModel!.globalSim1Name) {
                              await showDialog(
                                  context: context,
                                  builder: (_) => StatefulBuilder(
                                        builder: (_, setStateDialog) => Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .translate(
                                                                'internal_send_fee'),
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.error_outline,
                                                      color: Colors.orange,
                                                      size: 60,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Text(
                                                          '${AppLocalizations.of(context)!.translate('fee_charge_msg')} ${initModel!.internalSendMoneyFee} ${AppLocalizations.of(context)!.translate('for')} ${AppLocalizations.of(context)!.translate('internal_send')}.',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          height: 40,
                                                          width: 90,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.grey,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                'Cancel',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )),
                                                        ),
                                                        const SizedBox(
                                                          width: 16,
                                                        ),
                                                        Container(
                                                          height: 40,
                                                          width: 90,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.green,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: TextButton(
                                                              onPressed:
                                                                  () async {
                                                                await Future.delayed(
                                                                    const Duration(
                                                                        milliseconds:
                                                                            250));
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                                await Future.delayed(
                                                                    const Duration(
                                                                        milliseconds:
                                                                            250));
                                                                paypalClicked();
                                                              },
                                                              child: Text(
                                                                  'Accept',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ))),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                            }
                          } else {
                            await Future.delayed(
                                const Duration(milliseconds: 250));
                            Navigator.pop(context);
                            await Future.delayed(
                                const Duration(milliseconds: 250));
                            paypalClicked();
                          }
                        },
                        onWalletClicked: () async {
                          if (double.parse(amount ?? '0.0') >
                              (initModel!.customerBalance ?? 0.0)) {
                            //AppNavigator.pushReplace(context: context, page: const WalletRefill());
                            //return;
                          }
                          if (initModel!.customerCountryCode ==
                              selectedCountryCode) {
                            if (operators.first.simName ==
                                initModel!.globalSim1Name) {
                              if (double.parse(amount ?? '0.0') +
                                      initModel!.internalSendMoneyFee >
                                  (initModel!.customerBalance ?? 0.0)) {
                                AppNavigator.pushReplace(
                                    context: context,
                                    page: const WalletRefill());
                                return;
                              }
                            }
                          }
                          await Future.delayed(
                              const Duration(milliseconds: 250));
                          Navigator.pop(context);
                          await Future.delayed(
                              const Duration(milliseconds: 250));
                          walletClicked();
                        },
                      ));
            } catch (error) {
              if (!AppConfig.isPublished) {
                print('error: $error');
              }
            }
          }
        } else {
          Message.show(context,
              AppLocalizations.of(context)!.translate('terms_agree_validate'));
        }
      } else {
        Message.show(context,
            AppLocalizations.of(context)!.translate('terms_agree_validate'));
      }
    }
  }

  void paypalClicked() async {
    showDialog(context: context, builder: (context) => const LoadingDialog());
    await Future.delayed(const Duration(milliseconds: 3000));
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (context) => SuccessDialog(
            title: AppLocalizations.of(context)!
                .translate('transaction_succeeded'),
            receiptNumber: '#U672Y8974'));
  }

  void walletClicked() async {
    showDialog(context: context, builder: (context) => const LoadingDialog());
    await Future.delayed(const Duration(milliseconds: 3000));
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (context) => FailDialog(
            title:
                AppLocalizations.of(context)!.translate('transaction_failed') +
                    '!'));
  }

  void openURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        Message.show(
            context, AppLocalizations.of(context)!.translate('browser_error'));
      }
    } catch (error) {
      if (!AppConfig.isPublished) {
        print('error: $error');
      }
    }
  }
}
