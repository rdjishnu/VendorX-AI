import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/finance_service.dart';
import '../../../../core/services/shop_service.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Final Bill', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: ListenableBuilder(
        listenable: cartService,
        builder: (context, _) {
          final items = cartService.items;
          final total = cartService.totalCartValue;

          return Column(
            children: [
              // Total Display
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: AppTheme.backgroundColor, width: 2)),
                ),
                child: Column(
                  children: [
                    Text('TOTAL AMOUNT', style: GoogleFonts.inter(color: AppTheme.textLight, letterSpacing: 2, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(
                      '₹ ${total.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: items.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_outlined, size: 80, color: Colors.grey.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text('No items in bill', style: GoogleFonts.inter(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('${item.quantity} ${item.unit} x ₹${(item.price/item.quantity).toStringAsFixed(0)}', 
                                      style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
                                  ],
                                ),
                              ),
                              Text('₹ ${item.price.toStringAsFixed(0)}', 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                            ],
                          ),
                        );
                      },
                    ),
              ),
              
              // Checkout Bar
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
                ),
                child: ElevatedButton(
                  onPressed: items.isEmpty ? null : () => _showPaymentOptions(context, total),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("PROCEED TO PAY", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showPaymentOptions(BuildContext context, double amount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Payment Mode', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 20),
              
              // UPI Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.qr_code_2, color: Colors.orange),
                ),
                title: const Text('UPI / QR Code', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Generate QR for ₹$amount'),
                onTap: () {
                  Navigator.pop(context);
                  _showQRCode(context, amount);
                },
              ),
              const SizedBox(height: 10),
              
              // Cash Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.money, color: Colors.green),
                ),
                title: const Text('Cash Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Verify Cash Received'),
                onTap: () {
                  Navigator.pop(context);
                  _showCashVerification(context, amount);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQRCode(BuildContext context, double amount) {
    final shopName = ShopService().shopName;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/images/logo.png', height: 60, width: 60, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Text(shopName, style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 8),
              Text('₹ ${amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                height: 220, 
                width: 220, 
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_2, color: Colors.black, size: 180),
              ),
              const SizedBox(height: 24),
              const Text('Scan using any UPI App', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  FinanceService().recordSale(amount, PaymentType.upi);
                  CartService().clear();
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to Home/Inventory
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification Successful! Payment Received.'), backgroundColor: Colors.green),
                  );
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Simulate Success'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showCashVerification(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              Text('Verify ₹${amount.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Did you receive the cash from customer?', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('No'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        FinanceService().recordSale(amount, PaymentType.cash);
                        CartService().clear();
                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cash Payment Recorded!'), backgroundColor: Colors.green));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Yes, Received'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
