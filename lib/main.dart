import 'package:flutter/material.dart';
import 'package:pass_log/pages/login.dart';
import 'package:pass_log/pages/updatep.dart';
import 'package:pass_log/pages/getemail.dart';
import 'package:pass_log/pages/fpassword.dart';
import 'package:pass_log/pages/chat_page.dart';
import 'package:pass_log/pages/hives_page.dart';
import 'package:pass_log/pages/insights_page.dart';
import 'package:pass_log/pages/report_page.dart';
import 'package:pass_log/pages/notification_settings.dart';
import 'package:pass_log/pages/recommendations_page.dart';
import 'package:pass_log/pages/todo_page.dart';
import 'package:pass_log/pages/dashboard.dart';
import 'package:pass_log/pages/notification_service.dart';
import 'package:pass_log/pages/notification_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  try {
    await NotificationService().initialize();
    await NotificationManager().initialize();
  } catch (e) {
    print('Error initializing notification system: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BeeHive Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber.shade800,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      routes: {
        '/login': (context) => const LoginScreen(title: ''),
        '/fpassword': (context) => const ForgotPassword(),
        '/dashboard': (context) => const MyHomePage(title: 'Dashboard'),
        '/updateBeekeeper': (context) => UpdateBeekeeperScreen(
              beekeeperEmail:
                  ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/get_email': (context) => const GetEmailScreen(),
        '/chat': (context) => const ChatPage(userId: 'user123'),
        '/hives': (context) => const HivesPage(),
        '/insights': (context) => const InsightsPage(),
        '/reports': (context) => const ReportsPage(),
        '/notifications': (context) => const NotificationSettingsScreen(),
        '/recommendations': (context) => const RecommendationsPage(),
        '/todo': (context) => const TodoPage(),
      },
      initialRoute: '/login',
    );
  }
}
