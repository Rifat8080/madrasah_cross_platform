import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

import 'core/database/database_helper.dart';
import 'providers/student_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/salary_provider.dart';
import 'providers/accounting_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/students/student_list_screen.dart';
import 'screens/students/student_form_screen.dart';
import 'screens/staff/staff_list_screen.dart';
import 'screens/staff/staff_form_screen.dart';
import 'screens/salary/salary_management_screen.dart';
import 'screens/accounting/accounting_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/data_sync/data_sync_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database (guarded for web where path_provider / sqflite plugins may be missing)
  try {
    if (!kIsWeb) {
      await DatabaseHelper.instance.database;
    }
  } catch (e) {
    debugPrint('Database initialization skipped or failed: $e');
  }
  
  // Initialize window manager for desktop
  // Initialize window manager for desktop platforms only
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Madrasah Management System',
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  
  runApp(const MadrasahManagementApp());
}

class MadrasahManagementApp extends StatelessWidget {
  const MadrasahManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => SalaryProvider()),
        ChangeNotifierProvider(create: (_) => AccountingProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'Madrasah Management System',
            theme: ThemeData(
              primarySwatch: Colors.teal,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 2,
              ),
              cardTheme: CardThemeData(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.teal,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 2,
              ),
              cardTheme: CardThemeData(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            routerConfig: _createRouter(authProvider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: authProvider.isAuthenticated ? '/dashboard' : '/login',
      redirect: (context, state) {
        final bool isAuthenticated = authProvider.isAuthenticated;
        final bool isLoggingIn = state.matchedLocation == '/login';

        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }

        if (isAuthenticated && isLoggingIn) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/students',
          builder: (context, state) => const StudentListScreen(),
        ),
        GoRoute(
          path: '/students/add',
          builder: (context, state) => const StudentFormScreen(),
        ),
        GoRoute(
          path: '/students/edit/:id',
          builder: (context, state) => StudentFormScreen(
            studentId: int.tryParse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/staff',
          builder: (context, state) => const StaffListScreen(),
        ),
        GoRoute(
          path: '/staff/add',
          builder: (context, state) => const StaffFormScreen(),
        ),
        GoRoute(
          path: '/staff/edit/:id',
          builder: (context, state) => StaffFormScreen(
            staffId: int.tryParse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/salary',
          builder: (context, state) => const SalaryManagementScreen(),
        ),
        GoRoute(
          path: '/accounting',
          builder: (context, state) => const AccountingScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/data-sync',
          builder: (context, state) => const DataSyncScreen(),
        ),
      ],
    );
  }
}
