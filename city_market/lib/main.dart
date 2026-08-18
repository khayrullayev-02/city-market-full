import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/theme/app_theme.dart';
import 'data/repository.dart';
import 'data/supabase_repository.dart';
import 'state/app_state.dart';

/// City Market — ishga tushirish nuqtasi.
///
/// Supabase'ga ulanish uchun:
///   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=eyJ...
/// Aks holda avtomatik demo (Mock) rejim ishlaydi.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppRepository repo = await SupabaseRepository.create();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(repo)..init(),
      child: const CityMarketApp(),
    ),
  );
}
