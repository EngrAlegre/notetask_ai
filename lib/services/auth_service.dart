import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseService _supabaseService = SupabaseService();

  // Mock credentials for preview mode
  final Map<String, String> _mockCredentials = {
    'admin@notetask.com': 'admin123',
    'user@notetask.com': 'user123',
    'demo@notetask.com': 'demo123',
  };

  // Get current user
  User? get currentUser {
    if (!_supabaseService.isConfigured) {
      return null;
    }
    return _supabaseService.syncClient.auth.currentUser;
  }

  // Check if user is authenticated
  bool get isAuthenticated {
    if (!_supabaseService.isConfigured) {
      return false;
    }
    return currentUser != null;
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (!_supabaseService.isConfigured) {
      throw Exception(
          'Supabase is not configured. Please check your environment variables.');
    }

    try {
      final client = await _supabaseService.client;
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'role': 'user',
        },
      );

      if (response.user != null && response.user!.emailConfirmedAt == null) {
        throw Exception(
            'Please check your email and click the confirmation link to verify your account.');
      }

      return response;
    } catch (error) {
      throw Exception('Sign up failed: ${error.toString()}');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_supabaseService.isConfigured) {
      // Mock authentication for preview mode
      if (_mockCredentials.containsKey(email) &&
          _mockCredentials[email] == password) {
        // Simulate successful login
        return AuthResponse(
          user: null,
          session: null,
        );
      } else {
        throw Exception(
            'Invalid credentials. Please check your email and password.');
      }
    }

    try {
      final client = await _supabaseService.client;
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (error) {
      throw Exception('Sign in failed: ${error.toString()}');
    }
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    if (!_supabaseService.isConfigured) {
      // Mock Google sign-in for preview mode
      await Future.delayed(const Duration(seconds: 2));
      return AuthResponse(
        user: null,
        session: null,
      );
    }

    try {
      final client = await _supabaseService.client;

      if (kIsWeb) {
        // Web OAuth flow
        final response = await client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: '${SupabaseService.supabaseUrl}/auth/v1/callback',
        );

        if (!response) {
          throw Exception('Google sign-in was cancelled or failed');
        }

        // Return empty response for web as the redirect handles the auth
        return AuthResponse(user: null, session: null);
      } else {
        // Mobile OAuth flow
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId:
              'your-google-client-id', // Configure in Google Cloud Console
        );

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('Google sign-in was cancelled');
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        if (accessToken == null || idToken == null) {
          throw Exception('Failed to get Google authentication tokens');
        }

        final response = await client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

        return response;
      }
    } catch (error) {
      throw Exception('Google sign-in failed: ${error.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (!_supabaseService.isConfigured) {
      return;
    }

    try {
      final client = await _supabaseService.client;
      await client.auth.signOut();
    } catch (error) {
      throw Exception('Sign out failed: ${error.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    if (!_supabaseService.isConfigured) {
      throw Exception('Password reset is not available in preview mode.');
    }

    try {
      final client = await _supabaseService.client;
      await client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: ${error.toString()}');
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    if (!_supabaseService.isConfigured) {
      return Stream.empty();
    }
    return _supabaseService.syncClient.auth.onAuthStateChange;
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!_supabaseService.isConfigured || !isAuthenticated) {
      return null;
    }

    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();

      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: ${error.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    if (!_supabaseService.isConfigured || !isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final client = await _supabaseService.client;
      final updates = <String, dynamic>{};

      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (preferences != null) updates['preferences'] = preferences;

      if (updates.isNotEmpty) {
        await client
            .from('user_profiles')
            .update(updates)
            .eq('id', currentUser!.id);
      }
    } catch (error) {
      throw Exception('Failed to update profile: ${error.toString()}');
    }
  }

  // Check if email is available
  Future<bool> isEmailAvailable(String email) async {
    if (!_supabaseService.isConfigured) {
      return !_mockCredentials.containsKey(email);
    }

    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('user_profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return response == null;
    } catch (error) {
      return false;
    }
  }
}
