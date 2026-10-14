import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72});
  final double size;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/safewalk_mark.svg',
    width: size,
    height: size,
    semanticsLabel: 'SafeWalk: un camino protegido',
  );
}
