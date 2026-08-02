import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/app_state.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FlutterLogoGeneratorApp());
}

class FlutterLogoGeneratorApp extends StatelessWidget {
  const FlutterLogoGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'FLogo Generator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.bg,
          fontFamily: 'SpaceGrotesk',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.accent,
            brightness: Brightness.dark,
            surface: AppColors.surface,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
