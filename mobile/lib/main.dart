import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Игнорируем ошибки инициализации Firebase, чтобы UI работал
  // даже до того, как разработчик подложит реальный firebase_options.dart.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Splash и UI отрисуются, офферы покажут пустое состояние.
  }
  runApp(const ZaymyApp());
}

class ZaymyApp extends StatelessWidget {
  const ZaymyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Займы 24/7',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}
