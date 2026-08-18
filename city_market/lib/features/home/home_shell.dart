import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/strings.dart';
import '../../state/app_state.dart';
import '../cart/cart_screen.dart';
import '../catalog/catalog_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// Asosiy qobiq — 5 ta tab (Bosh sahifa, Katalog, Savat, Buyurtmalar, Profil).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;
    final tabs = [
      S.t(lang, 'tabHome'),
      S.t(lang, 'tabCat'),
      S.t(lang, 'tabCart'),
      S.t(lang, 'tabOrders'),
      S.t(lang, 'tabProfile'),
    ];
    const icons = [
      Icons.home_rounded,
      Icons.grid_view_rounded,
      Icons.shopping_cart_rounded,
      Icons.receipt_long_rounded,
      Icons.person_rounded,
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onOpenCategory: (catId) {
              st.activeCategory = catId;
              setState(() => _index = 1);
            },
            onOpenCatalog: () => setState(() => _index = 1),
          ),
          const CatalogScreen(),
          const CartScreen(),
          const OrdersScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: List.generate(5, (i) {
          return BottomNavigationBarItem(
            icon: i == 2 && st.cartCount > 0
                ? Badge(label: Text('${st.cartCount}'), child: Icon(icons[i]))
                : Icon(icons[i]),
            label: tabs[i],
          );
        }),
      ),
    );
  }
}
