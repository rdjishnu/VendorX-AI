class CartItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final DateTime timestamp;
  final double price;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.timestamp,
    this.price = 0.0,
  });

  CartItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    DateTime? timestamp,
    double? price,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      price: price ?? this.price,
    );
  }

  @override
  String toString() {
    return '$quantity $unit $name (₹$price)';
  }
}
