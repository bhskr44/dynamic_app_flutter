import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String productId;
  final String title;
  final String? image;
  final double price;
  int quantity;
  final Map<String, dynamic>? variant; // size, color, etc.
  final Map<String, dynamic>? metadata; // additional data

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    this.image,
    required this.price,
    this.quantity = 1,
    this.variant,
    this.metadata,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'title': title,
        'image': image,
        'price': price,
        'quantity': quantity,
        'variant': variant,
        'metadata': metadata,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id']?.toString() ?? '',
        productId: json['productId']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        image: json['image']?.toString(),
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        variant: json['variant'] as Map<String, dynamic>?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  static const String _cartKey = 'shopping_cart';
  static const String _wishlistKey = 'wishlist';

  List<CartItem> _items = [];
  List<String> _wishlist = [];

  List<CartItem> get items => List.unmodifiable(_items);
  List<String> get wishlist => List.unmodifiable(_wishlist);
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.total);
  
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  /// Initialize cart from storage
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load cart
      final cartJson = prefs.getString(_cartKey);
      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        _items = decoded.map((item) => CartItem.fromJson(item)).toList();
      }

      // Load wishlist
      final wishlistJson = prefs.getString(_wishlistKey);
      if (wishlistJson != null) {
        final List<dynamic> decoded = jsonDecode(wishlistJson);
        _wishlist = decoded.map((e) => e.toString()).toList();
      }

      notifyListeners();
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  /// Save cart to storage
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save cart
      final cartJson = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, cartJson);

      // Save wishlist
      final wishlistJson = jsonEncode(_wishlist);
      await prefs.setString(_wishlistKey, wishlistJson);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  /// Add item to cart
  Future<void> addItem({
    required String productId,
    required String title,
    String? image,
    required double price,
    int quantity = 1,
    Map<String, dynamic>? variant,
    Map<String, dynamic>? metadata,
  }) async {
    // Generate unique ID based on product and variant
    final variantKey = variant != null ? jsonEncode(variant) : '';
    final id = '$productId-$variantKey';

    // Check if item already exists
    final existingIndex = _items.indexWhere((item) => item.id == id);
    
    if (existingIndex >= 0) {
      // Update quantity
      _items[existingIndex].quantity += quantity;
    } else {
      // Add new item
      _items.add(CartItem(
        id: id,
        productId: productId,
        title: title,
        image: image,
        price: price,
        quantity: quantity,
        variant: variant,
        metadata: metadata,
      ));
    }

    await _save();
    notifyListeners();
  }

  /// Remove item from cart
  Future<void> removeItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _save();
    notifyListeners();
  }

  /// Update item quantity
  Future<void> updateQuantity(String id, int quantity) async {
    if (quantity <= 0) {
      await removeItem(id);
      return;
    }

    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].quantity = quantity;
      await _save();
      notifyListeners();
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    _items.clear();
    await _save();
    notifyListeners();
  }

  /// Get item by ID
  CartItem? getItem(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if product is in cart
  bool isInCart(String productId, {Map<String, dynamic>? variant}) {
    final variantKey = variant != null ? jsonEncode(variant) : '';
    final id = '$productId-$variantKey';
    return _items.any((item) => item.id == id);
  }

  /// Get quantity of specific product in cart
  int getQuantity(String productId, {Map<String, dynamic>? variant}) {
    final variantKey = variant != null ? jsonEncode(variant) : '';
    final id = '$productId-$variantKey';
    final item = _items.firstWhere(
      (item) => item.id == id,
      orElse: () => CartItem(id: '', productId: '', title: '', price: 0, quantity: 0),
    );
    return item.quantity;
  }

  // Wishlist methods

  /// Add to wishlist
  Future<void> addToWishlist(String productId) async {
    if (!_wishlist.contains(productId)) {
      _wishlist.add(productId);
      await _save();
      notifyListeners();
    }
  }

  /// Remove from wishlist
  Future<void> removeFromWishlist(String productId) async {
    _wishlist.remove(productId);
    await _save();
    notifyListeners();
  }

  /// Toggle wishlist
  Future<void> toggleWishlist(String productId) async {
    if (_wishlist.contains(productId)) {
      await removeFromWishlist(productId);
    } else {
      await addToWishlist(productId);
    }
  }

  /// Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _wishlist.contains(productId);
  }
}
