import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSvg extends StatelessWidget {
  final String assetName;
  final String? package;
  final double? width;
  final double? height;
  final Color? color;
  final ColorFilter? colorFilter;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final String? semanticsLabel;

  const AppSvg({
    super.key,
    required this.assetName,
    this.package = 'design_system',
    this.width,
    this.height,
    this.color,
    this.colorFilter,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticsLabel,
  });

  const AppSvg.asset({
    super.key,
    required this.assetName,
    this.package = 'design_system',
    this.width,
    this.height,
    this.color,
    this.colorFilter,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColorFilter = colorFilter ?? (color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null);

    return SvgPicture.asset(
      assetName,
      package: package,
      width: width,
      height: height,
      colorFilter: effectiveColorFilter,
      fit: fit,
      alignment: alignment,
      semanticsLabel: semanticsLabel,
    );
  }
}
