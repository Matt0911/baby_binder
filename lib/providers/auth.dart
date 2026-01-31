import 'package:baby_binder/constants.dart';
import 'package:baby_binder/screens/child_selection_page.dart';
import 'package:baby_binder/widgets/fb_widgets.dart';
import 'package:flutter/material.dart';

enum ApplicationLoginState {
  loggedOut,
  emailAddress,
  register,
  password,
  loggedIn,
}

const kInputDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  border: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.white),
    borderRadius: BorderRadius.all(Radius.circular(25.7)),
  ),
  errorStyle: TextStyle(fontSize: 14, color: Colors.white),
);

final kButtonStyle = ButtonStyle(
  backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF4DB6AC)),
);

class Authentication extends StatelessWidget {
  const Authentication({
    super.key,
    required this.loginState,
    required this.email,
    required this.startLoginFlow,
    required this.verifyEmail,
    required this.signInWithEmailAndPassword,
    required this.cancelRegistration,
    required this.registerAccount,
    required this.signOut,
  });

  final ApplicationLoginState loginState;
  final String? email;
  final void Function() startLoginFlow;
  final void Function(
    String email,
    void Function(Exception e) error,
  ) verifyEmail;
  final void Function(
    BuildContext context,
    String email,
    String password,
    void Function() success,
    void Function(Exception e) error,
  ) signInWithEmailAndPassword;
  final void Function() cancelRegistration;
  final void Function(
    BuildContext context,
    String email,
    String displayName,
    String password,
    void Function(Exception e) error,
  ) registerAccount;
  final void Function(BuildContext context) signOut;

  Widget _getBody(BuildContext context) {
    switch (loginState) {
      case ApplicationLoginState.loggedOut:
      case ApplicationLoginState.emailAddress:
        return EmailForm(
            callback: (email) => verifyEmail(
                email, (e) => _showErrorDialog(context, 'Invalid email', e)));
      case ApplicationLoginState.password:
        return PasswordForm(
          email: email!,
          login: (email, password) {
            signInWithEmailAndPassword(
                context,
                email,
                password,
                () =>
                    Navigator.pushNamed(context, ChildSelectionPage.routeName),
                (e) => _showErrorDialog(context, 'Failed to sign in', e));
          },
        );
      case ApplicationLoginState.register:
        return RegisterForm(
          email: email!,
          cancel: () {
            cancelRegistration();
          },
          registerAccount: (
            email,
            displayName,
            password,
          ) {
            registerAccount(
                context,
                email,
                displayName,
                password,
                (e) =>
                    _showErrorDialog(context, 'Failed to create account', e));
          },
        );
      case ApplicationLoginState.loggedIn:
        // Navigator.pushNamed(context, ChildSelectionPage.routeName);
        return const SizedBox();
      default:
        return Row(
          children: const [
            Text("Internal error, this shouldn't happen..."),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  'Baby Binder',
                  style: kTitleDarkTextStyle,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _getBody(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, Exception e) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 24),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '${(e as dynamic).message}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            StyledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
  }
}

class EmailForm extends StatefulWidget {
  const EmailForm({super.key, required this.callback});
  final void Function(String email) callback;
  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_EmailFormState');
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: TextFormField(
          controller: _controller,
          onFieldSubmitted: (_) {
            if (_formKey.currentState!.validate()) {
              widget.callback(_controller.text);
            }
          },
          decoration: InputDecoration(
            filled: kInputDecoration.filled,
            fillColor: kInputDecoration.fillColor,
            hintText: 'Enter your email',
            suffixIcon: IconButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.callback(_controller.text);
                  }
                },
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.teal,
                )),
            border: kInputDecoration.border,
            errorStyle: kInputDecoration.errorStyle,
          ),
          // style: TextStyle(color: Colors.white),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Enter your email address to continue';
            }
            return null;
          },
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
    required this.registerAccount,
    required this.cancel,
    required this.email,
  });
  final String email;
  final void Function(String email, String displayName, String password)
      registerAccount;
  final void Function() cancel;
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_RegisterFormState');
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      widget.registerAccount(
        _emailController.text,
        _displayNameController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Create account',
          style: kTitle2DarkTextStyle,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: kInputDecoration.filled,
                      fillColor: kInputDecoration.fillColor,
                      hintText: 'Enter your email',
                      border: kInputDecoration.border,
                      errorStyle: kInputDecoration.errorStyle,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email address to continue';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      filled: kInputDecoration.filled,
                      fillColor: kInputDecoration.fillColor,
                      hintText: 'Enter your name',
                      border: kInputDecoration.border,
                      errorStyle: kInputDecoration.errorStyle,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your account name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _passwordController,
                    onFieldSubmitted: (val) => submit(),
                    decoration: InputDecoration(
                      filled: kInputDecoration.filled,
                      fillColor: kInputDecoration.fillColor,
                      hintText: 'Enter your password',
                      suffixIcon: IconButton(
                          onPressed: submit,
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.teal,
                          )),
                      border: kInputDecoration.border,
                      errorStyle: kInputDecoration.errorStyle,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.cancel,
                        child: const Text('CANCEL',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: kButtonStyle,
                        onPressed: submit,
                        child: const Text('REGISTER'),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordForm extends StatefulWidget {
  const PasswordForm({
    super.key,
    required this.login,
    required this.email,
  });
  final String email;
  final void Function(String email, String password) login;
  @override
  _PasswordFormState createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_PasswordFormState');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      widget.login(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Sign in',
          style: kTitle2DarkTextStyle,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: kInputDecoration.filled,
                      fillColor: kInputDecoration.fillColor,
                      hintText: 'Enter your email',
                      border: kInputDecoration.border,
                      errorStyle: kInputDecoration.errorStyle,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email address to continue';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _passwordController,
                    autofocus: true,
                    onFieldSubmitted: (val) => submit(),
                    decoration: InputDecoration(
                      filled: kInputDecoration.filled,
                      fillColor: kInputDecoration.fillColor,
                      hintText: 'Enter your password',
                      suffixIcon: IconButton(
                          onPressed: submit,
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.teal,
                          )),
                      border: kInputDecoration.border,
                      errorStyle: kInputDecoration.errorStyle,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: kButtonStyle,
                        onPressed: submit,
                        child: const Text('SIGN IN'),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
