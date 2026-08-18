import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n/strings.dart';
import '../data/repository.dart';
import '../models/models.dart';

/// Butun ilovaning markaziy holati.
class AppState extends ChangeNotifier {
  AppState(this.repo);

  final AppRepository repo;

  // ---- Umumiy ----
  AppLang lang = AppLang.uz;
  bool loggedIn = false;
  bool loading = false;
  UserProfile? user;

  // ---- Ma'lumotlar ----
  List<Category> categories = [];
  List<Product> products = [];
  List<Address> addresses = [];
  List<Order> orders = [];
  Set<String> favorites = {};
  List<UserProfile> customers = [];
  AdminStats? stats;

  // ---- Savat ----
  final Map<String, int> cart = {};

  // ---- Filtrlar ----
  String? activeCategory;
  String query = '';
  String sort = 'popular';
  double maxPrice = 100000;
  bool inStockOnly = false;
  Set<String> brands = {};

  // ---- Buyurtma ----
  int selectedAddress = 0;
  int selectedSlot = 0;
  Order? lastOrder;

  static const double freeDeliveryThreshold = 20000;
  static const double deliveryFee = 10000;

  // ================= Init =================
  Future<void> init() async {
    loading = true;
    notifyListeners();

    // Tilni eslab qolamiz.
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('lang');
      if (saved == 'ru') lang = AppLang.ru;
      if (saved == 'en') lang = AppLang.en;
    } catch (_) {}

    await loadData();
    loading = false;
    notifyListeners();
  }

  Future<void> loadData() async {
    try {
      final results = await Future.wait([
        repo.fetchCategories(),
        repo.fetchProducts(),
        repo.fetchAddresses(),
        repo.fetchOrders(),
        repo.fetchFavorites(),
      ]);
      categories = results[0] as List<Category>;
      products = results[1] as List<Product>;
      addresses = results[2] as List<Address>;
      orders = results[3] as List<Order>;
      favorites = results[4] as Set<String>;
      if (addresses.isEmpty) {
        addresses = const [
          Address(
            id: 'a1',
            label: 'home',
            city: 'Jizzax',
            address: "Mustaqillik ko'chasi, 12-uy",
            isDefault: true,
          ),
        ];
      }
    } catch (_) {}
  }

  // ================= Lang =================
  void setLang(AppLang l) {
    lang = l;
    notifyListeners();
    SharedPreferences.getInstance().then((p) => p.setString('lang', l.name));
  }

  // ================= Auth =================
  Future<void> login(String phone) async {
    loading = true;
    notifyListeners();
    user = await repo.signInWithPhone(phone);
    loggedIn = user != null;
    loading = false;
    notifyListeners();
  }

  Future<void> verify(String code) async {
    user = await repo.verifyOtp(code);
    loggedIn = user != null;
    notifyListeners();
  }

  Future<void> logout() async {
    await repo.signOut();
    loggedIn = false;
    user = null;
    cart.clear();
    notifyListeners();
  }

  // ================= Katalog / Filtr =================
  List<String> get allBrands {
    final s = <String>{};
    for (final p in products) {
      if (p.brand.isNotEmpty) s.add(p.brand);
    }
    final list = s.toList()..sort();
    return list;
  }

  List<Product> get filteredProducts {
    final q = query.trim().toLowerCase();
    var list = products.where((p) {
      if (!p.isActive) return false;
      if (activeCategory != null && p.categoryId != activeCategory) {
        return false;
      }
      if (p.price > maxPrice) return false;
      if (inStockOnly && p.stock == 0) return false;
      if (brands.isNotEmpty && !brands.contains(p.brand)) return false;
      if (q.isNotEmpty &&
          !(p.name.tr(lang).toLowerCase().contains(q) ||
              p.brand.toLowerCase().contains(q) ||
              p.tags.any((t) => t.toLowerCase().contains(q)))) {
        return false;
      }
      return true;
    }).toList();

    if (sort == 'cheap') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (sort == 'expensive') {
      list.sort((a, b) => b.price.compareTo(a.price));
    }
    return list;
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  List<Product> searchProducts(String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return products;
    return products
        .where(
          (p) =>
              p.name.tr(lang).toLowerCase().contains(s) ||
              p.brand.toLowerCase().contains(s) ||
              p.tags.any((t) => t.toLowerCase().contains(s)),
        )
        .toList();
  }

  void resetFilters() {
    activeCategory = null;
    query = '';
    sort = 'popular';
    maxPrice = 100000;
    inStockOnly = false;
    brands = {};
    notifyListeners();
  }

  // ================= Savat =================
  int get cartCount => cart.values.fold(0, (sum, q) => sum + q);

  double get cartSubtotal {
    double s = 0;
    cart.forEach((id, q) {
      final p = _product(id);
      if (p != null) s += p.price * q;
    });
    return s;
  }

  double get cartDelivery =>
      cartSubtotal >= freeDeliveryThreshold ? 0 : deliveryFee;

  double get cartTotal => cartSubtotal + cartDelivery;

  Product? _product(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  void addToCart(String id, [int delta = 1]) {
    final p = _product(id);
    if (p == null) return;
    if (p.stock == 0 && delta > 0) return;
    final cur = cart[id] ?? 0;
    final next = cur + delta;
    if (next <= 0) {
      cart.remove(id);
    } else {
      cart[id] = next;
    }
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  // ================= Sevimlilar =================
  bool isFav(String id) => favorites.contains(id);

  Future<void> toggleFav(String id) async {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    notifyListeners();
    await repo.setFavorite(id, favorites.contains(id));
  }

  List<Product> get favoriteProducts =>
      products.where((p) => favorites.contains(p.id)).toList();

  // ================= Manzillar =================
  Future<void> addAddress(Address a) async {
    final saved = await repo.addAddress(a);
    addresses.add(saved);
    notifyListeners();
  }

  Future<void> removeAddress(String id) async {
    addresses.removeWhere((a) => a.id == id);
    notifyListeners();
    await repo.removeAddress(id);
  }

  // ================= Buyurtma =================
  Future<void> placeOrder(String comment) async {
    final items = <OrderItem>[];
    cart.forEach((id, q) {
      final p = _product(id);
      if (p != null) {
        items.add(
          OrderItem(
            productId: p.id,
            name: p.name.tr(lang),
            price: p.price,
            qty: q,
            unit: p.unitLabel(lang),
          ),
        );
      }
    });
    final addr = addresses.isNotEmpty
        ? addresses[selectedAddress.clamp(0, addresses.length - 1)]
        : const Address(id: '', address: '');
    final slotKey = 'slot${selectedSlot + 1}';
    final draft = OrderDraft(
      items: items,
      addressText: '${addr.city} · ${addr.address}',
      deliverySlot: S.t(lang, slotKey),
      paymentMethod: 'cash',
      comment: comment,
      subtotal: cartSubtotal,
      deliveryFee: cartDelivery,
      total: cartTotal,
    );
    lastOrder = await repo.placeOrder(draft);
    orders.insert(0, lastOrder!);
    clearCart();
  }

  // ================= Admin =================
  Future<void> loadAdmin() async {
    try {
      customers = await repo.fetchCustomers();
      stats = await repo.fetchStats();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> saveProduct(Product p) async {
    await repo.saveProduct(p);
    final i = products.indexWhere((x) => x.id == p.id);
    if (i >= 0) {
      products[i] = p;
    } else {
      products.insert(0, p);
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await repo.deleteProduct(id);
    products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await repo.updateOrderStatus(orderId, status);
    final i = orders.indexWhere((o) => o.id == orderId);
    if (i >= 0) {
      final old = orders[i];
      orders[i] = Order(
        id: old.id,
        number: old.number,
        items: old.items,
        subtotal: old.subtotal,
        deliveryFee: old.deliveryFee,
        total: old.total,
        status: status,
        createdAt: old.createdAt,
        addressText: old.addressText,
        deliverySlot: old.deliverySlot,
        paymentMethod: old.paymentMethod,
        comment: old.comment,
      );
      notifyListeners();
    }
  }
}
