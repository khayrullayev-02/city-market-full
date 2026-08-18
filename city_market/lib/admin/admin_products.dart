import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'product_form.dart';

/// Admin — mahsulotlar ro'yxati (qo'shish / tahrirlash / o'chirish).
class AdminProducts extends StatelessWidget {
  const AdminProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.t(lang, 'products'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${st.products.length} ${S.t(lang, 'found')}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductFormScreen()),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text(S.t(lang, 'addProduct')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: st.products.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('—', style: TextStyle(color: AppColors.muted)),
                )
              : Column(
                  children: [
                    _headerRow(lang),
                    const Divider(height: 1, color: AppColors.line),
                    ...st.products.map((p) => _row(context, st, lang, p)),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _headerRow(AppLang lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 3, child: _h(S.t(lang, 'productName'))),
          Expanded(flex: 2, child: _h(S.t(lang, 'category'))),
          Expanded(flex: 2, child: _h(S.t(lang, 'price'))),
          Expanded(flex: 1, child: _h(S.t(lang, 'stock'))),
          const SizedBox(width: 90, child: Text('')),
        ],
      ),
    );
  }

  Widget _h(String t) => Text(
    t,
    style: const TextStyle(
      color: AppColors.muted,
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
    ),
  );

  Widget _row(BuildContext context, AppState st, AppLang lang, Product p) {
    final cat = st.categories.where((c) => c.id == p.categoryId).firstOrNull;
    final low = p.stock == 0;
    final warn = p.stock > 0 && p.stock <= p.minStock;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cat?.emoji ?? '🛒',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 9),
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
                          fontSize: 12.5,
                        ),
                      ),
                      Text(
                        '${p.brand} · ${p.unitLabel(lang)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              cat?.name.tr(lang) ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              money(lang, p.price),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: low
                    ? const Color(0xFFFEE2E2)
                    : warn
                    ? AppColors.orangeLight
                    : AppColors.greenLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${p.stock}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                  color: low
                      ? const Color(0xFFB91C1C)
                      : warn
                      ? const Color(0xFFC2410C)
                      : AppColors.greenDark,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductFormScreen(product: p),
                    ),
                  ),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.green,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await st.deleteProduct(p.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.t(lang, 'productDeleted'))),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ],
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
