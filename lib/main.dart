import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'helper/storage_service.dart';
import 'provider/cart_provider.dart'; // Ensure this file exists and is correctly implemented
import 'provider/cart_storage_web.dart';
import 'splash/splash_screen.dart';

void main() async {
  /// Ensure that Flutter bindings are initialized before calling asynchronous operations
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.setItem('appStarted', 'true');

  /// Start the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => CartStorageHelper()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriveMart',
      theme: ThemeData(
        /// Use `ColorScheme` for consistent theming
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true, // Material 3 design
      ),
      home: const SplashScreen(), // Initial screen is SplashScreen
    );
  }
}
