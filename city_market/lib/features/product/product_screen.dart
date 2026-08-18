import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/widgets.dart';
import 'video_screen.dart';

/// Mahsulot sahifasi — rasm, video, narx, o'lchov birligi, tavsif, mavjudlik.
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int qty = 1;
  int _imgIdx = 0;

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;
    final p = st.products.where((x) => x.id == widget.productId).firstOrNull;
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('—')),
      );
    }
    final fav = st.isFav(p.id);
    final emoji = categoryEmoji(st, p.categoryId);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _imageArea(st, lang, p, emoji, fav),
                _infoCard(st, lang, p),
              ],
            ),
          ),
          _bottomBar(st, lang, p),
        ],
      ),
    );
  }

  Widget _imageArea(
    AppState st,
    AppLang lang,
    Product p,
    String emoji,
    bool fav,
  ) {
    final images = p.images.where((s) => !s.startsWith('mock://')).toList();
    final showCarousel = images.isNotEmpty;
    return Stack(
      children: [
        Container(
          height: 240,
          color: AppColors.greenLight,
          alignment: Alignment.center,
          child: showCarousel
              ? PageView.builder(
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _imgIdx = i),
                  itemBuilder: (_, i) => Image.network(
                    images[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Text(emoji, style: const TextStyle(fontSize: 100)),
                  ),
                )
              : Text(emoji, style: const TextStyle(fontSize: 110)),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.text),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      fav ? Icons.favorite : Icons.favorite_border,
                      color: fav ? const Color(0xFFE11D48) : AppColors.text,
                    ),
                    onPressed: () => st.toggleFav(p.id),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showCarousel && images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _imgIdx ? 16 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _imgIdx ? AppColors.green : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _infoCard(AppState st, AppLang lang, Product p) {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.name.tr(lang),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${S.t(lang, 'brand')}: ${p.brand} · ${p.unitLabel(lang)}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${fmtNum(p.price)} ${S.t(lang, 'sum')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                if (p.oldPrice != null) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      '${fmtNum(p.oldPrice!)} ${S.t(lang, 'sum')}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (p.discountPercent > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '🔥 ${S.t(lang, 'promoTag')} −${p.discountPercent.round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            _stockChip(lang, p),
            if (p.videoUrl != null && p.videoUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        VideoScreen(url: p.videoUrl!, title: p.name.tr(lang)),
                  ),
                ),
                icon: const Icon(
                  Icons.play_circle_outline,
                  color: AppColors.green,
                ),
                label: Text(S.t(lang, 'video')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            _section(
              S.t(lang, 'description'),
              Text(
                p.description.tr(lang).isNotEmpty
                    ? p.description.tr(lang)
                    : '—',
              ),
            ),
            _section(S.t(lang, 'quantity'), _qtySelector(lang)),
            _section(S.t(lang, 'specifications'), _specs(lang, p)),
          ],
        ),
      ),
    );
  }

  Widget _stockChip(AppLang lang, Product p) {
    final ok = p.stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ok ? AppColors.greenLight : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        ok
            ? '🟢 ${S.t(lang, 'inStock')} · ${p.stock}'
            : '🔴 ${S.t(lang, 'outStock')}',
        style: TextStyle(
          color: ok ? AppColors.greenDark : const Color(0xFFB91C1C),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _qtySelector(AppLang lang) {
    return Wrap(
      spacing: 8,
      children: [1, 2, 3, 5].map((n) {
        final active = qty == n;
        return GestureDetector(
          onTap: () => setState(() => qty = n),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: active ? AppColors.green : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppColors.green : AppColors.line,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$n',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : AppColors.text,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _specs(AppLang lang, Product p) {
    final rows = <(String, String)>[
      (S.t(lang, 'brand'), p.brand.isEmpty ? '—' : p.brand),
      (S.t(lang, 'sku'), p.sku.isEmpty ? '—' : p.sku),
      (S.t(lang, 'unit'), p.unitLabel(lang)),
      if (p.country.isNotEmpty) (S.t(lang, 'origin'), p.country),
      if (p.manufacturer.isNotEmpty)
        (S.t(lang, 'manufacturer'), p.manufacturer),
      if (p.weightKg != null) (S.t(lang, 'weight'), '${p.weightKg} kg'),
      if (p.tags.isNotEmpty) (S.t(lang, 'tags'), p.tags.join(', ')),
    ];
    return Column(
      children: rows.map((r) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  r.$1,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
              Expanded(
                child: Text(
                  r.$2,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _section(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _bottomBar(AppState st, AppLang lang, Product p) {
    final canAdd = p.stock > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Stepper(
              value: qty,
              min: 1,
              onChanged: (v) => setState(() => qty = v.clamp(1, 99)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BigButton(
                label: S.t(lang, 'addToCart'),
                icon: Icons.shopping_cart_outlined,
                onTap: canAdd
                    ? () {
                        st.addToCart(p.id, qty);
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(content: Text(S.t(lang, 'cartAdd'))),
                          );
                      }
                    : null,
              ),
            ),
          ],
        ),
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
