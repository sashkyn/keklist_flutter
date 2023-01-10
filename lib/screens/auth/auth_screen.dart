import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      if (state is LoggedIn) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
              context.read<AuthBloc>().add(LoginWithEmail(_loginTextEditingController.text));
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
                onPressed: () => context.read<AuthBloc>().add(LoginWithSocialNetwork(SocialNetwork.apple)),
                style: const AuthButtonStyle(
                  buttonType: AuthButtonType.icon,
                ),
              ),
              const SizedBox(width: 16.0),
              GoogleAuthButton(
                onPressed: () => context.read<AuthBloc>().add(LoginWithSocialNetwork(SocialNetwork.google)),
                style: const AuthButtonStyle(
                  buttonType: AuthButtonType.icon,
                ),
              ),
              const SizedBox(width: 16.0),
              FacebookAuthButton(
                onPressed: () => context.read<AuthBloc>().add(LoginWithSocialNetwork(SocialNetwork.facebook)),
                style: const AuthButtonStyle(
                  buttonType: AuthButtonType.icon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
