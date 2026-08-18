import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/l10n/strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/home/home_shell.dart';
import 'state/app_state.dart';

class CityMarketApp extends StatelessWidget {
  const CityMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City Market',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const RootGate(),
    );
  }
}

/// Kirish holatiga qarab Auth yoki asosiy ekranni ko'rsatadi.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    if (st.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!st.loggedIn) {
      return const AuthScreen();
    }
    return const HomeShell();
  }
}
