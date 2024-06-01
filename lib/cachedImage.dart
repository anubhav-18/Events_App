import 'package:cached_network_image/cached_network_image.dart';
import 'package:cu_events/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? boxFit;

  const CachedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.boxFit
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => const SpinKitChasingDots(
        color: headingColor,
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      alignment: Alignment.center,
      width: width,
      height: height,
      fit: boxFit,      
    );
  }
}
