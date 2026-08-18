import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'mock_repository.dart';
import 'repository.dart';

/// Haqiqiy Supabase backend.
///
/// Ulanish ma'lumotlari `--dart-define` orqali beriladi:
///   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=eyJ...
/// Agar berilmagan bo'lsa, avtomatik MockRepository (demo rejim) ishlaydi.
class SupabaseRepository implements AppRepository {
  SupabaseRepository._(this.client);

  final SupabaseClient client;

  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _key = String.fromEnvironment('SUPABASE_ANON_KEY');

  static Future<AppRepository> create() async {
    if (_url.isEmpty || _key.isEmpty) {
      return MockRepository();
    }
    try {
      final client = await Supabase.initialize(url: _url, anonKey: _key);
      return SupabaseRepository._(client);
    } catch (_) {
      return MockRepository();
    }
  }

  User? get _authUser => client.auth.currentUser;
  String? _pendingPhone;

  // ---------------- Auth ----------------
  @override
  Future<UserProfile?> signInWithPhone(String phone) async {
    _pendingPhone = phone;
    await client.auth.signInWithOtp(phone: phone);
    final u = _authUser;
    if (u == null) return null;
    return UserProfile(id: u.id, phone: phone);
  }

  @override
  Future<UserProfile?> verifyOtp(String code) async {
    final res = await client.auth.verifyOTP(
      type: OtpType.sms,
      token: code,
      phone: _pendingPhone,
    );
    final u = res.user ?? _authUser;
    if (u == null) return null;
    return UserProfile(id: u.id, phone: u.phone ?? _pendingPhone ?? '');
  }

  @override
  Future<void> signOut() async => client.auth.signOut();

  // ---------------- Katalog ----------------
  @override
  Future<List<Category>> fetchCategories() async {
    final rows = await client
        .from('categories')
        .select()
        .order('order', ascending: true);
    return rows.map((e) => Category.fromJson(e)).toList();
  }

  @override
  Future<List<Product>> fetchProducts() async {
    final rows = await client
        .from('products')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return rows.map((e) => Product.fromJson(e)).toList();
  }

  @override
  Future<Product?> fetchProduct(String id) async {
    final rows = await client.from('products').select().eq('id', id).limit(1);
    if (rows.isEmpty) return null;
    return Product.fromJson(rows.first);
  }

  // ---------------- Manzillar ----------------
  @override
  Future<List<Address>> fetchAddresses() async {
    final u = _authUser;
    if (u == null) return const [];
    final rows = await client.from('addresses').select().eq('user_id', u.id);
    return rows.map((e) => Address.fromJson(e)).toList();
  }

  @override
  Future<Address> addAddress(Address a) async {
    final u = _authUser;
    if (u == null) return a;
    final rows = await client.from('addresses').insert({
      'id': a.id.isEmpty ? null : a.id,
      'user_id': u.id,
      'label': a.label,
      'city': a.city,
      'address': a.address,
      'is_default': a.isDefault,
    }).select();
    return Address.fromJson(rows.first);
  }

  @override
  Future<void> removeAddress(String id) async {
    await client.from('addresses').delete().eq('id', id);
  }

  // ---------------- Buyurtmalar ----------------
  @override
  Future<List<Order>> fetchOrders() async {
    final u = _authUser;
    if (u == null) return const [];
    final rows = await client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', u.id)
        .order('created_at', ascending: false);
    return rows.map(_orderFromRow).toList();
  }

  Order _orderFromRow(Map<String, dynamic> j) {
    final items = j['order_items'];
    return Order(
      id: '${j['id']}',
      number: '${j['number'] ?? ''}',
      items: items is List
          ? items
                .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
      subtotal: (num.tryParse('${j['subtotal'] ?? 0}') ?? 0).toDouble(),
      deliveryFee: (num.tryParse('${j['delivery_fee'] ?? 0}') ?? 0).toDouble(),
      total: (num.tryParse('${j['total'] ?? 0}') ?? 0).toDouble(),
      status: orderStatusFrom('${j['status']}'),
      createdAt:
          DateTime.tryParse('${j['created_at'] ?? ''}') ?? DateTime.now(),
      addressText: '${j['address_text'] ?? ''}',
      deliverySlot: '${j['delivery_slot'] ?? ''}',
      paymentMethod: '${j['payment_method'] ?? 'cash'}',
      comment: '${j['comment'] ?? ''}',
    );
  }

  @override
  Future<Order> placeOrder(OrderDraft draft) async {
    final u = _authUser;
    final rows = await client.from('orders').insert({
      'user_id': u?.id,
      'number': 'CM-${DateTime.now().millisecondsSinceEpoch % 100000}',
      'address_text': draft.addressText,
      'delivery_slot': draft.deliverySlot,
      'payment_method': draft.paymentMethod,
      'comment': draft.comment,
      'subtotal': draft.subtotal,
      'delivery_fee': draft.deliveryFee,
      'total': draft.total,
      'status': 'accepted',
    }).select();

    final orderId = rows.first['id'];
    final items = draft.items
        .map(
          (i) => {
            'order_id': orderId,
            'product_id': i.productId,
            'name': i.name,
            'price': i.price,
            'qty': i.qty,
            'unit': i.unit,
          },
        )
        .toList();
    await client.from('order_items').insert(items);

    return Order(
      id: '$orderId',
      number: '${rows.first['number']}',
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
  }

  // ---------------- Sevimlilar ----------------
  @override
  Future<Set<String>> fetchFavorites() async {
    final u = _authUser;
    if (u == null) return {};
    final rows = await client
        .from('favorites')
        .select('product_id')
        .eq('user_id', u.id);
    return rows.map((e) => '${e['product_id']}').toSet();
  }

  @override
  Future<void> setFavorite(String productId, bool fav) async {
    final u = _authUser;
    if (u == null) return;
    if (fav) {
      await client.from('favorites').upsert({
        'user_id': u.id,
        'product_id': productId,
      });
    } else {
      await client
          .from('favorites')
          .delete()
          .eq('user_id', u.id)
          .eq('product_id', productId);
    }
  }

  // ---------------- Admin ----------------
  @override
  Future<void> saveProduct(Product p) async {
    await client.from('products').upsert(p.toJson()..remove('id'));
  }

  @override
  Future<void> deleteProduct(String id) async {
    await client.from('products').delete().eq('id', id);
  }

  @override
  Future<List<UserProfile>> fetchCustomers() async {
    final rows = await client.from('profiles').select();
    return rows
        .map(
          (e) => UserProfile(
            id: '${e['id']}',
            phone: '${e['phone'] ?? ''}',
            fullName: '${e['full_name'] ?? ''}',
          ),
        )
        .toList();
  }

  @override
  Future<AdminStats> fetchStats() async {
    return const AdminStats();
  }

  @override
  Future<List<Order>> fetchAllOrders() async {
    final rows = await client
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false)
        .limit(50);
    return rows.map(_orderFromRow).toList();
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await client
        .from('orders')
        .update({'status': orderStatusTo(status)})
        .eq('id', orderId);
  }

  @override
  Future<String> uploadImage(String fileName, Uint8List bytes) async {
    final path = 'products/$fileName';
    await client.storage
        .from('products')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return client.storage.from('products').getPublicUrl(path);
  }
}
