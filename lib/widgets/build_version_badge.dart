import 'package:flutter/material.dart';
import '../utils/build_config.dart';

/// Small unobtrusive build version badge displayed in bottom-right corner
class BuildVersionBadge extends StatelessWidget {
  const BuildVersionBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 8,
      bottom: 8,
      child: Text(
        'v${BuildConfig.appVersion} · #${BuildConfig.buildNumber}',
        style: const TextStyle(fontSize: 9, color: Colors.white38),
      ),
    );
  }
}
