import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mash_grower_mobile/app.dart';
import 'package:mash_grower_mobile/core/config/app_config.dart';
import 'package:mash_grower_mobile/core/config/theme_config.dart';
import 'package:mash_grower_mobile/presentation/providers/auth_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/registration_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/sensor_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/device_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/notification_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/theme_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/forgot_password_provider.dart';

class TestMASHGrowerApp extends StatelessWidget {
  const TestMASHGrowerApp({super.key});

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
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
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
