import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/product_service.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../features/home/domain/models/cart_item.dart';
import '../../../../features/home/domain/models/product.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  String _searchText = "";

  void _addToCart(Product product) {
    if (product.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item out of stock!'), backgroundColor: Colors.red),
      );
      return;
    }

    final cartItem = CartItem(
      id: const Uuid().v4(),
      name: product.name,
      quantity: 1.0,
      unit: product.unit,
      timestamp: DateTime.now(),
      price: product.basePrice,
    );
    _cartService.addItem(cartItem);
    _productService.updateStock(product.id, -1);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to Cart'),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final unitController = TextEditingController(text: 'kg');
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Product', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Product Name')),
              TextField(controller: unitController, decoration: const InputDecoration(labelText: 'Unit (e.g. kg, packets)')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price (₹)'), keyboardType: TextInputType.number),
              TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Initial Stock'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final newProduct = Product(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  unit: unitController.text,
                  basePrice: double.tryParse(priceController.text) ?? 0,
                  stockQuantity: double.tryParse(stockController.text) ?? 0,
                );
                _productService.addProduct(newProduct);
                Navigator.pop(context);
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  void _showEditStockDialog(Product product) {
    final priceController = TextEditingController(text: product.basePrice.toString());
    final stockController = TextEditingController(text: product.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${product.name}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price (₹)'), keyboardType: TextInputType.number),
            TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Current Stock'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(priceController.text) ?? product.basePrice;
              final newStock = double.tryParse(stockController.text) ?? product.stockQuantity;
              _productService.setPrice(product.id, newPrice);
              _productService.updateStock(product.id, newStock - product.stockQuantity);
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Inventory Management', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Product'),
        backgroundColor: AppTheme.secondaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchText = val),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _productService,
              builder: (context, child) {
                final filtered = _productService.search(_searchText);
                if (filtered.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Row(
                          children: [
                            Expanded(child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.textLight),
                              onPressed: () => _showEditStockDialog(product),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('₹${product.basePrice}', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                                Text(' / ${product.unit}', style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (product.stockQuantity > 0 ? Colors.green : Colors.red).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Stock: ${product.stockQuantity.toStringAsFixed(0)} ${product.unit}',
                                style: TextStyle(
                                  color: product.stockQuantity > 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _addToCart(product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: AppTheme.secondaryColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('ADD TO CART'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
