import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import './widgets/google_signin_button.dart';
import './widgets/registration_form.dart';
import './widgets/terms_privacy_section.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();
  final SupabaseService _supabaseService = SupabaseService();

  Future<void> _handleRegistration({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required bool acceptTerms,
  }) async {
    if (!acceptTerms) {
      setState(() {
        _errorMessage =
            'Please accept the terms and privacy policy to continue.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!_supabaseService.isConfigured) {
        // Preview mode - simulate registration
        await Future.delayed(const Duration(seconds: 2));

        // Success haptic feedback
        HapticFeedback.lightImpact();

        // Show success toast
        Fluttertoast.showToast(
            msg: "Registration successful! (Preview Mode)",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppTheme.getSuccessColor(true),
            textColor: Colors.white);

        // Navigate to overview screen
        Navigator.pushReplacementNamed(context, '/overview-screen');
        return;
      }

      await _authService.signUp(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName);

      // Success haptic feedback
      HapticFeedback.lightImpact();

      // Show success toast
      Fluttertoast.showToast(
          msg:
              "Registration successful! Please check your email for verification.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.getSuccessColor(true),
          textColor: Colors.white);

      // Navigate to login screen
      Navigator.pushReplacementNamed(context, '/login-screen');
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
          textColor: Colors.white);
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
          textColor: Colors.white);

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
          textColor: Colors.white);
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _handleSignIn() {
    Navigator.pushReplacementNamed(context, '/login-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context)),
            title: Text('Create Account',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: Colors.black, fontWeight: FontWeight.w600)),
            centerTitle: true),
        body: SafeArea(
            child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Welcome Text
                          Text('Welcome to NoteTask AI',
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),

                          SizedBox(height: 1.h),

                          Text(
                              'Create your account to get started with AI-powered note taking',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center),

                          SizedBox(height: 4.h),

                          // Preview Mode Banner
                          if (!_supabaseService.isConfigured) ...[
                            Container(
                                padding: EdgeInsets.all(3.w),
                                margin: EdgeInsets.only(bottom: 3.h),
                                decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(2.w),
                                    border: Border.all(
                                        color: Colors.orange
                                            .withValues(alpha: 0.3))),
                                child: Row(children: [
                                  CustomIconWidget(
                                      iconName: 'info',
                                      color: Colors.orange,
                                      size: 4.w),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                      child: Text(
                                          'Preview Mode - Configure Supabase for full functionality',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: Colors.orange.shade700,
                                                  fontSize: 12.sp))),
                                ])),
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
                                        color: AppTheme
                                            .lightTheme.colorScheme.error
                                            .withValues(alpha: 0.3))),
                                child: Row(children: [
                                  CustomIconWidget(
                                      iconName: 'error',
                                      color:
                                          AppTheme.lightTheme.colorScheme.error,
                                      size: 5.w),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                      child: Text(_errorMessage!,
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: AppTheme.lightTheme
                                                      .colorScheme.error,
                                                  fontSize: 12.sp))),
                                ])),
                          ],

                          // Registration Form
                          RegistrationForm(
                              onRegister: _handleRegistration,
                              isLoading: _isLoading),

                          SizedBox(height: 4.h),

                          // Google Sign-In
                          GoogleSignInButton(
                              isLoading: _isGoogleLoading,
                              onPressed: _handleGoogleSignIn),

                          SizedBox(height: 4.h),

                          // Terms and Privacy
                          TermsPrivacySection(
                              isAccepted: true, onChanged: (value) {}),

                          SizedBox(height: 4.h),

                          // Sign In Link
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Already have an account? ',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(color: Colors.grey[600])),
                                GestureDetector(
                                    onTap: _handleSignIn,
                                    child: Text('Sign In',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodyMedium
                                            ?.copyWith(
                                                color: AppTheme.lightTheme
                                                    .colorScheme.primary,
                                                fontWeight: FontWeight.w600))),
                              ]),

                          SizedBox(height: 2.h),
                        ])))));
  }
}
