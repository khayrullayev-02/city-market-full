import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../state/app_state.dart';

/// Admin — mijozlar ro'yxati.
class AdminCustomers extends StatelessWidget {
  const AdminCustomers({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          S.t(lang, 'customers'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        Text(
          '${st.customers.length} ${S.t(lang, 'found')}',
          style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: st.customers.map((c) {
              return ListTile(
                leading: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.greenLight,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('👤', style: TextStyle(fontSize: 16)),
                ),
                title: Text(
                  c.fullName.isEmpty ? c.phone : c.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                subtitle: Text(
                  c.phone,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
