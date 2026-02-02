class Product {
  final String id;
  final String name;
  final String unit;
  final double basePrice;
  final double stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.basePrice,
    this.stockQuantity = 0,
  });

  Product copyWith({
    String? id,
    String? name,
    String? unit,
    double? basePrice,
    double? stockQuantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      basePrice: basePrice ?? this.basePrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }

  @override
  String toString() => name;
}
