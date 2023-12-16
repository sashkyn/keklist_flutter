import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keklist/widgets/bool_widget.dart';

enum AuthButtonType {
  google(iconAsset: 'assets/auth_icons/google.svg'),
  apple(iconAsset: 'assets/auth_icons/apple.svg'),
  facebook(iconAsset: 'assets/auth_icons/facebook.svg'),
  offline(iconAsset: '');

  final String iconAsset;

  const AuthButtonType({required this.iconAsset});
}

class AuthButton extends StatelessWidget {
  final AuthButtonType type;
  final Function() onTap;

  const AuthButton({
    super.key,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66.0,
      height: 66.0,
      child: IconButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).cardColor),
          shadowColor: MaterialStateProperty.all<Color>(Theme.of(context).shadowColor),
          elevation: MaterialStateProperty.all<double>(5.0),
        ),
        onPressed: onTap,
        icon: BoolWidget(
          condition: type == AuthButtonType.offline,
          trueChild: const Icon(Icons.cloud_off_rounded),
          falseChild: SvgPicture.asset(
            type.iconAsset,
            width: 35.0,
            height: 35.0,
            colorFilter: type == AuthButtonType.apple ? ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn) : null,
          ),
        ),
      ),
    );
  }
}
