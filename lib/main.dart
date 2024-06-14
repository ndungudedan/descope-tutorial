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
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
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
            } catch (e) {}
            return '/';
          },
        ),
        GoRoute(
          path:
              'magiclink', // This path needs to correspond to the deep link you configured in your manifest
          redirect: (context, state) async {
            try {
              await Descope.flow.resume(state
                  .uri); // Resume the flow after returning from a magic link
            } catch (e) {}
            return '/';
          },
        ),
      ],
    ),
  ],
);

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Future<void> signupOrLogin() async {
    try {
      final options = DescopeFlowOptions(
          mobile: DescopeMobileFlowOptions(
              flowUrl:
                  'https://auth.descope.io/login/${dotenv.get('DESCOPE_PROJECT_ID')}',
              deepLinkUrl: 'auth-android'),
          web: DescopeWebFlowOptions(
            flowId: 'sign-up-or-in',
            flowContainerCss: {
              "background-color": "antiquewhite",
              "width": "500px",
              "min-height": "300px",
              "margin": "auto",
              "position": "relative",
              "top": "50%",
              "transform": "translateY(-50%)",
              "display": "flex",
              "flex-direction": "column",
              "align-items": "center",
              "justify-content": "center",
              "box-shadow": "0px 0px 10px gray",
            },
          ));
      final authResponse = await Descope.flow.start(options);
      final session = DescopeSession.fromAuthenticationResponse(authResponse);
      Descope.sessionManager.manageSession(session);

      if (!mounted) return;
      context.pushReplacementNamed('home');
    } catch (e) {
      print('Error: $e');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authenticate With Descope'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signupOrLogin,
              child: const Text('Sign Up or Login'),
            )
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DescopeSession? session = Descope.sessionManager.session;

  Future<void> _logout() async {
    final refreshJwt = Descope.sessionManager.session?.refreshJwt;
    if (refreshJwt != null) {
      await Descope.auth.logout(refreshJwt);
      Descope.sessionManager.clearSession();
    }

    if (!mounted) return;
    context.pushReplacementNamed('welcome');
  }

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user data available'),
        ),
      );
    }
    DescopeUser userInfo = session!.user;
    List<String> permissions =
        Descope.sessionManager.session?.permissions() ?? [];
    List<String> roles = Descope.sessionManager.session?.roles() ?? [];
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hi, ${userInfo!.name}!',
              textAlign: TextAlign.center,
            ),
            Text('Your roles in the comapny are: ${roles}'),
            roles.contains("Accountant")
                ? ElevatedButton(
                    onPressed: () {}, child: const Text('View Transactions'))
                : SizedBox.shrink(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Log out'),
            )
          ],
        ),
      ),
    );
  }
}
