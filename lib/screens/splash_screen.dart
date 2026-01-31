import 'package:flutter/material.dart';

import '../constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen(
      {super.key,
      required this.onFinished,
      required this.splashMaxDurationInSec});
  final Function onFinished;
  final int splashMaxDurationInSec;

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration(seconds: splashMaxDurationInSec),
      () => onFinished(),
    );

    return const Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Text(
          'Baby Binder',
          style: kTitleDarkTextStyle,
        ),
      ),
    );
  }
}
