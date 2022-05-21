import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sinam/config/app_config.dart';
import 'package:sinam/helpers/app_localizations.dart';
import 'package:sinam/helpers/app_text_field.dart';
import 'package:sinam/helpers/fading_edge_scrollview.dart';
import 'package:sinam/helpers/gradiant_button.dart';
import 'package:sinam/helpers/message.dart';
import 'package:sinam/view_models/init_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class MobilePaymentFragment extends StatefulWidget {
  const MobilePaymentFragment({Key? key}) : super(key: key);

  @override
  _MobilePaymentFragmentState createState() => _MobilePaymentFragmentState();
}

class _MobilePaymentFragmentState extends State<MobilePaymentFragment> with AutomaticKeepAliveClientMixin<MobilePaymentFragment>, TickerProviderStateMixin  {

  final _formKey = GlobalKey<FormState>();
  String? amount;
  bool submitSt = true;
  bool? termsSt = false;
  int? selectedSim = 0;
  String selectedSimName = '';
  List<Widget> simList = [];
  bool noSimSt = false;
  late InitViewModel initViewModel;

  @override
  void initState() {
    super.initState();
    initViewModel = context.read<InitViewModel>();
    loadSims();
  }

  void loadSims(){
    simList.clear();
    if(AppConfig.simData != null){
      if(AppConfig.simData!.cards.isNotEmpty){
        for (var element in AppConfig.simData!.cards) {
          simList.add(
            SizedBox(height:67 ,child: Tab(child: Column( children: [ SizedBox(height: ScreenUtil().setHeight(14.0)), Text(element.carrierName, style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textScaleFactor: 1.1, maxLines: 1)]))),
          );
        }
        selectedSimName =  AppConfig.simData!.cards.first.carrierName;
      }else{
        noSimSt = true;
        simList.add(
          SizedBox(height:67 ,child: Tab(child: Column( children: [ SizedBox(height: ScreenUtil().setHeight(14.0)), Text(AppLocalizations.of(context)!.translate('no_sim'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textScaleFactor: 1.1, maxLines: 1)])))
        );
      }
    }else{
      noSimSt = true;
      simList.add(
        SizedBox(height:67 ,child: Tab(child: Column( children: [ SizedBox(height: ScreenUtil().setHeight(14.0)), Text(AppLocalizations.of(context)!.translate('no_sim'), style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip), textScaleFactor: 1.1, maxLines: 1)])))
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: ScreenUtil().setHeight(18)),
        Expanded(
          child: FadingEdgeScrollView.fromSingleChildScrollView(
            child: SingleChildScrollView(
              controller: ScrollController(),
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20), horizontal: ScreenUtil().setWidth(20.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.translate('sim_card'), style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(height: ScreenUtil().setHeight(20)),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xffc3efff),
                              borderRadius: BorderRadius.circular(30)
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: ScreenUtil().setHeight(40),
                              child: DefaultTabController(
                                length: simList.length,
                                child: TabBar(
                                  labelColor: Colors.white,
                                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  unselectedLabelColor: Colors.grey[700],
                                  unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  onTap: (value){
                                    setState(() {
                                      selectedSim = value;
                                      if(!noSimSt){
                                        selectedSimName =  AppConfig.simData!.cards[value].carrierName;
                                      }
                                    });
                                  },
                                  indicator: BoxDecoration(
                                    color: const Color(0xff5197dd),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  tabs: simList,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            labelText: AppLocalizations.of(context)!.translate('enter_refill_amount'),
                            borderRadius: 30,
                            borderColor: const Color(0xffc3efff),
                            backgroundColor: const Color(0xffc3efff),
                            textInputType: TextInputType.number,
                            inputAction: TextInputAction.done,
                            onChanged: (value){ setState(() { amount = value; });},
                            onValidate: (value){
                              if(value.isEmpty){
                                return AppLocalizations.of(context)!.translate('amount_empty_validate');
                              }
                              return null;
                            },
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Text('€', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[500]),),
                            ),
                          ),
                          termsView(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GradiantButton(
                      title: AppLocalizations.of(context)!.translate('send'),
                      radius: 40,
                      width: double.maxFinite,
                      endColor: const Color(0xff3b7acc),
                      onPressed: () async{
                        await Future.delayed(const Duration(milliseconds: 250));
                        submitForm();
                      }
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget termsView(){
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: GestureDetector(
        onTap: () => setState(() { termsSt = termsSt != null ? !termsSt! : true;}),
        child: Wrap(
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: const Color(0xffc3efff),
              ),child: Checkbox(value: termsSt, onChanged: (value) => setState(() { termsSt = value; }), checkColor: Colors.blue[700], activeColor: const Color(0xffc3efff))
            ),
            Text(AppLocalizations.of(context)!.translate('terms_agree'), style: const TextStyle(fontSize: 13, color: Colors.white)),
            const SizedBox(width: 2),
            GestureDetector(
                onTap: () async{
                  await Future.delayed(const Duration(milliseconds: 250));
                  if(initViewModel.getTermsUrl != null){
                    openURL(initViewModel.getTermsUrl!);
                  }else{
                    Message.show(context, AppLocalizations.of(context)!.translate('went_wrong'));
                  }
                },
                child: Text(AppLocalizations.of(context)!.translate('terms_and_policies'), style: TextStyle(color: Colors.blue[200]!, fontSize: 13, decoration: TextDecoration.underline), maxLines: 1, overflow: TextOverflow.ellipsis)
            ),
          ],
        ),
      ),
    );
  }

  void submitForm(){
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if(termsSt != null && termsSt!){
        try{

        }catch(error){
          if(!AppConfig.isPublished){ print('error: $error'); }
        }
      }else{
        Message.show(context, AppLocalizations.of(context)!.translate('terms_agree_validate'));
      }
    }
  }

  void openURL(String url) async{
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

  @override
  bool get wantKeepAlive => true;
}
