import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _registerMode = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _mapError(AppLocalizations l10n, FirebaseAuthException e) =>
      switch (e.code) {
        'invalid-credential' ||
        'user-not-found' ||
        'wrong-password' =>
          l10n.authErrorInvalidCredentials,
        'email-already-in-use' => l10n.authErrorEmailInUse,
        'weak-password' => l10n.authErrorWeakPassword,
        'invalid-email' => l10n.authErrorInvalidEmail,
        _ => l10n.authErrorGeneric,
      };

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (_registerMode) {
        await auth.createUserWithEmailAndPassword(
            email: email, password: password);
      } else {
        await auth.signInWithEmailAndPassword(
            email: email, password: password);
      }
      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapError(l10n, e));
    } catch (_) {
      setState(() => _error = l10n.authErrorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title =
        _registerMode ? l10n.authRegisterTitle : l10n.authLoginTitle;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration:
                          InputDecoration(labelText: l10n.emailLabel),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.fieldRequired;
                        }
                        if (!v.contains('@')) return l10n.authErrorInvalidEmail;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration:
                          InputDecoration(labelText: l10n.passwordLabel),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.fieldRequired;
                        if (v.length < 6) return l10n.authErrorWeakPassword;
                        return null;
                      },
                    ),
                    if (_registerMode) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: l10n.confirmPasswordLabel),
                        validator: (v) => v != _passwordController.text
                            ? l10n.passwordMismatch
                            : null,
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_registerMode
                              ? l10n.authRegisterButton
                              : l10n.authLoginButton),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                                _registerMode = !_registerMode;
                                _error = null;
                              }),
                      child: Text(_registerMode
                          ? l10n.authSwitchToLogin
                          : l10n.authSwitchToRegister),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
