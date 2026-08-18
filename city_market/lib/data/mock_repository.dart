import 'dart:typed_data';

import '../models/models.dart';
import 'repository.dart';

/// Demo rejim — Supabase'ga ulanmasdan ishlaydi.
/// Barcha ma'lumotlar xotirada saqlanadi (real ma'lumotlar bazasini taqlid).
class MockRepository implements AppRepository {
  UserProfile? _user;

  late final List<Category> _categories = [
    const Category(
      id: 'c1',
      slug: 'sut',
      name: L10n(uz: 'Sut mahsulotlari', ru: 'Молочные продукты', en: 'Dairy'),
      emoji: '🥛',
    ),
    const Category(
      id: 'c2',
      slug: 'non',
      name: L10n(uz: 'Non', ru: 'Хлеб', en: 'Bread'),
      emoji: '🍞',
    ),
    const Category(
      id: 'c3',
      slug: 'ichimlik',
      name: L10n(uz: 'Ichimliklar', ru: 'Напитки', en: 'Drinks'),
      emoji: '🥤',
    ),
    const Category(
      id: 'c4',
      slug: 'meva',
      name: L10n(uz: 'Meva-sabzavot', ru: 'Овощи и фрукты', en: 'Fruits & Veg'),
      emoji: '🥦',
    ),
    const Category(
      id: 'c5',
      slug: 'gosht',
      name: L10n(uz: "Go'sht", ru: 'Мясо', en: 'Meat'),
      emoji: '🍗',
    ),
    const Category(
      id: 'c6',
      slug: 'shirin',
      name: L10n(uz: 'Shirinliklar', ru: 'Сладости', en: 'Sweets'),
      emoji: '🍫',
    ),
    const Category(
      id: 'c7',
      slug: 'don',
      name: L10n(uz: 'Don mahsulotlari', ru: 'Бакалея', en: 'Groceries'),
      emoji: '🌾',
    ),
    const Category(
      id: 'c8',
      slug: 'maishiy',
      name: L10n(
        uz: 'Yuvish vositalari',
        ru: 'Моющие средства',
        en: 'Detergents',
      ),
      emoji: '🧴',
      isHousehold: true,
    ),
    const Category(
      id: 'c9',
      slug: 'idish',
      name: L10n(uz: 'Idish-tovoq', ru: 'Посуда', en: 'Dishes'),
      emoji: '🍽️',
      isHousehold: true,
    ),
    const Category(
      id: 'c10',
      slug: 'gigiyena',
      name: L10n(
        uz: 'Shaxsiy gigiyena',
        ru: 'Личная гигиена',
        en: 'Personal care',
      ),
      emoji: '🧼',
      isHousehold: true,
    ),
  ];

  late final List<Product> _products = [
    const Product(
      id: 'p1',
      categoryId: 'c1',
      name: L10n(uz: 'Sut 3,2%', ru: 'Молоко 3,2%', en: 'Milk 3.2%'),
      description: L10n(
        uz: "Tabiiy pasterizatsiyalangan sigir suti, 3,2% yog'lilik.",
        ru: 'Натуральное пастеризованное молоко 3,2% жирности.',
        en: 'Natural pasteurized cow milk, 3.2% fat.',
      ),
      brand: 'Oqtepa',
      sku: '4780000000011',
      price: 12000,
      unit: 'litr',
      unitValue: 1,
      stock: 48,
      minStock: 10,
      tags: ['sut', 'tabiiy'],
      country: "O'zbekiston",
      manufacturer: 'Oqtepa Sut',
    ),
    const Product(
      id: 'p2',
      categoryId: 'c1',
      name: L10n(uz: 'Qatiq', ru: 'Катык', en: 'Yogurt (Qatiq)'),
      description: L10n(
        uz: "Qaymoqli tabiiy qatiq, qo'shimchalarsiz.",
        ru: 'Натуральный катык без добавок.',
        en: 'Creamy natural yogurt, no additives.',
      ),
      brand: 'Sutli diyor',
      price: 9000,
      unit: 'g',
      unitValue: 400,
      stock: 32,
      minStock: 8,
      country: "O'zbekiston",
    ),
    const Product(
      id: 'p3',
      categoryId: 'c1',
      name: L10n(uz: 'Pishloq', ru: 'Сыр', en: 'Cheese'),
      description: L10n(
        uz: 'Qattiq pishloq, sendvich va nonushta uchun.',
        ru: 'Твёрдый сыр для бутербродов.',
        en: 'Hard cheese, great for sandwiches.',
      ),
      brand: 'Lazzat',
      price: 25000,
      unit: 'g',
      unitValue: 200,
      stock: 20,
      minStock: 6,
      country: "O'zbekiston",
    ),
    const Product(
      id: 'p4',
      categoryId: 'c2',
      name: L10n(uz: 'Patir non', ru: 'Лепешка', en: 'Flatbread (Patir)'),
      description: L10n(
        uz: 'Tandirda yopilgan, kunjut sepilgan patir non.',
        ru: 'Лепешка из тандыра с кунжутом.',
        en: 'Tandoor-baked flatbread with sesame.',
      ),
      brand: 'Nonvoy',
      price: 8000,
      unit: 'dona',
      unitValue: 1,
      stock: 25,
      minStock: 10,
      country: "O'zbekiston",
    ),
    const Product(
      id: 'p5',
      categoryId: 'c2',
      name: L10n(uz: 'Buxanka non', ru: 'Буханка', en: 'Loaf bread'),
      description: L10n(
        uz: 'Yumshoq, bugun yopilgan oq non.',
        ru: 'Мягкий белый хлеб, свежая выпечка.',
        en: 'Soft white bread, baked today.',
      ),
      brand: 'City Bakery',
      price: 5000,
      unit: 'g',
      unitValue: 400,
      stock: 40,
      minStock: 15,
      country: "O'zbekiston",
    ),
    const Product(
      id: 'p6',
      categoryId: 'c3',
      name: L10n(
        uz: 'Ichimlik suvi',
        ru: 'Питьевая вода',
        en: 'Drinking water',
      ),
      description: L10n(
        uz: 'Gazsiz tozalangan ichimlik suvi.',
        ru: 'Негазированная очищенная вода.',
        en: 'Still purified drinking water.',
      ),
      brand: 'Hydrolife',
      price: 5000,
      unit: 'litr',
      unitValue: 1.5,
      stock: 120,
      minStock: 30,
      country: "O'zbekiston",
    ),
    const Product(
      id: 'p7',
      categoryId: 'c3',
      name: L10n(uz: 'Cola 1 l', ru: 'Кола 1 л', en: 'Cola 1 L'),
      description: L10n(
        uz: "Gazlangan salqin ichimlik, aksiyada.",
        ru: 'Газированный напиток, по акции.',
        en: 'Sparkling soft drink, on promo.',
      ),
      brand: 'Coca-Cola',
      price: 13000,
      oldPrice: 15000,
      unit: 'litr',
      unitValue: 1,
      stock: 80,
      minStock: 20,
      country: 'Turkiya',
    ),
    const Product(
      id: 'p8',
      categoryId: 'c4',
      name: L10n(uz: 'Olma', ru: 'Яблоки', en: 'Apples'),
      description: L10n(
        uz: 'Shirin, suvli mahalliy olma.',
        ru: 'Сладкие сочные местные яблоки.',
        en: 'Sweet, juicy local apples.',
      ),
      brand: 'Mahalliy',
      price: 15000,
      unit: 'kg',
      unitValue: 1,
      stock: 60,
      minStock: 20,
      country: "O'zbekiston",
    ),
    const Product(
      id: 'p9',
      categoryId: 'c4',
      name: L10n(uz: 'Pomidor', ru: 'Помидоры', en: 'Tomatoes'),
      description: L10n(
        uz: "Pishgan, xushbo'y pomidorlar.",
        ru: 'Спелые ароматные помидоры.',
        en: 'Ripe, fragrant tomatoes.',
      ),
      brand: 'Mahalliy',
      price: 12000,
      unit: 'kg',
      unitValue: 1,
      stock: 0,
      minStock: 20,
      country: "O'zbekiston",
    ),
    const Product(
      id: 'p10',
      categoryId: 'c5',
      name: L10n(
        uz: 'Tovuq son qismi',
        ru: 'Куриное бедро',
        en: 'Chicken thighs',
      ),
      description: L10n(
        uz: 'Sovutilgan tovuq son qismi, 1 kg.',
        ru: 'Охлаждённые куриные бёдра, 1 кг.',
        en: 'Chilled chicken thighs, 1 kg.',
      ),
      brand: 'Parranda',
      price: 42000,
      unit: 'kg',
      unitValue: 1,
      stock: 18,
      minStock: 8,
      country: "O'zbekiston",
    ),
    const Product(
      id: 'p11',
      categoryId: 'c6',
      name: L10n(uz: 'Shokolad', ru: 'Шоколад', en: 'Chocolate'),
      description: L10n(
        uz: "Sutli shokolad, yong'oq bilan.",
        ru: 'Молочный шоколад с орехом.',
        en: 'Milk chocolate with nuts.',
      ),
      brand: 'Alpen Gold',
      price: 16000,
      oldPrice: 19000,
      unit: 'g',
      unitValue: 100,
      stock: 55,
      minStock: 15,
      country: 'Rossiya',
    ),
    const Product(
      id: 'p12',
      categoryId: 'c7',
      name: L10n(uz: 'Guruch', ru: 'Рис', en: 'Rice'),
      description: L10n(
        uz: 'Yumshoq navli lazer guruch.',
        ru: 'Рис мягкого сорта лазер.',
        en: 'Soft-grain lazer rice.',
      ),
      brand: 'Lazer',
      price: 20000,
      unit: 'kg',
      unitValue: 1,
      stock: 70,
      minStock: 25,
      country: "O'zbekiston",
    ),
    const Product(
      id: 'p13',
      categoryId: 'c7',
      name: L10n(uz: 'Tuxum', ru: 'Яйца', en: 'Eggs'),
      description: L10n(
        uz: 'Birinchi navli tovuq tuxumi, 10 dona.',
        ru: 'Яйца первого сорта, 10 шт.',
        en: 'Grade-A chicken eggs, 10 pcs.',
      ),
      brand: 'Mahalliy',
      price: 18000,
      unit: 'dona',
      unitValue: 10,
      stock: 90,
      minStock: 30,
      country: "O'zbekiston",
    ),
    const Product(
      id: 'p14',
      categoryId: 'c8',
      name: L10n(
        uz: 'Kir yuvish kukuni',
        ru: 'Стиральный порошок',
        en: 'Laundry detergent',
      ),
      description: L10n(
        uz: 'Avtomat mashina uchun, 3 kg qadoq.',
        ru: 'Для стиральных машин, 3 кг.',
        en: 'For washing machines, 3 kg pack.',
      ),
      brand: 'Sorti',
      price: 45000,
      oldPrice: 52000,
      unit: 'kg',
      unitValue: 3,
      stock: 26,
      minStock: 8,
      country: "O'zbekiston",
    ),
    const Product(
      id: 'p15',
      categoryId: 'c8',
      name: L10n(
        uz: 'Idish yuvish geli',
        ru: 'Гель для посуды',
        en: 'Dishwashing gel',
      ),
      description: L10n(
        uz: "Yog'ni tez erituvchi gel.",
        ru: 'Гель, быстро растворяющий жир.',
        en: 'Fast grease-cutting gel.',
      ),
      brand: 'Fairy',
      price: 12000,
      unit: 'ml',
      unitValue: 500,
      stock: 64,
      minStock: 15,
      country: 'Turkiya',
    ),
    const Product(
      id: 'p16',
      categoryId: 'c9',
      name: L10n(
        uz: 'Chinni tovoq',
        ru: 'Фарфоровое блюдо',
        en: 'Porcelain dish',
      ),
      description: L10n(
        uz: '6 kishilik chinni tovoq to\'plami.',
        ru: 'Фарфоровое блюдо на 6 персон.',
        en: 'Porcelain serving dish for 6.',
      ),
      brand: 'Chinor',
      price: 65000,
      unit: 'dona',
      unitValue: 1,
      stock: 12,
      minStock: 4,
      country: 'Xitoy',
    ),
    const Product(
      id: 'p17',
      categoryId: 'c10',
      name: L10n(uz: 'Shampun', ru: 'Шампунь', en: 'Shampoo'),
      description: L10n(
        uz: "Soch to'kilishiga qarshi shampun.",
        ru: 'Шампунь против выпадения волос.',
        en: 'Anti-hair-loss shampoo.',
      ),
      brand: 'Clear',
      price: 28000,
      unit: 'ml',
      unitValue: 400,
      stock: 38,
      minStock: 10,
      country: 'Turkiya',
    ),
    const Product(
      id: 'p18',
      categoryId: 'c10',
      name: L10n(
        uz: "Tualet qog'ozi",
        ru: 'Туалетная бумага',
        en: 'Toilet paper',
      ),
      description: L10n(
        uz: "3 qatlamli, yumshoq tualet qog'ozi.",
        ru: 'Трёхслойная мягкая бумага.',
        en: '3-ply soft toilet paper.',
      ),
      brand: 'Flo',
      price: 12000,
      unit: 'dona',
      unitValue: 4,
      stock: 100,
      minStock: 30,
      country: "O'zbekiston",
    ),
  ];

  late final List<Address> _addresses = [
    const Address(
      id: 'a1',
      label: 'home',
      city: 'Jizzax',
      address: "Mustaqillik ko'chasi, 12-uy, 5-kvartira",
      isDefault: true,
    ),
  ];

  final Set<String> _favorites = {};

  late final List<Order> _orders = [
    Order(
      id: 'o1',
      number: 'CM-1041',
      createdAt: DateTime(2026, 8, 16, 14, 20),
      status: OrderStatus.delivered,
      subtotal: 32000,
      deliveryFee: 0,
      total: 32000,
      addressText: 'Jizzax, Mustaqillik 12',
      deliverySlot: 'Bugun, 18:00–20:00',
      items: const [
        OrderItem(
          productId: 'p1',
          name: 'Sut 3,2%',
          price: 12000,
          qty: 2,
          unit: '1 litr',
        ),
        OrderItem(
          productId: 'p4',
          name: 'Patir non',
          price: 8000,
          qty: 1,
          unit: '1 dona',
        ),
      ],
    ),
    Order(
      id: 'o2',
      number: 'CM-1039',
      createdAt: DateTime(2026, 8, 9, 11, 40),
      status: OrderStatus.onway,
      subtotal: 69000,
      deliveryFee: 0,
      total: 69000,
      addressText: 'Jizzax, Mustaqillik 12',
      deliverySlot: 'Ertaga, 10:00–12:00',
      items: const [
        OrderItem(
          productId: 'p14',
          name: 'Kir yuvish kukuni',
          price: 45000,
          qty: 1,
          unit: '3 kg',
        ),
        OrderItem(
          productId: 'p15',
          name: 'Idish yuvish geli',
          price: 12000,
          qty: 2,
          unit: '500 ml',
        ),
      ],
    ),
  ];

  final List<UserProfile> _customers = const [
    UserProfile(
      id: 'u1',
      phone: '+998 90 123 45 67',
      fullName: 'Diyor Karimov',
    ),
    UserProfile(
      id: 'u2',
      phone: '+998 93 555 22 11',
      fullName: 'Malika Rahimova',
    ),
    UserProfile(
      id: 'u3',
      phone: '+998 91 777 33 09',
      fullName: "Jasur Toshpo'latov",
    ),
    UserProfile(
      id: 'u4',
      phone: '+998 94 201 88 44',
      fullName: "Nilufar Yo'ldosheva",
    ),
    UserProfile(
      id: 'u5',
      phone: '+998 99 340 12 76',
      fullName: 'Bekzod Sultonov',
    ),
  ];

  int _orderSeq = 1042;

  // ---------------- Auth ----------------
  @override
  Future<UserProfile?> signInWithPhone(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _user = UserProfile(
      id: 'demo-user',
      phone: phone,
      fullName: 'Diyor Karimov',
    );
    return _user;
  }

  @override
  Future<UserProfile?> verifyOtp(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _user ??= const UserProfile(
      id: 'demo-user',
      phone: '+998 90 123 45 67',
      fullName: 'Diyor Karimov',
    );
    return _user;
  }

  @override
  Future<void> signOut() async => _user = null;

  // ---------------- Katalog ----------------
  @override
  Future<List<Category>> fetchCategories() async => List.of(_categories);

  @override
  Future<List<Product>> fetchProducts() async => List.of(_products);

  @override
  Future<Product?> fetchProduct(String id) async {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ---------------- Manzillar ----------------
  @override
  Future<List<Address>> fetchAddresses() async => List.of(_addresses);

  @override
  Future<Address> addAddress(Address a) async {
    _addresses.add(a);
    return a;
  }

  @override
  Future<void> removeAddress(String id) async {
    _addresses.removeWhere((a) => a.id == id);
  }

  // ---------------- Buyurtmalar ----------------
  @override
  Future<List<Order>> fetchOrders() async => List.of(_orders);

  @override
  Future<Order> placeOrder(OrderDraft draft) async {
    final order = Order(
      id: 'o-${DateTime.now().millisecondsSinceEpoch}',
      number: 'CM-${_orderSeq++}',
      items: draft.items,
      subtotal: draft.subtotal,
      deliveryFee: draft.deliveryFee,
      total: draft.total,
      status: OrderStatus.accepted,
      createdAt: DateTime.now(),
      addressText: draft.addressText,
      deliverySlot: draft.deliverySlot,
      paymentMethod: draft.paymentMethod,
      comment: draft.comment,
    );
    _orders.insert(0, order);
    return order;
  }

  // ---------------- Sevimlilar ----------------
  @override
  Future<Set<String>> fetchFavorites() async => Set.of(_favorites);

  @override
  Future<void> setFavorite(String productId, bool fav) async {
    if (fav) {
      _favorites.add(productId);
    } else {
      _favorites.remove(productId);
    }
  }

  // ---------------- Admin ----------------
  @override
  Future<void> saveProduct(Product p) async {
    final i = _products.indexWhere((x) => x.id == p.id);
    if (i >= 0) {
      _products[i] = p;
    } else {
      _products.insert(0, p);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
  }

  @override
  Future<List<UserProfile>> fetchCustomers() async => List.of(_customers);

  @override
  Future<AdminStats> fetchStats() async => const AdminStats(
    todaySales: 2850000,
    ordersToday: 34,
    customers: 1280,
    avgCheck: 84000,
    weekSales: [820, 940, 760, 1100, 980, 1350, 1240],
    weekLabels: ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'],
  );

  @override
  Future<List<Order>> fetchAllOrders() async {
    final extra = [
      Order(
        id: 'o3',
        number: 'CM-1040',
        createdAt: DateTime(2026, 8, 11, 19, 5),
        status: OrderStatus.delivered,
        subtotal: 31000,
        total: 31000,
        addressText: 'Jizzax',
        items: const [
          OrderItem(productId: 'p11', name: 'Shokolad', price: 16000, qty: 1),
        ],
      ),
      Order(
        id: 'o4',
        number: 'CM-1038',
        createdAt: DateTime(2026, 8, 7, 9, 30),
        status: OrderStatus.preparing,
        subtotal: 28000,
        total: 28000,
        addressText: 'Jizzax',
        items: const [
          OrderItem(productId: 'p17', name: 'Shampun', price: 28000, qty: 1),
        ],
      ),
    ];
    return [...extra, ..._orders];
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final i = _orders.indexWhere((o) => o.id == orderId);
    if (i >= 0) {
      final old = _orders[i];
      _orders[i] = Order(
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
    }
  }

  @override
  Future<String> uploadImage(String fileName, Uint8List bytes) async {
    // Demo: lokal saqlash o'rniga fayl nomini qaytaramiz.
    return 'mock://$fileName';
  }
}
