import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/widgets.dart';

/// Kirish / ro'yxatdan o'tish — telefon + SMS kod (demo rejim).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phone = TextEditingController(text: '+998 90 123 45 67');
  final _otp = List.generate(4, (_) => TextEditingController(text: ''));

  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    const demo = ['1', '2', '3', '4'];
    for (var i = 0; i < 4; i++) {
      _otp[i].text = demo[i];
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    for (final c in _otp) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.green, Color(0xFF22C55E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: const Text('🛒', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 16),
              Text(
                S.t(lang, 'appName'),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                S.t(lang, 'loginSub'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: S.t(lang, 'phone'),
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_otpSent) ...[
                      Text(
                        S.t(lang, 'enterCode'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) {
                          return Container(
                            width: 46,
                            height: 52,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: TextField(
                              controller: _otp[i],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          );
                        }),
                      ),
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
                          '🔑 ${S.t(lang, 'demoCode')}',
                          style: const TextStyle(
                            color: Color(0xFF9A3412),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      BigButton(
                        label: S.t(lang, 'verify'),
                        onTap: () async {
                          final code = _otp.map((c) => c.text).join();
                          await st.verify(code);
                        },
                      ),
                    ] else ...[
                      BigButton(
                        label: S.t(lang, 'getCode'),
                        onTap: () {
                          setState(() => _otpSent = true);
                        },
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => st.login(_phone.text),
                      child: Text(
                        S.t(lang, 'skip'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
