import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils.dart';
import '../../state/app_state.dart';
import '../../widgets/widgets.dart';

/// Katalog — qidiruv, kategoriyalar, saralash va filtrlar.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;
    final list = st.filteredProducts;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: TextField(
              onChanged: st.setQuery,
              decoration: InputDecoration(
                hintText: S.t(lang, 'searchPh'),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.muted,
                  size: 20,
                ),
              ),
            ),
          ),
          _categoryChips(st, lang),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: st.sort,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 'popular',
                            child: Text(S.t(lang, 'popular')),
                          ),
                          DropdownMenuItem(
                            value: 'cheap',
                            child: Text(S.t(lang, 'cheap')),
                          ),
                          DropdownMenuItem(
                            value: 'expensive',
                            child: Text(S.t(lang, 'expensive')),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) st.sort = v;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _showFilter(context, st, lang),
                  icon: const Icon(Icons.tune, size: 18),
                  label: Text(S.t(lang, 'filter')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: AppColors.line),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${list.length} ${S.t(lang, 'found')}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? EmptyState(
                    emoji: '🔍',
                    title: S.t(lang, 'noProducts'),
                    action: BigButton(
                      label: S.t(lang, 'reset'),
                      onTap: st.resetFilters,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (_, i) => ProductCard(product: list[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChips(AppState st, AppLang lang) {
    return SizedBox(
      height: 82,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _chip(st, lang, null, '✨', S.t(lang, 'allCategories')),
          ...st.categories.map(
            (c) => _chip(st, lang, c.id, c.emoji, c.name.tr(lang)),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    AppState st,
    AppLang lang,
    String? id,
    String emoji,
    String label,
  ) {
    final active = st.activeCategory == id;
    return GestureDetector(
      onTap: () => st.activeCategory = id,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? AppColors.green : AppColors.line),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: active ? Colors.white : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilter(BuildContext context, AppState st, AppLang lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 14,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '⚙️ ${S.t(lang, 'filter')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${S.t(lang, 'priceRange')}: 0 — ${fmtNum(st.maxPrice)} ${S.t(lang, 'sum')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Slider(
                    value: st.maxPrice.clamp(5000, 100000),
                    min: 5000,
                    max: 100000,
                    divisions: 95,
                    activeColor: AppColors.green,
                    onChanged: (v) => setSheet(() => st.maxPrice = v),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.t(lang, 'brands'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: st.allBrands.map((b) {
                          final checked = st.brands.contains(b);
                          return CheckboxListTile(
                            value: checked,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppColors.green,
                            title: Text(
                              b,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onChanged: (v) {
                              setSheet(() {
                                if (v == true) {
                                  st.brands.add(b);
                                } else {
                                  st.brands.remove(b);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    value: st.inStockOnly,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.green,
                    title: Text(
                      S.t(lang, 'onlyStock'),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onChanged: (v) =>
                        setSheet(() => st.inStockOnly = v ?? false),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setSheet(st.resetFilters),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.text,
                            side: const BorderSide(color: AppColors.line),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(S.t(lang, 'reset')),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(S.t(lang, 'apply')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
