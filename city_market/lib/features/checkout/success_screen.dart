import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/widgets.dart';
import '../orders/tracking_screen.dart';

/// Buyurtma muvaffaqiyatli qabul qilingani haqida ekran.
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;
    final order = st.lastOrder;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.greenLight,
                  shape: BoxShape.circle,
                ),
                child: const Text('✅', style: TextStyle(fontSize: 46)),
              ),
              const SizedBox(height: 18),
              Text(
                S.t(lang, 'success'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                S.t(lang, 'orderNo'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              Text(
                order?.number ?? '—',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                S.t(lang, 'thanks'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              BigButton(
                label: S.t(lang, 'track'),
                onTap: order == null
                    ? null
                    : () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackingScreen(orderId: order.id),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.line),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(S.t(lang, 'backHome')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
