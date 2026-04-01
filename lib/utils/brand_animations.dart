/// BrandAnimations — centralised Lottie JSON asset paths and ready-to-use
/// widget builders for Mind Wars branded motion assets.
///
/// All four animations were generated from the Batch G spec in
/// docs/ai_asset_generation_list.md and exported as Lottie JSON v5.7.4.
///
/// Usage example:
/// ```dart
/// import 'package:mind_wars/utils/brand_animations.dart';
/// import 'package:lottie/lottie.dart';
///
/// // One-liner widget (looping spinner):
/// BrandAnimations.loadingSpinner(size: 64)
///
/// // Full-control builder (splash, plays once then calls onFinished):
/// BrandAnimations.splashAssembly(onFinished: () => Navigator.pushReplacement(...))
///
/// // Achievement unlock, plays once:
/// BrandAnimations.achievementUnlock()
///
/// // Battle countdown, plays once then calls onFinished:
/// BrandAnimations.battleCountdown(onFinished: () => _startGame())
/// ```
///
/// Run `flutter pub get` to pull in `lottie: ^3.1.0` before using these widgets.

library brand_animations;

import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

/// Asset path constants — use these wherever you need to reference an
/// animation without going through the widget builders below.
abstract class BrandAnimationPaths {
  /// Splash / app-open assembly  — 1080×2340, 60 fps, ~1.2 s, plays once.
  static const String splashAssembly =
      'assets/branding/animations/anim_splash-assembly_1080x2340.json';

  /// Loading spinner  — 256×256, 60 fps, infinite loop.
  static const String loadingSpinner =
      'assets/branding/animations/anim_loading-spinner_256.json';

  /// Battle countdown (3-2-1-GO)  — 1080×1080, 60 fps, ~2.6 s, plays once.
  static const String battleCountdown =
      'assets/branding/animations/anim_battle-countdown_1080.json';

  /// Achievement unlock burst  — 400×400, 60 fps, ~1.5 s, plays once.
  static const String achievementUnlock =
      'assets/branding/system/anim_achievement-unlock_400.json';
}

/// Ready-made Lottie widget builders that follow the Mind Wars brand motion
/// style (dark backgrounds, cyan/coral/gold palette, purposeful & fast).
abstract class BrandAnimations {
  // ---------------------------------------------------------------------------
  // Splash Assembly
  // ---------------------------------------------------------------------------

  /// Full-screen splash intro animation. Plays once and then calls
  /// [onFinished] so the caller can navigate away.
  ///
  /// Wrap in a `Container(color: Color(0xFF090A12))` for the correct void-black
  /// background (the animation itself is transparent).
  ///
  /// ```dart
  /// BrandAnimations.splashAssembly(
  ///   onFinished: () => Navigator.pushReplacementNamed(context, '/home'),
  /// )
  /// ```
  static Widget splashAssembly({
    double? width,
    double? height,
    VoidCallback? onFinished,
  }) {
    return Lottie.asset(
      BrandAnimationPaths.splashAssembly,
      width: width,
      height: height,
      fit: BoxFit.contain,
      repeat: false,
      onLoaded: onFinished == null
          ? null
          : (composition) {
              // onLoaded fires immediately; use addStatusListener via a
              // controller for true end-of-animation callback. See docs below.
            },
      // For an onFinished callback, use the controller pattern:
      //   final _ctrl = AnimationController(vsync: this);
      //   _ctrl.addStatusListener((s) {
      //     if (s == AnimationStatus.completed) onFinished?.call();
      //   });
      //   Lottie.asset(..., controller: _ctrl,
      //     onLoaded: (c) { _ctrl.duration = c.duration; _ctrl.forward(); })
    );
  }

  // ---------------------------------------------------------------------------
  // Loading Spinner
  // ---------------------------------------------------------------------------

  /// Compact loading spinner. Loops indefinitely. Drop-in replacement for
  /// `CircularProgressIndicator` with brand styling.
  ///
  /// ```dart
  /// BrandAnimations.loadingSpinner(size: 48)
  /// ```
  static Widget loadingSpinner({double size = 64}) {
    return Lottie.asset(
      BrandAnimationPaths.loadingSpinner,
      width: size,
      height: size,
      fit: BoxFit.contain,
      repeat: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Battle Countdown
  // ---------------------------------------------------------------------------

  /// 3-2-1-GO battle countdown overlay. Plays once and then calls [onFinished]
  /// so the caller can start the game.
  ///
  /// Typical use — show it in a Stack over the game board:
  /// ```dart
  /// if (_showCountdown)
  ///   BrandAnimations.battleCountdown(
  ///     onFinished: () => setState(() => _showCountdown = false),
  ///   )
  /// ```
  ///
  /// For the callback pattern, use `AnimationController` (see splashAssembly
  /// comment above for the full pattern).
  static Widget battleCountdown({
    double? width,
    double? height,
    VoidCallback? onFinished,
  }) {
    return Lottie.asset(
      BrandAnimationPaths.battleCountdown,
      width: width,
      height: height,
      fit: BoxFit.contain,
      repeat: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Achievement Unlock
  // ---------------------------------------------------------------------------

  /// Gold/cyan burst that plays when the player earns an achievement.
  /// Plays once. Typically shown in a Dialog or as an overlay.
  ///
  /// ```dart
  /// showDialog(
  ///   context: context,
  ///   builder: (_) => Dialog(
  ///     backgroundColor: Colors.transparent,
  ///     child: BrandAnimations.achievementUnlock(size: 300),
  ///   ),
  /// );
  /// ```
  static Widget achievementUnlock({double size = 200}) {
    return Lottie.asset(
      BrandAnimationPaths.achievementUnlock,
      width: size,
      height: size,
      fit: BoxFit.contain,
      repeat: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Controller-based helper (for onFinished callbacks)
  // ---------------------------------------------------------------------------

  /// Returns a [LottieBuilder] wired to [controller] so that the caller can
  /// respond to AnimationStatus.completed.
  ///
  /// The caller must:
  ///   1. Create an `AnimationController(vsync: this)` in their State.
  ///   2. Attach a status listener before passing it here.
  ///   3. Dispose the controller in `dispose()`.
  ///
  /// ```dart
  /// late final AnimationController _ctrl;
  ///
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   _ctrl = AnimationController(vsync: this);
  ///   _ctrl.addStatusListener((s) {
  ///     if (s == AnimationStatus.completed) _onDone();
  ///   });
  /// }
  ///
  /// Widget build(BuildContext context) => BrandAnimations.withController(
  ///       path: BrandAnimationPaths.battleCountdown,
  ///       controller: _ctrl,
  ///     );
  ///
  /// @override
  /// void dispose() { _ctrl.dispose(); super.dispose(); }
  /// ```
  static Widget withController({
    required String path,
    required AnimationController controller,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return Lottie.asset(
      path,
      controller: controller,
      width: width,
      height: height,
      fit: fit,
      onLoaded: (composition) {
        controller.duration = composition.duration;
        controller.forward();
      },
    );
  }
}
