import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';

/// Admin boshqaruv paneli — statistika + so'nggi buyurtmalar.
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;
    final stats = st.stats ?? const AdminStats();

    final cards = [
      (
        '💰',
        money(lang, stats.todaySales),
        S.t(lang, 'todaySales'),
        '+12%',
        true,
      ),
      ('🧾', '${stats.ordersToday}', S.t(lang, 'ordersToday'), '+8%', true),
      ('👥', '${stats.customers}', S.t(lang, 'custCount'), '+5%', true),
      ('📈', money(lang, stats.avgCheck), S.t(lang, 'avgCheck'), '-2%', false),
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          S.t(lang, 'dash'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        Text(
          '${S.t(lang, 'today')} · 18.08.2026',
          style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (_, c) {
            final cols = c.maxWidth > 760 ? 4 : 2;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.5,
              children: cards
                  .map((c) => _statCard(lang, c.$1, c.$2, c.$3, c.$4, c.$5))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        _panel(title: '📊 ${S.t(lang, 'sales7')}', child: _barChart(stats)),
        const SizedBox(height: 16),
        _panel(
          title: '🧾 ${S.t(lang, 'recentOrders')}',
          child: _recentOrders(st, lang),
        ),
      ],
    );
  }

  Widget _statCard(
    AppLang lang,
    String emoji,
    String value,
    String label,
    String delta,
    bool up,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$delta ${S.t(lang, 'vsPrev')}',
            style: TextStyle(
              color: up ? AppColors.green : AppColors.muted,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _barChart(AdminStats stats) {
    final data = stats.weekSales.isEmpty
        ? const [820.0, 940, 760, 1100, 980, 1350, 1240]
        : stats.weekSales;
    final labels = stats.weekLabels.isEmpty
        ? const ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya']
        : stats.weekLabels;
    final max = data.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 170,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final h = (data[i] / max * 130).clamp(8.0, 130.0);
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${data[i].round()}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: h,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: i == 5 ? AppColors.orange : AppColors.green,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _recentOrders(AppState st, AppLang lang) {
    final orders = st.orders.take(5).toList();
    if (orders.isEmpty) {
      return Text('—', style: TextStyle(color: AppColors.muted));
    }
    return Column(
      children: orders.map((o) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.number,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                    Text(
                      fmtDate(o.createdAt),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                money(lang, o.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(width: 12),
              StatusPill(status: o.status),
            ],
          ),
        );
      }).toList(),
    );
  }
}
