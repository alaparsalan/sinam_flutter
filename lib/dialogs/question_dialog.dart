import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sinam/helpers/app_localizations.dart';

class QuestionDialog extends StatefulWidget {

  final String title;
  final String? yesTitle;
  final String? noTitle;
  final Function? onYes;
  final Function? onNo;

  const QuestionDialog({Key? key,  required this.title, this.onYes, this.onNo, this.yesTitle, this.noTitle }) : super(key: key);

  @override
  _QuestionDialogState createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> with SingleTickerProviderStateMixin {

  AnimationController? controller;
  Animation<double>? scaleAnimation;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller!, curve: Curves.linearToEaseOut);

    controller!.addListener(() {
      setState(() {});
    });

    controller!.forward();
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: SizedBox(
        width: ScreenUtil().setWidth(350),
        //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
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
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        width: double.infinity,
                        color: Colors.white,
                        child: Center(
                          child: Text(widget.title, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.center),
                        )
                    ),
                    Divider(height: 0, color: Colors.grey[300], thickness: 0.5),
                    Container(
                      color: Colors.grey[300],
                      child: Row(
                        children: <Widget>[

                          Expanded(
                            child: Container(
                              color: Colors.white,
                              height: 48,
                              child: TextButton(
                                  onPressed: (){
                                    if(widget.onNo != null){
                                      widget.onNo!();
                                    }

                                    Future.delayed(const Duration(milliseconds: 300), (){
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: Text(widget.noTitle != null ? widget.noTitle! : AppLocalizations.of(context)!.translate('no'), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.blue[600]), textAlign: TextAlign.center)
                              ),
                            ),
                          ),

                          const SizedBox(width: 0.5),

                          Expanded(
                            child: Container(
                              color: Colors.white,
                              height: 48,
                              child: TextButton(
                                  onPressed: (){
                                    if(widget.onYes != null){
                                      widget.onYes!();
                                      Future.delayed(const Duration(milliseconds: 300), (){
                                        Navigator.pop(context);
                                      });
                                    }
                                  },
                                  child: Text(widget.yesTitle != null ? widget.yesTitle! : AppLocalizations.of(context)!.translate('yes'), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.blue[600]), textAlign: TextAlign.center)
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
            ),
          ),
        ),
      ),
    );
  }
}