import '../core/l10n/strings.dart';

/// Uch tildagi matn (O'zbekcha / Русский / English).
class L10n {
  final String uz;
  final String ru;
  final String en;

  const L10n({this.uz = '', this.ru = '', this.en = ''});

  String tr(AppLang l) {
    if (l == AppLang.uz) return uz.isNotEmpty ? uz : ru;
    if (l == AppLang.ru) return ru.isNotEmpty ? ru : uz;
    return en.isNotEmpty ? en : uz;
  }

  Map<String, dynamic> toJson() => {'uz': uz, 'ru': ru, 'en': en};

  factory L10n.fromJson(dynamic j) {
    if (j is Map) {
      return L10n(
        uz: '${j['uz'] ?? ''}',
        ru: '${j['ru'] ?? ''}',
        en: '${j['en'] ?? ''}',
      );
    }
    final s = '$j';
    return L10n(uz: s, ru: s, en: s);
  }
}

enum OrderStatus { accepted, preparing, onway, delivered, cancelled }

OrderStatus orderStatusFrom(String? s) {
  switch (s) {
    case 'preparing':
      return OrderStatus.preparing;
    case 'onway':
      return OrderStatus.onway;
    case 'delivered':
      return OrderStatus.delivered;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.accepted;
  }
}

String orderStatusTo(OrderStatus s) {
  switch (s) {
    case OrderStatus.preparing:
      return 'preparing';
    case OrderStatus.onway:
      return 'onway';
    case OrderStatus.delivered:
      return 'delivered';
    case OrderStatus.cancelled:
      return 'cancelled';
    default:
      return 'accepted';
  }
}

/// Kategoriya (oziq-ovqat / uy-ro'zg'or).
class Category {
  final String id;
  final String slug;
  final L10n name;
  final String emoji;
  final bool isHousehold;

  const Category({
    required this.id,
    required this.slug,
    required this.name,
    this.emoji = '🛒',
    this.isHousehold = false,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id: '${j['id']}',
    slug: '${j['slug'] ?? ''}',
    name: L10n.fromJson(j['name'] ?? {}),
    emoji: '${j['emoji'] ?? '🛒'}',
    isHousehold: j['is_household'] == true,
  );
}

/// Mahsulot — to'liq (kengaytirilgan) ma'lumotlar bilan.
class Product {
  final String id;
  final String categoryId;
  final L10n name;
  final L10n description;
  final String brand;
  final String sku;
  final double price;
  final double? oldPrice;
  final String unit; // kg | litr | dona | g | ml
  final double unitValue;
  final int stock;
  final int minStock;
  final List<String> images; // URL yoki lokal yo'l
  final String? videoUrl;
  final List<String> tags;
  final String country;
  final String manufacturer;
  final double? weightKg;
  final bool isActive;

  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description = const L10n(),
    this.brand = '',
    this.sku = '',
    required this.price,
    this.oldPrice,
    this.unit = 'dona',
    this.unitValue = 1,
    this.stock = 0,
    this.minStock = 5,
    this.images = const [],
    this.videoUrl,
    this.tags = const [],
    this.country = '',
    this.manufacturer = '',
    this.weightKg,
    this.isActive = true,
  });

  double get discountPercent {
    if (oldPrice == null || oldPrice! <= 0 || oldPrice! <= price) return 0;
    return ((1 - price / oldPrice!) * 100).roundToDouble();
  }

  String unitLabel(AppLang lang) {
    final v = unitValue == 1 ? '' : _fmtUnit(unitValue);
    final base = S.t(lang, _unitKey(unit));
    return '$v $base'.trim();
  }

  String _unitKey(String u) {
    switch (u) {
      case 'kg':
        return 'uKg';
      case 'litr':
        return 'uL';
      case 'g':
        return 'uG';
      case 'ml':
        return 'uMl';
      default:
        return 'uPcs';
    }
  }

  String _fmtUnit(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'name': name.toJson(),
    'description': description.toJson(),
    'brand': brand,
    'sku': sku,
    'price': price,
    'old_price': oldPrice,
    'unit': unit,
    'unit_value': unitValue,
    'stock': stock,
    'min_stock': minStock,
    'images': images,
    'video_url': videoUrl,
    'tags': tags,
    'country_origin': country,
    'manufacturer': manufacturer,
    'weight_kg': weightKg,
    'is_active': isActive,
  };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: '${j['id']}',
    categoryId: '${j['category_id'] ?? ''}',
    name: L10n.fromJson(j['name'] ?? {}),
    description: L10n.fromJson(j['description'] ?? {}),
    brand: '${j['brand'] ?? ''}',
    sku: '${j['sku'] ?? ''}',
    price: (num.tryParse('${j['price'] ?? 0}') ?? 0).toDouble(),
    oldPrice: j['old_price'] == null
        ? null
        : (num.tryParse('${j['old_price']}') ?? 0).toDouble(),
    unit: '${j['unit'] ?? 'dona'}',
    unitValue: (num.tryParse('${j['unit_value'] ?? 1}') ?? 1).toDouble(),
    stock: (num.tryParse('${j['stock'] ?? 0}') ?? 0).toInt(),
    minStock: (num.tryParse('${j['min_stock'] ?? 5}') ?? 5).toInt(),
    images: _list(j['images']),
    videoUrl: j['video_url'] == null ? null : '${j['video_url']}',
    tags: _list(j['tags']),
    country: '${j['country_origin'] ?? ''}',
    manufacturer: '${j['manufacturer'] ?? ''}',
    weightKg: j['weight_kg'] == null
        ? null
        : (num.tryParse('${j['weight_kg']}') ?? 0).toDouble(),
    isActive: j['is_active'] != false,
  );

  static List<String> _list(dynamic v) {
    if (v is List) return v.map((e) => '$e').toList();
    return const [];
  }
}

/// Yetkazib berish manzili.
class Address {
  final String id;
  final String label; // home | work | other
  final String city;
  final String address;
  final bool isDefault;

  const Address({
    required this.id,
    this.label = 'home',
    this.city = 'Jizzax',
    required this.address,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> j) => Address(
    id: '${j['id']}',
    label: '${j['label'] ?? 'home'}',
    city: '${j['city'] ?? ''}',
    address: '${j['address'] ?? ''}',
    isDefault: j['is_default'] == true,
  );
}

/// Buyurtma qatori.
class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int qty;
  final String unit;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    this.qty = 1,
    this.unit = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    productId: '${j['product_id'] ?? ''}',
    name: '${j['name'] ?? ''}',
    price: (num.tryParse('${j['price'] ?? 0}') ?? 0).toDouble(),
    qty: (num.tryParse('${j['qty'] ?? 1}') ?? 1).toInt(),
    unit: '${j['unit'] ?? ''}',
  );
}

/// Buyurtma.
class Order {
  final String id;
  final String number;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String addressText;
  final String deliverySlot;
  final String paymentMethod;
  final String comment;

  const Order({
    required this.id,
    required this.number,
    required this.items,
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.total = 0,
    this.status = OrderStatus.accepted,
    required this.createdAt,
    this.addressText = '',
    this.deliverySlot = '',
    this.paymentMethod = 'cash',
    this.comment = '',
  });

  int get itemCount => items.fold(0, (a, b) => a + b.qty);

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id: '${j['id']}',
    number: '${j['number'] ?? ''}',
    items: j['items'] is List
        ? (j['items'] as List)
              .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : const [],
    subtotal: (num.tryParse('${j['subtotal'] ?? 0}') ?? 0).toDouble(),
    deliveryFee: (num.tryParse('${j['delivery_fee'] ?? 0}') ?? 0).toDouble(),
    total: (num.tryParse('${j['total'] ?? 0}') ?? 0).toDouble(),
    status: orderStatusFrom('${j['status']}'),
    createdAt: DateTime.tryParse('${j['created_at'] ?? ''}') ?? DateTime.now(),
    addressText: '${j['address_text'] ?? ''}',
    deliverySlot: '${j['delivery_slot'] ?? ''}',
    paymentMethod: '${j['payment_method'] ?? 'cash'}',
    comment: '${j['comment'] ?? ''}',
  );
}

/// Buyurtma qoralamasi (joylashdan oldin).
class OrderDraft {
  final List<OrderItem> items;
  final String addressText;
  final String deliverySlot;
  final String paymentMethod;
  final String comment;
  final double subtotal;
  final double deliveryFee;
  final double total;

  const OrderDraft({
    required this.items,
    required this.addressText,
    required this.deliverySlot,
    this.paymentMethod = 'cash',
    this.comment = '',
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });
}

/// Foydalanuvchi profili.
class UserProfile {
  final String id;
  final String phone;
  final String fullName;

  const UserProfile({
    required this.id,
    required this.phone,
    this.fullName = '',
  });
}

/// Admin statistika.
class AdminStats {
  final double todaySales;
  final int ordersToday;
  final int customers;
  final double avgCheck;
  final List<double> weekSales;
  final List<String> weekLabels;

  const AdminStats({
    this.todaySales = 0,
    this.ordersToday = 0,
    this.customers = 0,
    this.avgCheck = 0,
    this.weekSales = const [],
    this.weekLabels = const [],
  });
}
