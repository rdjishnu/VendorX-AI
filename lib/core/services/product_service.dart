import 'package:flutter/material.dart';
import '../../features/home/domain/models/product.dart';

class ProductService extends ChangeNotifier {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final List<Product> _products = [
    Product(id: '1', name: 'Rice', unit: 'kg', basePrice: 60, stockQuantity: 50),
    Product(id: '2', name: 'Sugar', unit: 'kg', basePrice: 45, stockQuantity: 20),
    Product(id: '3', name: 'Milk', unit: 'packets', basePrice: 30, stockQuantity: 15),
    Product(id: '4', name: 'Atta', unit: 'kg', basePrice: 45, stockQuantity: 10),
    Product(id: '5', name: 'Oil', unit: 'liters', basePrice: 130, stockQuantity: 5),
    Product(id: '6', name: 'Toor Dal', unit: 'kg', basePrice: 120, stockQuantity: 8),
    Product(id: '7', name: 'Moong Dal', unit: 'kg', basePrice: 120, stockQuantity: 12),
    Product(id: '8', name: 'Tata Tea', unit: 'packets', basePrice: 40, stockQuantity: 30),
    Product(id: '9', name: 'Nescafe Coffee', unit: 'jars', basePrice: 250, stockQuantity: 10),
    Product(id: '10', name: 'Marie Biscuits', unit: 'packets', basePrice: 20, stockQuantity: 40),
    Product(id: '11', name: 'Bourbon Biscuits', unit: 'packets', basePrice: 30, stockQuantity: 25),
    Product(id: '12', name: 'Lux Soap', unit: 'bars', basePrice: 42, stockQuantity: 15),
    Product(id: '13', name: 'Lifebuoy Soap', unit: 'bars', basePrice: 33, stockQuantity: 20),
    Product(id: '14', name: 'Clinic Plus Shampoo', unit: 'sachets', basePrice: 2, stockQuantity: 100),
    Product(id: '15', name: 'Tata Salt', unit: 'packets', basePrice: 20, stockQuantity: 20),
    Product(id: '16', name: 'Turmeric Powder', unit: 'packets', basePrice: 50, stockQuantity: 15),
    Product(id: '17', name: 'Red Chilli Powder', unit: 'packets', basePrice: 60, stockQuantity: 15),
    Product(id: '18', name: 'Coriander Powder', unit: 'packets', basePrice: 40, stockQuantity: 15),
    Product(id: '19', name: 'Eggs', unit: 'pieces', basePrice: 6, stockQuantity: 120),
    Product(id: '20', name: 'Bread', unit: 'loaves', basePrice: 40, stockQuantity: 5),
    Product(id: '21', name: 'Maggi Noodles', unit: 'packets', basePrice: 12, stockQuantity: 50),
    Product(id: '22', name: 'Surf Excel', unit: 'kg', basePrice: 150, stockQuantity: 10),
    Product(id: '23', name: 'Vim Bar', unit: 'pieces', basePrice: 15, stockQuantity: 30),
    Product(id: '24', name: 'Toothbrush', unit: 'pieces', basePrice: 20, stockQuantity: 20),
    Product(id: '25', name: 'Colgate Toothpaste', unit: 'tubes', basePrice: 90, stockQuantity: 15),
  ];

  List<Product> get products => List.unmodifiable(_products);

  List<Product> search(String query) {
    if (query.isEmpty) return products;
    return _products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  void updateStock(String id, double delta) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final product = _products[index];
      _products[index] = product.copyWith(stockQuantity: (product.stockQuantity + delta).clamp(0, double.infinity));
      notifyListeners();
    }
  }

  void setPrice(String id, double newPrice) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(basePrice: newPrice);
      notifyListeners();
    }
  }

  void addProduct(Product product) {
    _products.insert(0, product);
    notifyListeners();
  }
}
