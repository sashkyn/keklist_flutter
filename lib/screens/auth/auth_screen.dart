import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rememoji/screens/auth/widgets/auth_button.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:rememoji/blocs/auth_bloc/auth_bloc.dart';
import 'package:rememoji/constants.dart';
import 'package:rememoji/helpers/extensions/dispose_bag.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> with DisposeBag {
  final _loginTextEditingController = TextEditingController();
  final _passwordTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    context.read<AuthBloc>().stream.listen((state) {
      if (state is AuthLoggedIn) {
        // NOTE: возвращаемся к главному экрану.
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }).disposed(by: this);
  }

  @override
  void dispose() {
    super.dispose();

    cancelSubscriptions();
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
              Form(
                key: _formKey,
                child: TextFormField(
                  validator: MultiValidator([
                    EmailValidator(errorText: 'Enter a valid email address'),
                    MinLengthValidator(4, errorText: 'Please enter email'),
                  ]),
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
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () async {
                  if (_loginTextEditingController.text == KeklistConstants.demoAccountEmail) {
                    _displayTextInputDialog(
                      context,
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              AuthLoginWithEmailAndPassword(
                                email: _loginTextEditingController.text,
                                password: _passwordTextEditingController.text,
                              ),
                            );
                      },
                    );
                    return;
                  }
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
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
                  AuthButton(
                    onTap: () => context.read<AuthBloc>().add(AuthLoginWithSocialNetwork(SocialNetwork.apple)),
                    type: AuthButtonType.apple
                  ),
                  const SizedBox(width: 16.0),
                  AuthButton(
                    onTap: () => context.read<AuthBloc>().add(AuthLoginWithSocialNetwork(SocialNetwork.google)),
                    type: AuthButtonType.google
                  ),
                  const SizedBox(width: 16.0),
                  AuthButton(
                    onTap: () => context.read<AuthBloc>().add(AuthLoginWithSocialNetwork(SocialNetwork.facebook)),
                    type: AuthButtonType.facebook
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              TextButton(
                onPressed: () => launchUrlString(KeklistConstants.termsOfUseURL),
                child: const Text(
                  'Terms of use',
                  style: TextStyle(color: Colors.blue),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _displayTextInputDialog(
    BuildContext context, {
    required VoidCallback onPressed,
  }) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Password'),
            content: TextField(
              controller: _passwordTextEditingController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                hintText: "Enter password",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: onPressed,
                ),
              ),
            ),
          );
        });
  }
}
