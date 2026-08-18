import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';

/// Admin — buyurtmalar va status o'zgartirish.
class AdminOrders extends StatelessWidget {
  const AdminOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          S.t(lang, 'ordersAdmin'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        Text(
          '${st.orders.length} ${S.t(lang, 'found')}',
          style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
        ),
        const SizedBox(height: 16),
        if (st.orders.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Text('—', style: TextStyle(color: AppColors.muted)),
          )
        else
          ...st.orders.map((o) => _card(st, lang, o)),
      ],
    );
  }

  Widget _card(AppState st, AppLang lang, Order o) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    fmtDateTime(o.createdAt),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              Text(
                money(lang, o.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            o.addressText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: orderStatusTo(o.status),
                      isExpanded: true,
                      items:
                          [
                                ('accepted', S.t(lang, 'sAccepted')),
                                ('preparing', S.t(lang, 'sPreparing')),
                                ('onway', S.t(lang, 'sOnway')),
                                ('delivered', S.t(lang, 'sDelivered')),
                                ('cancelled', S.t(lang, 'sCancelled')),
                              ]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.$1,
                                  child: Text(
                                    e.$2,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          st.updateOrderStatus(o.id, orderStatusFrom(v));
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              StatusPill(status: o.status),
            ],
          ),
        ],
      ),
    );
  }
}
