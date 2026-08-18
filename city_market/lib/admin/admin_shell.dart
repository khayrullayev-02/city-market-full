import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../state/app_state.dart';
import 'admin_customers.dart';
import 'admin_dashboard.dart';
import 'admin_orders.dart';
import 'admin_products.dart';

/// Admin panel qobig'i — yon menyu + kontent (Flutter Web'da ham ishlaydi).
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _view = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().lang;
    final items = [
      (S.t(lang, 'dash'), Icons.dashboard_outlined),
      (S.t(lang, 'products'), Icons.inventory_2_outlined),
      (S.t(lang, 'ordersAdmin'), Icons.receipt_long_outlined),
      (S.t(lang, 'customers'), Icons.people_outline),
    ];

    final pages = [
      const AdminDashboard(),
      const AdminProducts(),
      const AdminOrders(),
      const AdminCustomers(),
    ];

    final isWide = MediaQuery.of(context).size.width > 900;

    final content = Row(
      children: [
        Container(
          width: isWide ? 232 : 72,
          color: const Color(0xFF0F172A),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🛒', style: TextStyle(fontSize: 16)),
                    ),
                    if (isWide) ...[
                      const SizedBox(width: 9),
                      const Text(
                        'City Market',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 6),
              ...items.asMap().entries.map((e) {
                final active = _view == e.key;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _view = e.key),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: active ? AppColors.green : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            e.value.$2,
                            size: 20,
                            color: active
                                ? Colors.white
                                : const Color(0xFFCBD5E1),
                          ),
                          if (isWide) ...[
                            const SizedBox(width: 10),
                            Text(
                              e.value.$1,
                              style: TextStyle(
                                color: active
                                    ? Colors.white
                                    : const Color(0xFFCBD5E1),
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.smartphone,
                          size: 18,
                          color: Color(0xFFCBD5E1),
                        ),
                        if (isWide) ...[
                          const SizedBox(width: 8),
                          Text(
                            S.t(lang, 'backApp'),
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(color: const Color(0xFFF7F9FB), child: pages[_view]),
        ),
      ],
    );

    return Scaffold(body: SafeArea(child: content));
  }
}
