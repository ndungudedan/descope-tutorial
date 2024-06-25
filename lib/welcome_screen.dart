import 'package:descope/descope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

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
                  'https://auth.descope.io/${dotenv.get('DESCOPE_PROJECT_ID')}?flow=sign-up-or-in&debug=true',
              deepLinkUrl: 'https://your.deeplink.url/auth-android'),
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
    } on DescopeException catch (e) {
      switch (e) {
        case DescopeException.wrongOTPCode:
        case DescopeException.invalidRequest:
        case DescopeException.flowCancelled:
          print(e);
        default:
          print(e);
      }
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
