import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final double? placeholderIconSize;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.size = 80,
    this.fit,
    this.borderRadius,
    this.placeholderIcon = Symbols.package_2_rounded,
    this.placeholderIconSize,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.borderRadius16;
    final iconSize = placeholderIconSize ?? (size * 0.8);

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: context.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: radius,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: context.colorScheme.outline,
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: fit ?? BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Center(
                child: Icon(
                  placeholderIcon,
                  size: iconSize,
                  weight: 300,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : Center(
              child: Icon(
                placeholderIcon,
                size: iconSize,
                weight: 300,
                color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
    );
  }
}
