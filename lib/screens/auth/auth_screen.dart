import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zenmode/blocs/auth_bloc/auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final _loginTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    context.read<AuthBloc>().stream.listen((state) {
      if (state is AuthLoggedIn) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ModalScrollController.of(context),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Material(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16.0),
              const Text(
                'Sign in',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _loginTextEditingController,
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(8),
                  border: UnderlineInputBorder(),
                  hintText: 'Email',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () async {
                  context.read<AuthBloc>().add(AuthLoginWithEmail(_loginTextEditingController.text));
                  // TODO: показать алерт на экшен в блоке.
                  showOkAlertDialog(
                    context: context,
                    title: 'Success',
                    message: 'Please, go to your email app and open magic link',
                  );
                },
                child: const SizedBox(
                  width: 100,
                  height: 44,
                  child: Center(
                      child: Text(
                    'Get magic link',
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'or continue with social networks:',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppleAuthButton(
                    onPressed: () => context.read<AuthBloc>().add(AuthLoginWithSocialNetwork(SocialNetwork.apple)),
                    style: const AuthButtonStyle(
                      buttonType: AuthButtonType.icon,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  GoogleAuthButton(
                    onPressed: () => context.read<AuthBloc>().add(AuthLoginWithSocialNetwork(SocialNetwork.google)),
                    style: const AuthButtonStyle(
                      buttonType: AuthButtonType.icon,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  FacebookAuthButton(
                    onPressed: () => context.read<AuthBloc>().add(AuthLoginWithSocialNetwork(SocialNetwork.facebook)),
                    style: const AuthButtonStyle(
                      buttonType: AuthButtonType.icon,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'By processing you agree',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.0,
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: 'Terms of use',
                        style: const TextStyle(
                          color: Color(0xFF2F80ED),
                          fontSize: 12.0,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrlString(
                              'vk.com',
                              mode: LaunchMode.inAppWebView,
                            );
                          },
                      ),
                      const TextSpan(text: ' '),
                      const TextSpan(
                        text: 'and confirm that you have red',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.0,
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: 'Privacy policy',
                        style: const TextStyle(
                          color: Color(0xFF2F80ED),
                          fontSize: 12.0,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrlString(
                              'facebook.com',
                              mode: LaunchMode.inAppWebView,
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
