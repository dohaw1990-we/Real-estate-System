import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'services/firebase_service.dart';
import 'services/rental_office_service.dart';
import 'pages/admin_home_page.dart';
import 'pages/buildings_management_page.dart';
import 'pages/rental_admin_dashboard_page.dart';
import 'pages/units_management_page.dart';
import 'widgets/app_islamic_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web requires explicit FirebaseOptions when no generated firebase_options.dart exists.
  try {
    if (kIsWeb) {
      const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
      const appId = String.fromEnvironment('FIREBASE_APP_ID');
      const messagingSenderId = String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID',
      );
      const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
      const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
      const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
      const measurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

      final hasRequiredWebOptions =
          apiKey.isNotEmpty &&
          appId.isNotEmpty &&
          messagingSenderId.isNotEmpty &&
          projectId.isNotEmpty;

      if (hasRequiredWebOptions) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: apiKey,
            appId: appId,
            messagingSenderId: messagingSenderId,
            projectId: projectId,
            authDomain: authDomain.isNotEmpty ? authDomain : null,
            storageBucket: storageBucket.isNotEmpty ? storageBucket : null,
            measurementId: measurementId.isNotEmpty ? measurementId : null,
          ),
        );
      }
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeController()),
        ChangeNotifierProvider(create: (context) => FirebaseService()),
        ChangeNotifierProvider(create: (context) => RentalOfficeService()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp(
          title: 'Real Estate App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          builder: (context, child) {
            return Stack(
              children: [
                const Positioned.fill(child: AppIslamicBackground()),
                if (child != null) child,
              ],
            );
          },
          initialRoute: '/',
          routes: {
            '/': (context) => const AdminHomePage(),
            '/dashboard': (context) => const RentalAdminDashboardPage(),
            '/buildings': (context) => const BuildingsManagementPage(),
            '/units': (context) {
              final arg = ModalRoute.of(context)?.settings.arguments;
              return UnitsManagementPage(
                preselectedBuildingId: arg is String ? arg : null,
              );
            },
          },
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
