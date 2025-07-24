import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/gradient_background_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/retry_button_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _showRetryButton = false;
  String _loadingText = 'Initializing...';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Mock user data for demonstration
  final Map<String, dynamic> _mockUserData = {
    "isAuthenticated": false,
    "isFirstTime": true,
    "hasCompletedOnboarding": false,
    "userPreferences": {
      "theme": "light",
      "fontSize": "medium",
      "fontFamily": "Inter"
    }
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setSystemUIOverlay();
    _initializeApp();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppTheme.lightTheme.colorScheme.primary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _loadingText = 'Checking authentication...';
      });

      // Simulate Firebase authentication check
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _loadingText = 'Loading preferences...';
      });

      // Simulate loading user preferences
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        _loadingText = 'Preparing data...';
      });

      // Simulate Hive/SQLite initialization
      await Future.delayed(const Duration(milliseconds: 700));

      setState(() {
        _loadingText = 'Almost ready...';
      });

      // Final configuration
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate based on user state
      _navigateToNextScreen();
    } catch (e) {
      // Show retry button after 5 seconds timeout
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        setState(() {
          _showRetryButton = true;
        });
        _fadeController.forward();
      }
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    // Determine navigation path based on user state
    String nextRoute;

    if (_mockUserData["isAuthenticated"] == true) {
      nextRoute = '/overview-screen';
    } else if (_mockUserData["isFirstTime"] == true ||
        _mockUserData["hasCompletedOnboarding"] == false) {
      nextRoute = '/onboarding-flow';
    } else {
      nextRoute = '/login-screen';
    }

    // Smooth transition to next screen
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, nextRoute);
      }
    });
  }

  void _retryInitialization() {
    setState(() {
      _showRetryButton = false;
      _loadingText = 'Retrying...';
    });
    _fadeController.reset();
    _initializeApp();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    // Reset system UI overlay
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GradientBackgroundWidget(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _showRetryButton ? _buildRetryView() : _buildLoadingView(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),

        // Animated Logo
        const AnimatedLogoWidget(),

        SizedBox(height: 3.h),

        // App Name
        Text(
          'NoteTask AI',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),

        SizedBox(height: 1.h),

        // Tagline
        Text(
          'AI-Powered Note Taking',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 0.5,
          ),
        ),

        const Spacer(flex: 3),

        // Loading Indicator
        LoadingIndicatorWidget(loadingText: _loadingText),

        const Spacer(flex: 1),

        // Version Info
        Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Text(
            'Version 1.0.0',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRetryView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Logo (static when showing retry)
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'note_add',
                  color: Colors.white,
                  size: 6.w,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'NT',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          // Retry Button
          RetryButtonWidget(
            onRetry: _retryInitialization,
            message:
                'Connection timeout. Please check your internet connection and try again.',
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
