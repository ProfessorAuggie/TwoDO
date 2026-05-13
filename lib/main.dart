import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:twodo/firebase_options.dart';
import 'package:twodo/core/theme/app_theme.dart';
import 'package:twodo/routes/app_router.dart';
import 'package:twodo/presentation/providers/auth_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state to determine initial route
    final authState = ref.watch(authStateProvider);
    final router = AppRouter.router(authState);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Twoदो',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
