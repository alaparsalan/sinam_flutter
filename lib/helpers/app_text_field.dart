import '../config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {

  final bool? isEnable;
  final String labelText;
  final String? value;
  final int? maxLine;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final TextInputAction? inputAction;
  final Function(String term)? onFieldSubmitted;
  final Function()? onEditingComplete;
  final Function(String value)? onValidate;
  final Function(String value)? onChanged;
  final TextInputType? textInputType;
  final bool? isPassword;
  final bool? autoFocus;
  final TextDirection? textDirection;
  final TextCapitalization? textCapitalization;
  final List<TextInputFormatter>? textInputFormatter;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? hasBorder;
  final bool? toggleVisibleSt;

  const AppTextField({Key? key,  this.maxLine, this.autoFocus, this.textCapitalization, this.onEditingComplete,
    this.inputAction , this.onFieldSubmitted, this.onValidate, required this.labelText, this.textInputType,
    this.isPassword, this.textDirection, this.value, this.onChanged, this.textInputFormatter, this.isEnable,
    this.prefixIcon, this.hasBorder = true, this.suffixIcon, this.borderRadius, this.backgroundColor, this.borderColor, this.toggleVisibleSt}) : super(key: key);

  @override
  _AppTextFieldState createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {

  TextEditingController? controller;
  bool? isEmpty;
  final focus = FocusNode();
  bool toggleVisible = false;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();
    isEmpty = controller!.text.isEmpty;
    controller!.addListener(() {
      if (isEmpty != controller!.text.isEmpty) {
        setState(() {
          isEmpty = controller!.text.isEmpty;
        });
      }
    });

    if(widget.value != null){
      controller!.text = widget.value!;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(3),
      child: Directionality(
        textDirection: widget.textDirection != null ? widget.textDirection! : TextDirection.ltr,
        child: TextFormField(
          controller: controller,
          enabled: widget.isEnable ?? true,
          cursorColor: AppColors.accentColor,
          style: TextStyle(fontSize: 17, color: widget.isEnable != null && widget.isEnable == false ? Colors.grey[400] : Colors.grey[700]),
          maxLines: widget.maxLine ?? 1,
          textInputAction: widget.inputAction ?? TextInputAction.next,
          autofocus: widget.autoFocus != null ? widget.autoFocus! : false,
          keyboardType: widget.textInputType ?? TextInputType.text,
          obscureText: widget.isPassword != null ? (widget.toggleVisibleSt != null && widget.toggleVisibleSt == true ? (toggleVisible ? false:true) : widget.isPassword!) : false,
          textCapitalization: widget.textCapitalization != null ? widget.textCapitalization! : TextCapitalization.none,
          onFieldSubmitted: (term){
            if(widget.onFieldSubmitted != null){
              widget.onFieldSubmitted!(term);
            }
            FocusScope.of(context).nextFocus();
          },
          onEditingComplete: (){
            if(widget.onEditingComplete != null){
              widget.onEditingComplete!();
            }
          },
          onChanged: (value){
            widget.onChanged!(value);
          },
          autocorrect: false,
          enableSuggestions: false,
          validator: (value) {
            return widget.onValidate != null ? widget.onValidate!(value!) : null;
          },
          inputFormatters: widget.textInputFormatter,
          decoration: InputDecoration(
            isDense: true,
            filled: widget.backgroundColor != null ? true : false,
            fillColor: widget.backgroundColor ?? Colors.transparent,
            contentPadding: const EdgeInsets.fromLTRB(20, 17, 0, 17),
            //labelText: widget.labelText,
            //labelStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
            hintText: widget.labelText,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
            errorMaxLines: 1,
            errorStyle: const TextStyle(fontSize: 12),
            border: widget.hasBorder != null && widget.hasBorder! ? OutlineInputBorder(
                borderSide:  BorderSide(color: widget.borderColor != null ? widget.borderColor! : AppColors.primaryColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius ?? 30))
            ) : InputBorder.none,
            focusedBorder: widget.hasBorder != null && widget.hasBorder! ? OutlineInputBorder(
                borderSide:  BorderSide(color: widget.borderColor != null ? widget.borderColor! : AppColors.primaryColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius ?? 30))
            ) : InputBorder.none,
            enabledBorder: widget.hasBorder != null && widget.hasBorder! ? OutlineInputBorder(
                borderSide:  BorderSide(color: widget.borderColor != null ? widget.borderColor! : AppColors.primaryColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius ?? 30))
            ) : InputBorder.none,
            errorBorder: OutlineInputBorder(
                borderSide:  const BorderSide(color: Colors.redAccent, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius ?? 30))
            ),
            disabledBorder: widget.hasBorder != null && widget.hasBorder! ? OutlineInputBorder(
                borderSide:  BorderSide(color: widget.borderColor != null ? widget.borderColor! : AppColors.primaryColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius ?? 30))
            ) : InputBorder.none,
            prefixIcon: widget.prefixIcon,
            //suffixIcon: controller!.text.isNotEmpty ? removeButton() : null,
            suffixIcon: widget.suffixIcon != null ? Container(
              margin: const EdgeInsets.only(right: 8),
              width: widget.toggleVisibleSt != null && widget.toggleVisibleSt == true ? 120 : 82,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  controller!.text.isNotEmpty ? removeButton() : Container(width: 0),
                  controller!.text.isNotEmpty && widget.toggleVisibleSt != null && widget.toggleVisibleSt == true ? toggleButton() : Container(width: 0),
                  const SizedBox(width: 15),
                  widget.suffixIcon!
                ],
              ),
            ) : (controller!.text.isNotEmpty ? Row(
              children: [
                removeButton(),
                controller!.text.isNotEmpty && widget.toggleVisibleSt != null && widget.toggleVisibleSt == true ? toggleButton() : Container(width: 0),
              ],
            ) : null),
          ),
        ),
      ),
    );
  }

  Widget removeButton(){
    return widget.isEnable != null && widget.isEnable! == false ? Container(width: 0) : GestureDetector( onTap: (){ controller!.clear(); widget.onChanged!(''); }, child: Icon(Icons.cancel, size: 21, color: Colors.grey[400]));
  }

  Widget toggleButton(){
    return widget.isEnable != null && widget.isEnable! == false ? Container(width: 0) : GestureDetector( onTap: (){ setState(() { toggleVisible = !toggleVisible; }); }, child: Container(margin: const EdgeInsets.only(left: 12), child: Icon(toggleVisible ? Icons.remove_red_eye_rounded : Icons.remove_red_eye_outlined, size: 26, color: Colors.grey[400])));
  }
}