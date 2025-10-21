import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/theme_config.dart';
import 'core/config/environment.dart';
import 'core/services/session_service.dart';
import 'firebase_options.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/registration_provider.dart';
import 'presentation/providers/sensor_provider.dart';
import 'presentation/providers/device_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'data/datasources/local/database_helper.dart' if (dart.library.html) 'data/datasources/local/database_helper_web.dart';
import 'core/utils/logger.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Logger.info('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set environment (change this for production builds)
  EnvironmentConfig.setEnvironment(Environment.development);
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize background message handler (skip on web)
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  
  // Initialize database (skip on web for now)
  // if (!kIsWeb) {
  //   await DatabaseHelper.instance.database;
  // }
  
  // Initialize session service
  await SessionService().initialize();
  
  runApp(const MASHGrowerApp());
}

class MASHGrowerApp extends StatelessWidget {
  const MASHGrowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const App(),
          );
        },
      ),
    );
  }
}
