import 'dart:typed_data';

import '../models/models.dart';

/// Barcha ma'lumotlar manbalari uchun yagona interfeys.
/// SupabaseRepository (haqiqiy backend) va MockRepository (demo rejim)
/// shu interfeysni amalga oshiradi — shu tufayli ilova Supabase'ga
/// ulanmasdan ham ishlayveradi.
abstract class AppRepository {
  // ---- Auth ----
  Future<UserProfile?> signInWithPhone(String phone);
  Future<UserProfile?> verifyOtp(String code);
  Future<void> signOut();

  // ---- Katalog ----
  Future<List<Category>> fetchCategories();
  Future<List<Product>> fetchProducts();
  Future<Product?> fetchProduct(String id);

  // ---- Manzillar ----
  Future<List<Address>> fetchAddresses();
  Future<Address> addAddress(Address a);
  Future<void> removeAddress(String id);

  // ---- Buyurtmalar ----
  Future<List<Order>> fetchOrders();
  Future<Order> placeOrder(OrderDraft draft);

  // ---- Sevimlilar ----
  Future<Set<String>> fetchFavorites();
  Future<void> setFavorite(String productId, bool fav);

  // ---- Admin ----
  Future<void> saveProduct(Product p);
  Future<void> deleteProduct(String id);
  Future<List<UserProfile>> fetchCustomers();
  Future<AdminStats> fetchStats();
  Future<List<Order>> fetchAllOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus status);

  /// Rasmni Storage'ga yuklab, ommaviy URL'ni qaytaradi.
  /// Mock rejimda lokal yo'lni qaytaradi.
  Future<String> uploadImage(String fileName, Uint8List bytes);
}
