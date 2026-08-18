import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/strings.dart';
import '../../state/app_state.dart';
import '../../widgets/widgets.dart';

/// Sevimli mahsulotlar.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;
    final favs = st.favoriteProducts;

    return Scaffold(
      appBar: AppBar(title: Text('❤️ ${S.t(lang, 'favorites')}')),
      body: favs.isEmpty
          ? EmptyState(
              emoji: '🤍',
              title: S.t(lang, 'emptyFav'),
              subtitle: S.t(lang, 'emptyFavSub'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (_, i) => ProductCard(product: favs[i]),
            ),
    );
  }
}
