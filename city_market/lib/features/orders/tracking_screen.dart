import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/widgets.dart';

/// Buyurtma statusini kuzatish — 4 bosqichli vaqt chizig'i.
class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;
    final o = st.orders.where((x) => x.id == orderId).firstOrNull;
    if (o == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('—')),
      );
    }

    final steps = [
      (S.t(lang, 'sAccepted'), '📥'),
      (S.t(lang, 'sPreparing'), '👨‍🍳'),
      (S.t(lang, 'sOnway'), '🛵'),
      (S.t(lang, 'sDelivered'), '✅'),
    ];
    final idx = _index(o.status);

    return Scaffold(
      appBar: AppBar(title: Text(S.t(lang, 'track'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                Text(
                  '${S.t(lang, 'orderNo')} ${o.number} · ${fmtDate(o.createdAt)}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  money(lang, o.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                StatusPill(status: o.status),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: List.generate(steps.length, (i) {
                final done = i < idx;
                final cur = i == idx;
                final emoji = steps[i].$2;
                final label = steps[i].$1;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Column(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: done
                                  ? AppColors.green
                                  : cur
                                  ? AppColors.orange
                                  : const Color(0xFFE5E9F0),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              done ? '✓' : emoji,
                              style: TextStyle(
                                fontSize: 14,
                                color: done || cur
                                    ? Colors.white
                                    : Colors.black54,
                              ),
                            ),
                          ),
                          if (i < steps.length - 1)
                            Container(
                              width: 2,
                              height: 30,
                              color: done
                                  ? AppColors.green
                                  : const Color(0xFFE5E9F0),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontWeight: cur || done
                              ? FontWeight.w800
                              : FontWeight.w600,
                          fontSize: 13.5,
                          color: cur ? AppColors.orange : AppColors.text,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📍 ${S.t(lang, 'address')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(o.addressText, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 10),
                Text(
                  '🕐 ${S.t(lang, 'deliveryTime')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(o.deliverySlot, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 10),
                Text(
                  '💳 ${S.t(lang, 'paymentMethod')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(S.t(lang, 'cash'), style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _index(OrderStatus s) {
    switch (s) {
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.onway:
        return 2;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return 0;
      default:
        return 0;
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
