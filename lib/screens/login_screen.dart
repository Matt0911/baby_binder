import 'package:baby_binder/providers/app_state.dart';
import 'package:baby_binder/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  static const String routeName = '/login-page';

  const LoginScreen({super.key});

  @override
  Widget build(context, ref) {
    final authState = ref.watch(appStateProvider);
    return Authentication(
      loginState: authState.loginState,
      email: authState.email,
      startLoginFlow: authState.startLoginFlow,
      verifyEmail: authState.verifyEmail,
      signInWithEmailAndPassword: authState.signInWithEmailAndPassword,
      cancelRegistration: authState.cancelRegistration,
      registerAccount: authState.registerAccount,
      signOut: authState.signOut,
    );
  }
}
