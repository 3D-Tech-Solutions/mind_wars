import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

import '../utils/brand_assets.dart';
import '../services/avatar_cache_service.dart';

/// [2026-03-16 Integration] Asset-aware avatar renderer for branded profiles.
///
/// Supports:
/// 1. Emoji/asset avatars (starts with 'assets/')
/// 2. Uploaded images (URL + checksum for offline-first caching)
/// 3. Fallback label (initials)
///
/// For uploaded images, uses local cache during gameplay to avoid network calls.
class BrandedAvatar extends StatefulWidget {
  final String? avatar;  // Asset path or emoji
  final String? avatarUrl;  // Remote URL for uploaded images
  final String? avatarChecksum;  // MD5 checksum for cache validation
  final String? userId;  // Required for avatar caching
  final String fallbackLabel;
  final double radius;
  final Color? backgroundColor;

  const BrandedAvatar({
    super.key,
    required this.avatar,
    this.avatarUrl,
    this.avatarChecksum,
    this.userId,
    required this.fallbackLabel,
    this.radius = 20,
    this.backgroundColor,
  });

  @override
  State<BrandedAvatar> createState() => _BrandedAvatarState();
}

class _BrandedAvatarState extends State<BrandedAvatar> {
  late AvatarCacheService _cacheService;
  Future<String?>? _cachedPathFuture;

  @override
  void initState() {
    super.initState();
    _cacheService = AvatarCacheService();

    // Only preload if we have a remote avatar
    if (widget.avatarUrl != null && widget.userId != null) {
      _cachedPathFuture = _cacheService.downloadAndCacheAvatar(
        widget.userId!,
        widget.avatarUrl!,
        widget.avatarChecksum,
      );
    }
  }

  bool get _hasAssetAvatar =>
      widget.avatar != null && widget.avatar!.startsWith('assets/') && widget.avatar!.isNotEmpty;

  bool get _hasRemoteAvatar =>
      widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty && widget.userId != null;

  @override
  Widget build(BuildContext context) {
    final effectiveBackground =
        widget.backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    final size = widget.radius * 2;

    // Priority 1: Asset/emoji avatar
    if (_hasAssetAvatar) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: effectiveBackground,
        child: ClipOval(
          child: SizedBox(
            width: size,
            height: size,
            child: widget.avatar!.endsWith('.svg')
                ? SvgPicture.asset(
                    widget.avatar!,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    widget.avatar!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      );
    }

    // Priority 2: Remote avatar (with local cache)
    if (_hasRemoteAvatar) {
      return FutureBuilder<String?>(
        future: _cachedPathFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
            // Cache hit - display from local file
            return CircleAvatar(
              radius: widget.radius,
              backgroundColor: effectiveBackground,
              child: ClipOval(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Image.file(
                    File(snapshot.data!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallback(effectiveBackground),
                  ),
                ),
              ),
            );
          }

          // Still loading or error - show fallback
          return CircleAvatar(
            radius: widget.radius,
            backgroundColor: effectiveBackground,
            child: snapshot.connectionState == ConnectionState.waiting
                ? SizedBox(
                    width: widget.radius,
                    height: widget.radius,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : _buildFallbackText(effectiveBackground),
          );
        },
      );
    }

    // Priority 3: Fallback initials
    return _buildFallback(effectiveBackground);
  }

  Widget _buildFallback(Color backgroundColor) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: backgroundColor,
      child: _buildFallbackText(backgroundColor),
    );
  }

  Widget _buildFallbackText(Color backgroundColor) {
    return Text(
      widget.fallbackLabel,
      style: TextStyle(
        color: BrandAssets.text,
        fontSize: widget.radius,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}