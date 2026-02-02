import 'package:flutter/foundation.dart';
import '../../features/home/domain/models/cart_item.dart';
import 'package:uuid/uuid.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  
  final List<CartItem> _items = [];
  final _uuid = const Uuid();

  CartService._internal() {
    _seedData();
  }

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalCartValue => _items.fold(0, (sum, item) => sum + item.price);

  Map<String, double> get categoryBreakdown {
    final Map<String, double> breakdown = {};
    for (var item in _items) {
      breakdown[item.name] = (breakdown[item.name] ?? 0) + item.price;
    }
    return breakdown;
  }

  void addItem(CartItem item) {
    _items.insert(0, item);
    notifyListeners();
  }

  void addItems(List<CartItem> newItems) {
    _items.insertAll(0, newItems);
    notifyListeners();
  }

  void _seedData() {
    // Cart starts empty
  }

  void updateQuantity(String id, double delta) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _items[index];
      final newQty = (item.quantity + delta).clamp(0.0, double.infinity);
      
      // Calculate unit price from current total and qty
      final unitPrice = item.quantity > 0 ? item.price / item.quantity : 0.0;
      
      _items[index] = item.copyWith(
        quantity: newQty,
        price: unitPrice * newQty,
      );
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

