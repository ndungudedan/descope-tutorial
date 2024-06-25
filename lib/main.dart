import 'package:descope_app/home_screen.dart';
import 'package:descope_app/welcome_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:descope/descope.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  // WidgetsFlutterBinding must be initialized before loading the Descope session manager
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Descope.setup(dotenv.get('DESCOPE_PROJECT_ID'), (config) {
    if (kDebugMode) {
      config.logger = DescopeLogger();
    }
  });
  await Descope.sessionManager.loadSession();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Descope Flutter Sample App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) =>
                Descope.sessionManager.session?.refreshToken.isExpired == false
                    ? const HomeScreen()
                    : const WelcomeScreen(),
            routes: [
              GoRoute(
                path: 'home',
                name: 'home',
                builder: (_, __) => const HomeScreen(),
              ),
              GoRoute(
                path: 'welcome',
                name: 'welcome',
                builder: (_, __) => const WelcomeScreen(),
              ),
              GoRoute(
                path: 'auth-android',
                redirect: (context, state) {
                  try {
                    Descope.flow.exchange(state.uri);
                  } catch (e) {
                    print(e);
                  }
                  return '/';
                },
              ),
              GoRoute(
                path: 'magiclink',
                redirect: (context, state) async {
                  try {
                    await Descope.flow.resume(state.uri);
                  } catch (e) {
                    print(e);
                  }
                  return '/';
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
