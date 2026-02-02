import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/khata_service.dart';

class KhataScreen extends StatefulWidget {
  const KhataScreen({super.key});

  @override
  State<KhataScreen> createState() => _KhataScreenState();
}

class _KhataScreenState extends State<KhataScreen> {
  final KhataService _khataService = KhataService();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text('Digital Khata', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D5FEF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Intro
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manage customer credit and send reminders.', 
                      style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
                  ],
                ),
              ),
            ),

            // Summary Cards
            ListenableBuilder(
              listenable: _khataService,
              builder: (context, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildSummaryCard('TOTAL CREDIT', '₹${_khataService.totalCreditGiven.toStringAsFixed(0)}', Icons.north_east, Colors.red.shade50, Colors.red),
                    const SizedBox(width: 12),
                    _buildSummaryCard('ACTIVE CUST.', '${_khataService.activeCustomers}', Icons.south_west, Colors.green.shade50, Colors.green),
                    const SizedBox(width: 12),
                    _buildSummaryCard('REMINDERS', '12', Icons.chat_bubble_outline, Colors.blue.shade50, Colors.blue),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Search by name or phone number...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer List (Table-like Header)
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('CUSTOMER NAME', style: _headerStyle())),
                        Expanded(flex: 3, child: Text('PHONE NUMBER', style: _headerStyle())),
                        Expanded(flex: 2, child: Text('BALANCE', style: _headerStyle())),
                        Expanded(flex: 2, child: Text('ACTIONS', style: _headerStyle(), textAlign: TextAlign.right)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListenableBuilder(
                    listenable: _khataService,
                    builder: (context, _) {
                      final filtered = _khataService.customers.where((c) => 
                        c.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                        c.phone.contains(_searchQuery)).toList();
                      
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final customer = filtered[index];
                          return _buildCustomerRow(customer);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headerStyle() => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 0.5);

  Widget _buildSummaryCard(String label, String value, IconData icon, Color bgColor, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerRow(KhataCustomer customer) {
    final hasBalance = customer.balance > 0;
    return InkWell(
      onTap: () => _showReduceCreditAction(customer),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue.shade50,
                    child: Text(customer.name[0], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(customer.phone, style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 2,
              child: Text('₹${customer.balance.toStringAsFixed(0)}', 
                style: TextStyle(fontWeight: FontWeight.bold, color: hasBalance ? Colors.red : Colors.grey, fontSize: 13)),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReduceCreditAction(KhataCustomer customer) {
    if (customer.balance == 0) return;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Collect Payment: ${customer.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Due: ₹${customer.balance.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount Paid', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                _khataService.updateBalance(customer.id, -amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Updated balance for ${customer.name}')));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
