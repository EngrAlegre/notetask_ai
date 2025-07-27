import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/biometric_service.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_tile_widget.dart';
import './widgets/theme_selector_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final BiometricService _biometricService = BiometricService();

  Map<String, dynamic> _preferences = {};
  bool _isLoading = true;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkBiometricAvailability();
  }

  Future<void> _loadSettings() async {
    try {
      final preferences = await _userService.getUserPreferences();
      setState(() {
        _preferences = preferences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: 'Failed to load settings: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await _biometricService.isAvailable();
    setState(() => _biometricAvailable = available);
  }

  Future<void> _updatePreference(String key, dynamic value) async {
    try {
      final updatedPreferences = {..._preferences, key: value};
      await _userService.updateUserPreferences(updatedPreferences);
      setState(() => _preferences = updatedPreferences);
      
      Fluttertoast.showToast(
        msg: 'Settings updated',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to update settings: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _handleSignOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _authService.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login-screen',
                  (route) => false,
                );
              } catch (e) {
                Fluttertoast.showToast(
                  msg: 'Failed to sign out: $e',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            SettingsSectionWidget(
              title: 'Appearance',
              children: [
                ThemeSelectorWidget(
                  currentTheme: _preferences['theme'] ?? 'light',
                  onThemeChanged: (theme) => _updatePreference('theme', theme),
                ),
                SettingsTileWidget(
                  title: 'Font Size',
                  subtitle: _preferences['fontSize'] ?? 'Medium',
                  icon: 'format_size',
                  onTap: () => _showFontSizeDialog(),
                ),
                SettingsTileWidget(
                  title: 'Font Family',
                  subtitle: _preferences['fontFamily'] ?? 'Inter',
                  icon: 'format_paint',
                  onTap: () => _showFontFamilyDialog(),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Security Section
            SettingsSectionWidget(
              title: 'Security',
              children: [
                if (_biometricAvailable)
                  SettingsTileWidget(
                    title: 'Biometric Authentication',
                    subtitle: 'Use fingerprint or face ID to unlock',
                    icon: 'fingerprint',
                    trailing: Switch(
                      value: _preferences['biometricEnabled'] ?? false,
                      onChanged: (value) => _updatePreference('biometricEnabled', value),
                    ),
                  ),
                SettingsTileWidget(
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  icon: 'lock',
                  onTap: () => _showChangePasswordDialog(),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Notifications Section
            SettingsSectionWidget(
              title: 'Notifications',
              children: [
                SettingsTileWidget(
                  title: 'Task Reminders',
                  subtitle: 'Get notified about upcoming tasks',
                  icon: 'notifications',
                  trailing: Switch(
                    value: _preferences['enableReminders'] ?? true,
                    onChanged: (value) => _updatePreference('enableReminders', value),
                  ),
                ),
                SettingsTileWidget(
                  title: 'AI Suggestions',
                  subtitle: 'Receive AI-powered productivity tips',
                  icon: 'auto_awesome',
                  trailing: Switch(
                    value: _preferences['enableAI'] ?? true,
                    onChanged: (value) => _updatePreference('enableAI', value),
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Data Section
            SettingsSectionWidget(
              title: 'Data & Storage',
              children: [
                SettingsTileWidget(
                  title: 'Export Data',
                  subtitle: 'Download your notes and tasks',
                  icon: 'download',
                  onTap: () => _exportData(),
                ),
                SettingsTileWidget(
                  title: 'Clear Cache',
                  subtitle: 'Free up storage space',
                  icon: 'clear_all',
                  onTap: () => _clearCache(),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // About Section
            SettingsSectionWidget(
              title: 'About',
              children: [
                SettingsTileWidget(
                  title: 'Version',
                  subtitle: '1.0.0',
                  icon: 'info',
                ),
                SettingsTileWidget(
                  title: 'Privacy Policy',
                  subtitle: 'View our privacy policy',
                  icon: 'privacy_tip',
                  onTap: () => _showPrivacyPolicy(),
                ),
                SettingsTileWidget(
                  title: 'Terms of Service',
                  subtitle: 'View terms and conditions',
                  icon: 'description',
                  onTap: () => _showTermsOfService(),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Sign Out Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSignOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'logout',
                      color: Colors.white,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Sign Out',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['small', 'medium', 'large'].map((size) {
            return RadioListTile<String>(
              title: Text(size.toUpperCase()),
              value: size,
              groupValue: _preferences['fontSize'],
              onChanged: (value) {
                Navigator.pop(context);
                _updatePreference('fontSize', value);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFontFamilyDialog() {
    final fonts = ['Inter', 'Roboto', 'Arial', 'Times New Roman', 'Georgia'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Family'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: fonts.map((font) {
            return RadioListTile<String>(
              title: Text(font, style: TextStyle(fontFamily: font)),
              value: font,
              groupValue: _preferences['fontFamily'],
              onChanged: (value) {
                Navigator.pop(context);
                _updatePreference('fontFamily', value);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    // Implementation for password change
    Fluttertoast.showToast(
      msg: 'Password change feature coming soon',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _exportData() {
    // Implementation for data export
    Fluttertoast.showToast(
      msg: 'Data export feature coming soon',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _clearCache() {
    // Implementation for cache clearing
    Fluttertoast.showToast(
      msg: 'Cache cleared successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showPrivacyPolicy() {
    // Implementation for privacy policy
    Fluttertoast.showToast(
      msg: 'Opening privacy policy...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showTermsOfService() {
    // Implementation for terms of service
    Fluttertoast.showToast(
      msg: 'Opening terms of service...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}