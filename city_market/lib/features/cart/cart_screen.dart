import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils.dart';
import '../../state/app_state.dart';
import '../../widgets/widgets.dart';
import '../checkout/checkout_screen.dart';

/// Savat — miqdorni oshirish/kamaytirish, umumiy summa.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;

    if (st.cart.isEmpty) {
      return SafeArea(
        child: EmptyState(
          emoji: '🛒',
          title: S.t(lang, 'emptyCart'),
          subtitle: S.t(lang, 'emptyCartSub'),
        ),
      );
    }

    final entries = st.cart.entries.toList();
    final free = st.cartDelivery == 0;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🛒 ${S.t(lang, 'cartTitle')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                Text(
                  '${st.cartCount} ${S.t(lang, 'items')}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (_, i) {
                final e = entries[i];
                final p = st.products.where((x) => x.id == e.key).firstOrNull;
                if (p == null) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          categoryEmoji(st, p.categoryId),
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name.tr(lang),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${p.unitLabel(lang)} · ${money(lang, p.price)}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stepper(
                                  value: e.value,
                                  min: 0,
                                  onChanged: (v) =>
                                      st.addToCart(e.key, v - e.value),
                                ),
                                Text(
                                  money(lang, p.price * e.value),
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
                      IconButton(
                        onPressed: () => st.addToCart(e.key, -e.value),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _summary(st, lang, free),
        ],
      ),
    );
  }

  Widget _summary(AppState st, AppLang lang, bool free) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _row(S.t(lang, 'subtotal'), money(lang, st.cartSubtotal)),
            _row(
              S.t(lang, 'delivery'),
              free ? S.t(lang, 'free') : money(lang, st.cartDelivery),
              highlight: free,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: AppColors.line),
            ),
            _row(S.t(lang, 'total'), money(lang, st.cartTotal), bold: true),
            const SizedBox(height: 12),
            BigButton(
              label: S.t(lang, 'checkout'),
              icon: Icons.arrow_forward,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              fontSize: bold ? 15 : 13,
              color: AppColors.text,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              fontSize: bold ? 15 : 13,
              color: highlight ? AppColors.green : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
