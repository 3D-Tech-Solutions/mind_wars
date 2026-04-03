import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/brand_assets.dart';

/// [2026-03-16 Integration] Asset-aware avatar renderer for branded profiles.
///
/// Supports imported SVG and PNG avatar assets while preserving an initials
/// fallback for existing users who do not yet have an asset-backed avatar.
class BrandedAvatar extends StatelessWidget {
  final String? avatar;
  final String fallbackLabel;
  final double radius;
  final Color? backgroundColor;

  const BrandedAvatar({
    super.key,
    required this.avatar,
    required this.fallbackLabel,
    this.radius = 20,
    this.backgroundColor,
  });

  bool get _hasAssetAvatar =>
      avatar != null && avatar!.startsWith('assets/') && avatar!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final effectiveBackground =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    final size = radius * 2;

    if (_hasAssetAvatar) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: effectiveBackground,
        child: ClipOval(
          child: SizedBox(
            width: size,
            height: size,
            child: avatar!.endsWith('.svg')
                ? SvgPicture.asset(
                    avatar!,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    avatar!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      );
    }

    /// [2026-03-16 Integration] Preserve a graceful fallback for legacy avatars.
    return CircleAvatar(
      radius: radius,
      backgroundColor: effectiveBackground,
      child: Text(
        fallbackLabel,
        style: TextStyle(
          color: BrandAssets.text,
          fontSize: radius,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}