import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sinam/config/app_colors.dart';

class ImageView extends StatefulWidget {
  final String? url;
  final double? width;
  final double? height;
  final double? radius;
  final bool?   hasPlaceHolder;
  const ImageView({Key? key, required this.url, this.height, this.width, this.radius, this.hasPlaceHolder}) : super(key: key);
  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 65,
      height: widget.height ?? 65,
      child: widget.url != null && widget.url != '' ? ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius != null ? widget.radius! : 10),
        child: CachedNetworkImage(
          placeholder:(context, url) => Container(color: AppColors.veryLightGrey),
          errorWidget: (context, url, error) => widget.hasPlaceHolder != null && widget.hasPlaceHolder! == true ? Image.asset('assets/images/default.jpg') : Container(color: AppColors.veryLightGrey),
          imageUrl: widget.url!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ) : ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius != null ? widget.radius! : 10),
          child: widget.hasPlaceHolder != null && widget.hasPlaceHolder! == true ? Image.asset('assets/images/default.jpg') : Container(color: AppColors.veryLightGrey)
      )
    );
  }
}