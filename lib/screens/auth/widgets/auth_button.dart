import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rememoji/widgets/rounded_container.dart';

enum AuthButtonType {
  google(iconAsset: 'assets/images/google.svg'),
  apple(iconAsset: 'assets/images/apple.svg'),
  facebook(iconAsset: 'assets/images/facebook.svg');

  final String iconAsset = '';

  const AuthButtonType({required String iconAsset});
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
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        child: RoundedContainer(
            child: SvgPicture.asset(
          'assets/images/google.svg',
          width: 24,
          height: 24,
        )),
      ),
    );
  }
}
