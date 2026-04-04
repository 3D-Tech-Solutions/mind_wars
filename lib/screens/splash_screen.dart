/**
 * Splash Screen
 * - Handles initial app load
 * - Attempts to restore session for auto-login
 * - Navigates to appropriate screen based on auth state
 */

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../main.dart';
import 'onboarding_screen.dart';
import '../utils/brand_assets.dart';
import '../utils/brand_animations.dart';
import '../widgets/debug_panel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    // Wait a minimum time for splash screen
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Try to restore session
    final hasSession = await authService.restoreSession();
    
    if (!mounted) return;
    
    if (hasSession) {
      // User is logged in - check if onboarding is complete
      final shouldShow = await shouldShowOnboarding();
      
      if (!mounted) return;
      
      if (shouldShow) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // User is not logged in - show login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    /// [2026-03-16 Integration] Use imported splash art and brand mark instead of placeholder gradients.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (kAlphaMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              tooltip: 'Debug Panel',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: SizedBox(
                      height: 600,
                      child: DebugPanel(),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            MediaQuery.of(context).size.height > 900
                ? BrandAssets.splashIos
                : BrandAssets.splashAndroid,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.24),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                SvgPicture.asset(
                  BrandAssets.wordmarkHorizontal,
                  width: 220,
                ),
                const SizedBox(height: 28),
                BrandAnimations.loadingSpinner(size: 64),
                const SizedBox(height: 24),
                if (kAlphaMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: BrandAssets.deepNavy.withOpacity(0.76),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: BrandAssets.cyan.withOpacity(0.5)),
                    ),
                    child: const Text(
                      'ALPHA VERSION',
                      style: TextStyle(
                        color: BrandAssets.text,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                const SizedBox(height: 72),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
