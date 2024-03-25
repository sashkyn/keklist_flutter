import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:keklist/presentation/core/helpers/platform_utils.dart';
import 'package:keklist/presentation/core/widgets/bool_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/screens/auth/widgets/auth_button.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:keklist/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:keklist/domain/constants.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> with DisposeBag {
  final TextEditingController _loginTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    subscribeTo<AuthBloc>(onNewState: (state) {
      switch (state) {
        case AuthCurrentState status when status.isLoggedIn:
          _dismiss();
      }
    })?.disposed(by: this);

    subscribeTo<SettingsBloc>(onNewState: (state) {
      if (state is SettingsDataState && state.isOfflineMode) {
        _dismiss();
      }
    })?.disposed(by: this);
  }

  void _dismiss() {
    Navigator.of(context).popUntil((route) => route.isFirst);
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
              Text(
                'Sign in',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: TextFormField(
                  validator: MultiValidator([
                    EmailValidator(errorText: 'Enter a valid email address'),
                    MinLengthValidator(4, errorText: 'Please enter email'),
                  ]).call,
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
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
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
                child: SizedBox(
                  width: 100,
                  height: 44,
                  child: Center(
                      child: Text(
                    'Get magic link',
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  )),
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'or continue with social networks:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BoolWidget(
                    condition: DeviceUtils.safeGetPlatform() == SupportedPlatform.iOS,
                    trueChild: AuthButton(
                      onTap: () => sendEventTo<AuthBloc>(AuthLoginWithSocialNetwork.apple()),
                      type: AuthButtonType.apple,
                    ),
                    falseChild: const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 16.0),
                  AuthButton(
                    onTap: () => sendEventTo<AuthBloc>(AuthLoginWithSocialNetwork.google()),
                    type: AuthButtonType.google,
                  ),
                  const SizedBox(width: 16.0),
                  AuthButton(
                    onTap: () => sendEventTo<AuthBloc>(AuthLoginWithSocialNetwork.facebook()),
                    type: AuthButtonType.facebook,
                  ),
                  const SizedBox(width: 16.0),
                  AuthButton(
                    onTap: () {
                      sendEventTo<SettingsBloc>(const SettingsChangeOfflineMode(isOfflineMode: true));
                      _dismiss();
                    },
                    type: AuthButtonType.offline,
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              TextButton(
                onPressed: () => launchUrlString(KeklistConstants.termsOfUseURL),
                child: Text(
                  'Terms of use',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    cancelSubscriptions();
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
