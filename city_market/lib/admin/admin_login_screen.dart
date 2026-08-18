import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'admin_shell.dart';

/// Admin panelga kirish (demo: admin@citymarket.uz / admin123).
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController(text: 'admin@citymarket.uz');
  final _pass = TextEditingController(text: 'admin123');
  bool _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _login() {
    if (_email.text.trim() == 'admin@citymarket.uz' &&
        _pass.text == 'admin123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminShell()),
      );
    } else {
      final lang = context.read<AppState>().lang;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(S.t(lang, 'errLogin'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().lang;

    return Scaffold(
      appBar: AppBar(title: Text(S.t(lang, 'adminLogin'))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '🛒 ${S.t(lang, 'appName')}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  S.t(lang, 'adminPanel'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: S.t(lang, 'email'),
                    prefixIcon: const Icon(
                      Icons.mail_outline,
                      color: AppColors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  obscureText: _hide,
                  decoration: InputDecoration(
                    labelText: S.t(lang, 'password'),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.green,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hide ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _hide = !_hide),
                    ),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 16),
                BigButton(label: S.t(lang, 'signIn'), onTap: _login),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orangeLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🔑 ${S.t(lang, 'adminDemo')}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF9A3412),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
