import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils.dart';
import '../../state/app_state.dart';
import '../../widgets/widgets.dart';

/// Bosh sahifa — bannerlar, kategoriyalar, aksiyalar, tavsiyalar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenCategory, this.onOpenCatalog});

  final void Function(String categoryId)? onOpenCategory;
  final VoidCallback? onOpenCatalog;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bannerCtrl = PageController();
  int _bannerIdx = 0;

  @override
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;
    final promo = st.products.where((p) => p.oldPrice != null).toList();
    final rec = st.products.take(6).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _topBar(st, lang),
          const SizedBox(height: 12),
          _banners(lang),
          SectionHeader(title: S.t(lang, 'categories')),
          _categoriesGrid(st, lang),
          if (promo.isNotEmpty) ...[
            SectionHeader(title: S.t(lang, 'promo')),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: promo.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) =>
                    SizedBox(width: 150, child: ProductCard(product: promo[i])),
              ),
            ),
          ],
          SectionHeader(
            title: S.t(lang, 'recommended'),
            onSeeAll: widget.onOpenCatalog,
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
            children: rec.map((p) => ProductCard(product: p)).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _topBar(AppState st, AppLang lang) {
    final city = st.addresses.isNotEmpty ? st.addresses.first.city : 'Jizzax';
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: widget.onOpenCatalog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.muted, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    S.t(lang, 'searchPh'),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          alignment: Alignment.center,
          child: const Text('🔔', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _banners(AppLang lang) {
    final banners = [
      (
        AppColors.green,
        const Color(0xFF22C55E),
        '🥬',
        S.t(lang, 'promoTag') + ' −20%',
        S.t(lang, 'buyNow'),
      ),
      (
        AppColors.orange,
        const Color(0xFFFB923C),
        '🛵',
        S.t(lang, 'freeDeliveryNote'),
        S.t(lang, 'checkout'),
      ),
      (
        const Color(0xFF4F46E5),
        const Color(0xFF818CF8),
        '🧴',
        S.t(lang, 'promoTag') + ' −15%',
        S.t(lang, 'seeAll'),
      ),
    ];
    return Column(
      children: [
        SizedBox(
          height: 128,
          child: PageView.builder(
            controller: _bannerCtrl,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _bannerIdx = i),
            itemBuilder: (_, i) {
              final (c1, c2, emoji, title, cta) = banners[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [c1, c2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 8,
                      bottom: 4,
                      child: Text(emoji, style: const TextStyle(fontSize: 60)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 210,
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            cta,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _bannerIdx ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: i == _bannerIdx
                    ? AppColors.green
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _categoriesGrid(AppState st, AppLang lang) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 10,
      childAspectRatio: 0.8,
      children: st.categories.map((c) {
        return GestureDetector(
          onTap: () => widget.onOpenCategory?.call(c.id),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                alignment: Alignment.center,
                child: Text(c.emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(height: 6),
              Text(
                c.name.tr(lang),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                  height: 1.25,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
