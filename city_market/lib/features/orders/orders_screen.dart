import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/widgets.dart';
import 'tracking_screen.dart';

/// Buyurtmalar tarixi va status kuzatuvi.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;

    final active = st.orders
        .where(
          (o) =>
              o.status == OrderStatus.accepted ||
              o.status == OrderStatus.preparing ||
              o.status == OrderStatus.onway,
        )
        .toList();
    final history = st.orders
        .where(
          (o) =>
              o.status == OrderStatus.delivered ||
              o.status == OrderStatus.cancelled,
        )
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '📦 ${S.t(lang, 'ordersTitle')}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 12),
          Text(
            S.t(lang, 'active'),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          if (active.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('—', style: TextStyle(color: AppColors.muted)),
            )
          else
            ...active.map((o) => _orderCard(context, st, lang, o)),
          const SizedBox(height: 10),
          Text(
            S.t(lang, 'history'),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          ...history.map((o) => _orderCard(context, st, lang, o)),
        ],
      ),
    );
  }

  Widget _orderCard(BuildContext context, AppState st, AppLang lang, Order o) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TrackingScreen(orderId: o.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.number,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${fmtDate(o.createdAt)} · ${o.itemCount} ${S.t(lang, 'items')}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                StatusPill(status: o.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.t(lang, 'total'),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  money(lang, o.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
