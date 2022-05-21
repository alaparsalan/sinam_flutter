import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarView extends StatefulWidget {
  final String? url;
  final double? width;
  final double? height;
  final bool? status;
  final BoxFit? fit;
  const AvatarView({Key? key, required this.url, this.height, this.width, this.status, this.fit}) : super(key: key);
  @override
  _AvatarViewState createState() => _AvatarViewState();
}

class _AvatarViewState extends State<AvatarView> {

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Container(
            width: widget.width ?? 65,
            height: widget.height ?? 65,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(600),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: widget.url != null && widget.url != '' ? ClipRRect(
              borderRadius: BorderRadius.circular(600),
              child: CachedNetworkImage(
                placeholder:(context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Image.asset('assets/images/avatar.png'),
                imageUrl: widget.url!,
                width: double.infinity,
                height: double.infinity,
                fit: widget.fit ?? BoxFit.cover,
              ),
            ) : ClipRRect(
                borderRadius: BorderRadius.circular(600),
                child: Image.asset('assets/images/avatar.png')
            )
        ),
        if(widget.status != null && widget.status!)
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: Colors.green[400],
              shape: BoxShape.circle
            ),
          ),
        )
      ],
    );
  }
}
