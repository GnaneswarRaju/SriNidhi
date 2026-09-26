import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'auth_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});
  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final expanded = constraints.maxWidth >= 1024;
            return Row(
              children: [
                if (expanded)
                  Expanded(
                    flex: 5,
                    child: ColoredBox(
                      color: StoreTheme.ink,
                      child: SizedBox.expand(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(56),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.appTitle.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Text(
                                l.brandHeadline,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                l.brandBody,
                                style: const TextStyle(
                                  color: Color(0xFFDDD7E8),
                                  fontSize: 20,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Text(
                                l.productLabel,
                                style: const TextStyle(
                                  color: Color(0xFFDDD7E8),
                                  fontSize: 12,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 7,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 48,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: AutofillGroup(
                          child: Form(
                            key: _form,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!expanded) ...[
                                  Icon(
                                    Icons.storefront_outlined,
                                    size: 40,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(height: 32),
                                ],
                                Text(
                                  l.welcome,
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Text(l.signInSubtitle),
                                const SizedBox(height: 32),
                                TextFormField(
                                  controller: _email,
                                  enabled: !state.isLoading,
                                  decoration: InputDecoration(
                                    labelText: l.email,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.username],
                                  textInputAction: TextInputAction.next,
                                  autocorrect: false,
                                  validator: (value) =>
                                      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                          .hasMatch(value?.trim() ?? '')
                                      ? null
                                      : l.invalidEmail,
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _password,
                                  enabled: !state.isLoading,
                                  decoration: InputDecoration(
                                    labelText: l.password,
                                    suffixIcon: IconButton(
                                      tooltip: _obscure
                                          ? l.showPassword
                                          : l.hidePassword,
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                  obscureText: _obscure,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  autofillHints: const [AutofillHints.password],
                                  onFieldSubmitted: (_) => _submit(),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? l.passwordRequired
                                      : null,
                                ),
                                if (state.hasError) ...[
                                  const SizedBox(height: 16),
                                  Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      l.authError,
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                FilledButton(
                                  onPressed: state.isLoading ? null : _submit,
                                  child: state.isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(l.signIn),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  l.needAccess,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
