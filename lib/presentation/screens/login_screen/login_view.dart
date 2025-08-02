import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milestone_social/presentation/screens/login_screen/widgets/login_password_field.dart';
import 'package:milestone_social/presentation/screens/login_screen/widgets/login_phone_field.dart';

import '../../../bloc/login/login_cubit.dart';
import '../../../bloc/login/login_state.dart';
import '../navigation/role_based_navigation.dart';
import '../../../generated/l10n.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Add controllers and a form key
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // Validate the form before proceeding
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(S.of(context).login), elevation: 0),
      // Use BlocConsumer to listen and build based on LoginState
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
          } else if (state is LoginSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(S.of(context).welcome(state.user.firstName)),
                ),
              );
            // Navigate to the role-based navigation on success
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => RoleBasedNavigation(user: state.user),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginLoading;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              // Use a Form widget with the form key
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      S.of(context).welcomeBack,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).loginToAccount,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Use the updated widgets with controllers
                    LoginNameField(controller: _usernameController),
                    const SizedBox(height: 16),
                    LoginPasswordField(controller: _passwordController),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      // Disable button when loading, otherwise call _login
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: Colors.white,
                        textStyle: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      // Show a loading indicator or the text
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(S.of(context).login),
                    ),
                    // ... your other widgets like the theme switcher button
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
