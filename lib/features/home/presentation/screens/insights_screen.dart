import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/finance_service.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = FinanceService();
    final cartService = CartService();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text('Business Insights', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profit & Loss Brief
            Text('PROFIT & LOSS STATEMENT', style: _sectionTitleStyle()),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF333333)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Net Profit', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('₹${(finance.totalIncome - finance.totalExpense).toStringAsFixed(0)}', 
                            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.trending_up, color: Colors.green, size: 16),
                            SizedBox(width: 4),
                            Text('+12.5%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 32),
                  _buildPlRow('Income', '₹${finance.totalIncome.toStringAsFixed(0)}', Colors.green),
                  const SizedBox(height: 12),
                  _buildPlRow('Expense', '₹${finance.totalExpense.toStringAsFixed(0)}', Colors.redAccent),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Sales Breakdown Section
            Text('SALES BREAKDOWN', style: _sectionTitleStyle()),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInsightCard('UPI Sales', '₹${finance.upiSales.toStringAsFixed(0)}', Icons.qr_code_2, Colors.orange),
                const SizedBox(width: 12),
                _buildInsightCard('Cash Sales', '₹${finance.cashSales.toStringAsFixed(0)}', Icons.payments_outlined, Colors.green),
              ],
            ),
            
            const SizedBox(height: 32),

            // STOCK LIST SECTION (Now showing items in Cart)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ITEMS IN CART', style: _sectionTitleStyle()),
                ListenableBuilder(
                  listenable: cartService,
                  builder: (context, _) => Text('${cartService.items.length} Items', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: cartService,
              builder: (context, _) {
                final items = cartService.items;
                if (items.isEmpty) return _buildEmptyState('No items in cart');
                
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${item.quantity} ${item.unit}', style: const TextStyle(fontSize: 12)),
                        trailing: Text('₹${item.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // TRANSACTION HISTORY
            Text('RECENT TRANSACTIONS', style: _sectionTitleStyle()),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: finance,
              builder: (context, _) {
                final txs = finance.transactions;
                if (txs.isEmpty) return _buildEmptyState('No recent transactions');
                
                return Column(
                  children: txs.map((tx) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(DateFormat('dd MMM, hh:mm a').format(tx.date), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                        Text(
                          '${tx.type == PaymentType.upi ? "+" : ""} ₹${tx.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: tx.amount > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                );
              },
            ),

            const SizedBox(height: 32),

            // HYPER-LOCAL SIGNALS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text('Hyper-Local Signals', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: Colors.green))),
              ],
            ),
            const SizedBox(height: 12),
            _buildSignalAlert(
              icon: Icons.calendar_month,
              iconColor: Colors.white,
              bgColor: const Color(0xFF00B67A),
              title: 'Thai Pusam Alert',
              description: 'High Milk & Fruit Demand expected on Feb 1st. Restock 40% higher than usual.',
            ),
            _buildSignalAlert(
              icon: Icons.cloud_outlined,
              iconColor: Colors.white,
              bgColor: Colors.blue,
              title: 'Weather Warning',
              description: 'Heavy Rain likely this evening. Impulse snack sales (chips/biscuits) trend up by 25%.',
              isAlert: true,
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _sectionTitleStyle() => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2);

  Widget _buildPlRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalAlert({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String description,
    bool isAlert = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (isAlert) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                        child: const Text('ALERT', style: TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ),
    );
  }
}
