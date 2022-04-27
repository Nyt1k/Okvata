import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktava/services/auth/bloc/auth_bloc.dart';
import 'package:oktava/services/auth/bloc/auth_event.dart';
import 'package:oktava/services/auth/bloc/auth_state.dart';
import 'package:oktava/utilities/dialogs/error_dialog.dart';
import 'package:oktava/utilities/dialogs/password_reset_email_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSendEmail) {
            _controller.clear();
            await showPasswordResetSendDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(context,
                'We could`n process your request, please try again or create new user account');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Restore password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                  'Enter you email and we will send you password reset mail.'),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Your email address...',
                ),
              ),
              TextButton(
                onPressed: () {
                  final email = _controller.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgotPassword(email: email));
                },
                child: const Text('Send me password'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: const Text('Back to login page'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
