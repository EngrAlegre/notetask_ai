import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/overview_screen/overview_screen.dart';
import '../presentation/notes_screen/notes_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String loginScreen = '/login-screen';
  static const String registrationScreen = '/registration-screen';
  static const String overviewScreen = '/overview-screen';
  static const String notesScreen = '/notes-screen';
  static const String tasksScreen = '/tasks-screen';
  static const String aiAssistantScreen = '/ai-assistant-screen';
  static const String noteEditor = '/note-editor';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    loginScreen: (context) => const LoginScreen(),
    registrationScreen: (context) => const RegistrationScreen(),
    overviewScreen: (context) => const OverviewScreen(),
    notesScreen: (context) => const NotesScreen(),
    tasksScreen: (context) => const TasksScreen(),
    aiAssistantScreen: (context) => const AiAssistantScreen(),
    noteEditor: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return NoteEditorScreen(
        noteId: args?['noteId'],
        type: args?['type'] ?? 'note',
      );
    },
    // TODO: Add your other routes here
  };
}
