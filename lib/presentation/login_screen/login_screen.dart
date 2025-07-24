import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import './widgets/app_logo_widget.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/forgot_password_widget.dart';
import './widgets/google_signin_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/signup_link_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isBiometricAvailable = true;
  String? _errorMessage;

  final AuthService _authService = AuthService();
  final SupabaseService _supabaseService = SupabaseService();

  // Mock credentials for preview mode
  final Map<String, String> _mockCredentials = {
    'admin@notetask.com': 'admin123',
    'user@notetask.com': 'user123',
    'demo@notetask.com': 'demo123',
  };

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    // Simulate biometric availability check
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isBiometricAvailable = true;
    });
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      // Success haptic feedback
      HapticFeedback.lightImpact();

      // Show success toast
      Fluttertoast.showToast(
        msg: "Login successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.getSuccessColor(true),
        textColor: Colors.white,
      );

      // Navigate to overview screen
      Navigator.pushReplacementNamed(context, '/overview-screen');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      // Error haptic feedback
      HapticFeedback.mediumImpact();

      // Show error toast
      Fluttertoast.showToast(
        msg: _errorMessage!,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithGoogle();

      // Success haptic feedback
      HapticFeedback.lightImpact();

      // Show success toast
      Fluttertoast.showToast(
        msg: "Google Sign-In successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.getSuccessColor(true),
        textColor: Colors.white,
      );

      // Navigate to overview screen
      Navigator.pushReplacementNamed(context, '/overview-screen');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      // Error haptic feedback
      HapticFeedback.mediumImpact();

      // Show error toast
      Fluttertoast.showToast(
        msg: _errorMessage!,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricAuth() async {
    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(seconds: 1));

      // Success haptic feedback
      HapticFeedback.lightImpact();

      // Show success toast
      Fluttertoast.showToast(
        msg: "Biometric authentication successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.getSuccessColor(true),
        textColor: Colors.white,
      );

      // Navigate to overview screen
      Navigator.pushReplacementNamed(context, '/overview-screen');
    } catch (e) {
      // Error haptic feedback
      HapticFeedback.mediumImpact();

      // Show error toast
      Fluttertoast.showToast(
        msg: "Biometric authentication failed. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
    }
  }

  void _handleForgotPassword() {
    if (!_supabaseService.isConfigured) {
      // Show preview mode message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Preview Mode',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Password reset is not available in preview mode. Please configure Supabase to enable this feature.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Show password reset dialog
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController emailController = TextEditingController();
        return AlertDialog(
          title: Text(
            'Reset Password',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email address to receive a password reset link.',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  try {
                    await _authService.resetPassword(email);
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "Password reset email sent!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: AppTheme.getSuccessColor(true),
                      textColor: Colors.white,
                    );
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: e.toString().replaceAll('Exception: ', ''),
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: AppTheme.lightTheme.colorScheme.error,
                      textColor: Colors.white,
                    );
                  }
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _handleSignUp() {
    Navigator.pushNamed(context, '/registration-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    8.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo
                  const AppLogoWidget(),

                  SizedBox(height: 6.h),

                  // Preview Mode Banner
                  if (!_supabaseService.isConfigured) ...[
                    Container(
                      padding: EdgeInsets.all(3.w),
                      margin: EdgeInsets.only(bottom: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'info',
                            color: Colors.orange,
                            size: 4.w,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Preview Mode - Configure Supabase for full functionality',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: Colors.orange.shade700,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Error Message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: EdgeInsets.all(3.w),
                      margin: EdgeInsets.only(bottom: 3.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.error
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.error
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'error',
                            color: AppTheme.lightTheme.colorScheme.error,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.error,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Login Form
                  LoginFormWidget(
                    onLogin: _handleLogin,
                    isLoading: _isLoading,
                  ),

                  SizedBox(height: 2.h),

                  // Forgot Password Link
                  ForgotPasswordWidget(
                    onForgotPassword: _handleForgotPassword,
                  ),

                  SizedBox(height: 4.h),

                  // Google Sign-In
                  GoogleSignInWidget(
                    onGoogleSignIn: _handleGoogleSignIn,
                    isLoading: _isGoogleLoading,
                  ),

                  // Biometric Authentication
                  BiometricPromptWidget(
                    onBiometricAuth: _handleBiometricAuth,
                    isAvailable: _isBiometricAvailable,
                  ),

                  SizedBox(height: 4.h),

                  // Sign Up Link
                  SignUpLinkWidget(
                    onSignUp: _handleSignUp,
                  ),

                  SizedBox(height: 2.h),

                  // Mock Credentials Info (only in preview mode)
                  if (!_supabaseService.isConfigured) ...[
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'info',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Demo Credentials',
                                style: AppTheme.lightTheme.textTheme.labelMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          ..._mockCredentials.entries.map((entry) => Padding(
                                padding: EdgeInsets.only(bottom: 0.5.h),
                                child: Text(
                                  '${entry.key} / ${entry.value}',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontSize: 11.sp,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
