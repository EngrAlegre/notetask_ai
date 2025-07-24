import './auth_service.dart';
import './supabase_service.dart';
import './notes_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  final NotesService _notesService = NotesService();

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      return null;
    }

    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', _authService.currentUser!.id)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: ${error.toString()}');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
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
        updates['updated_at'] = DateTime.now().toIso8601String();

        final response = await client
            .from('user_profiles')
            .update(updates)
            .eq('id', _authService.currentUser!.id)
            .select()
            .single();

        return response;
      }

      return await getCurrentUserProfile() ?? {};
    } catch (error) {
      throw Exception('Failed to update profile: ${error.toString()}');
    }
  }

  // Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      return {
        'theme': 'light',
        'fontSize': 'medium',
        'fontFamily': 'Inter',
        'enableReminders': true,
        'enableAI': true,
      };
    }

    try {
      final profile = await getCurrentUserProfile();
      return profile?['preferences'] ??
          {
            'theme': 'light',
            'fontSize': 'medium',
            'fontFamily': 'Inter',
            'enableReminders': true,
            'enableAI': true,
          };
    } catch (error) {
      throw Exception('Failed to get preferences: ${error.toString()}');
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      return;
    }

    try {
      await updateUserProfile(preferences: preferences);
    } catch (error) {
      throw Exception('Failed to update preferences: ${error.toString()}');
    }
  }

  // Get user statistics using NotesService
  Future<Map<String, dynamic>> getUserStatistics() async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      return {
        'total_notes': 0,
        'total_tasks': 0,
        'completed_tasks': 0,
        'completion_rate': 0.0,
        'notes_this_week': 0,
        'tasks_this_week': 0,
      };
    }

    try {
      final notesStats = await _notesService.getNotesStatistics();

      return {
        'total_notes': notesStats['total_notes'] ?? 0,
        'total_tasks': notesStats['total_tasks'] ?? 0,
        'completed_tasks': notesStats['completed_tasks'] ?? 0,
        'completion_rate': notesStats['completion_rate'] ?? 0.0,
        'notes_this_week': 0, // Could be calculated if needed
        'tasks_this_week': 0, // Could be calculated if needed
      };
    } catch (error) {
      // Return default values if notes service fails
      return {
        'total_notes': 0,
        'total_tasks': 0,
        'completed_tasks': 0,
        'completion_rate': 0.0,
        'notes_this_week': 0,
        'tasks_this_week': 0,
      };
    }
  }

  // Check if user has premium features
  Future<bool> isPremiumUser() async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      return false;
    }

    try {
      final profile = await getCurrentUserProfile();
      return profile?['role'] == 'premium';
    } catch (error) {
      return false;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      return false;
    }

    try {
      final profile = await getCurrentUserProfile();
      return profile?['role'] == 'admin';
    } catch (error) {
      return false;
    }
  }

  // Get user by ID (admin only)
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      return null;
    }

    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (error) {
      throw Exception('Failed to get user: ${error.toString()}');
    }
  }

  // Search users (admin only)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      return [];
    }

    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('user_profiles')
          .select()
          .or('email.ilike.%$query%,first_name.ilike.%$query%,last_name.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search users: ${error.toString()}');
    }
  }
}
