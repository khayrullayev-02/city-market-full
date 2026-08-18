import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../core/utils.dart';
import '../features/product/product_screen.dart';
import '../models/models.dart';
import '../state/app_state.dart';

/// Mahsulot rasmi — URL bo'lsa rasmdan, bo'lmasa emoji fonidan.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    this.height = 104,
    this.radius = 13,
    this.emojiSize = 46,
  });

  final Product product;
  final double height;
  final double radius;
  final double emojiSize;

  @override
  Widget build(BuildContext context) {
    final url = product.images.isNotEmpty ? product.images.first : null;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url.isNotEmpty && !url.startsWith('mock://')
          ? Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => _emoji(),
            )
          : _emoji(),
    );
  }

  Widget _emoji() {
    final st = context.watch<AppState>();
    return Center(
      child: Text(
        categoryEmoji(st, product.categoryId),
        style: TextStyle(fontSize: emojiSize),
      ),
    );
  }
}

/// Kategoriyadan emoji qidirish.
String categoryEmoji(AppState st, String categoryId) {
  for (final c in st.categories) {
    if (c.id == categoryId) return c.emoji;
  }
  return '🛒';
}

/// Mahsulot kartasi (grid uchun).
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;
    final fav = st.isFav(product.id);
    final emoji = categoryEmoji(st, product.categoryId);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductScreen(productId: product.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 104,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 46)),
                ),
                if (product.oldPrice != null)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: _badge(
                      '−${product.discountPercent.round()}%',
                      AppColors.orange,
                    ),
                  )
                else if (product.stock == 0)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: _badge(S.t(lang, 'outStock'), AppColors.green),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => st.toggleFav(product.id),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.line),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        fav ? '❤️' : '🤍',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.name.tr(lang),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${product.unitLabel(lang)} · ${product.brand}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: AppColors.text),
                      children: [
                        TextSpan(
                          text: fmtNum(product.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                        TextSpan(
                          text: ' ${S.t(lang, 'sum')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: product.stock == 0
                      ? null
                      : () {
                          st.addToCart(product.id);
                          _snack(context, S.t(lang, 'cartAdd'));
                        },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: product.stock == 0
                          ? AppColors.muted
                          : AppColors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '+',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// Miqdor oshirish/kamaytirish.
class Stepper extends StatelessWidget {
  const Stepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn('−', () => onChanged(value - 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          _btn('+', () => onChanged(value + 1)),
        ],
      ),
    );
  }

  Widget _btn(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: AppColors.greenDark,
        ),
      ),
    ),
  );
}

/// Buyurtma statusi uchun rangli yorliq.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().lang;
    final (label, color, bg) = _style(lang);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  (String, Color, Color) _style(AppLang lang) {
    switch (status) {
      case OrderStatus.preparing:
        return (
          S.t(lang, 'sPreparing'),
          const Color(0xFFA16207),
          const Color(0xFFFEF9C3),
        );
      case OrderStatus.onway:
        return (
          S.t(lang, 'sOnway'),
          const Color(0xFFC2410C),
          AppColors.orangeLight,
        );
      case OrderStatus.delivered:
        return (
          S.t(lang, 'sDelivered'),
          AppColors.greenDark,
          AppColors.greenLight,
        );
      case OrderStatus.cancelled:
        return (
          S.t(lang, 'sCancelled'),
          const Color(0xFFB91C1C),
          const Color(0xFFFEE2E2),
        );
      default:
        return (
          S.t(lang, 'sAccepted'),
          const Color(0xFF0369A1),
          const Color(0xFFE0F2FE),
        );
    }
  }
}

/// Bo'sh holat ko'rinishi.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// Bo'lim sarlavhasi.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.seeAllLabel,
  });

  final String title;
  final VoidCallback? onSeeAll;
  final String? seeAllLabel;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().lang;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                seeAllLabel ?? S.t(lang, 'seeAll'),
                style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// To'liq kenglikdagi asosiy tugma.
class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.green,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}
