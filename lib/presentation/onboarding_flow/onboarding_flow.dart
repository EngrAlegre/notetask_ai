import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/navigation_controls_widget.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _biometricEnabled = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "AI-Powered Note Taking",
      "description":
          "Transform your thoughts with intelligent summarization, grammar correction, and idea generation. Let AI enhance your creativity and productivity.",
      "image":
          "https://images.unsplash.com/photo-1677442136019-21780ecad995?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    },
    {
      "title": "Smart Organization",
      "description":
          "Keep everything organized with folders, tags, and smart reminders. Never lose track of important notes and tasks again.",
      "image":
          "https://images.pexels.com/photos/7688336/pexels-photo-7688336.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    },
    {
      "title": "Offline-First Experience",
      "description":
          "Work seamlessly offline with local storage and automatic background sync. Your notes are always available, anywhere.",
      "image":
          "https://images.pixabay.com/photo/2020/06/24/19/12/cabbage-5337431_1280.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, '/overview-screen');
  }

  void _completeOnboarding() {
    // Handle biometric setup if enabled
    if (_biometricEnabled) {
      _setupBiometricAuth();
    }
    Navigator.pushReplacementNamed(context, '/overview-screen');
  }

  void _setupBiometricAuth() {
    // Biometric authentication setup logic would go here
    // This is a placeholder for the actual implementation
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return OnboardingPageWidget(
                    title: data["title"] as String,
                    description: data["description"] as String,
                    imageUrl: data["image"] as String,
                    isLastPage: index == _onboardingData.length - 1,
                    onGetStarted: _completeOnboarding,
                  );
                },
              ),
            ),

            // Page indicator
            Container(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: PageIndicatorWidget(
                currentPage: _currentPage,
                totalPages: _onboardingData.length,
              ),
            ),

            // Navigation controls
            NavigationControlsWidget(
              onSkip: _skipOnboarding,
              onNext: _nextPage,
              isLastPage: _currentPage == _onboardingData.length - 1,
              nextButtonText: _currentPage == _onboardingData.length - 1
                  ? 'Get Started'
                  : 'Next',
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
