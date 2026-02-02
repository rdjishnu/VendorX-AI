import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/utils/command_parser.dart';
import '../widgets/push_to_talk_button.dart';
import 'billing_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final VoiceService _voiceService = VoiceService();
  bool _isListening = false;
  String _searchText = "";

  String _liveText = "Using Microphone...";

  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
    _voiceService.isListeningNotifier.addListener(_syncVoiceState);
  }

  @override
  void dispose() {
    _voiceService.isListeningNotifier.removeListener(_syncVoiceState);
    super.dispose();
  }

  void _syncVoiceState() {
    if (mounted) {
      final isNowListening = _voiceService.isListeningNotifier.value;
      if (_isListening && !isNowListening) {
        setState(() => _isListening = false);
        _processCommand(_liveText);
      } else {
        setState(() => _isListening = isNowListening);
      }
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _voiceService.stop();
    } else {
      _liveText = "Listening...";
      bool started = await _voiceService.listen(onResult: (text) {
        setState(() => _liveText = text);
      });

      if (!started) {
        setState(() {
          _isListening = false;
          _liveText = "Microphone error.";
        });
      }
    }
  }

  void _processCommand(String text) {
    if (text.isEmpty || text == "Listening..." || text == "Using Microphone...") return;
    
    final items = CommandParser.parse(text);
    if (items.isNotEmpty) {
      _cartService.addItems(items);
      String message = items.length == 1 
          ? 'Added ${items.first.quantity} ${items.first.unit} of ${items.first.name}'
          : 'Added ${items.length} items';
       
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.secondaryColor),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not understand command'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Total Value Summary
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, Color(0xFFA2D325)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Value', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 5),
                            ListenableBuilder(
                              listenable: _cartService,
                              builder: (context, _) {
                                return Text(
                                  '₹ ${_cartService.totalCartValue.toStringAsFixed(0)}',
                                  style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                                );
                              },
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.currency_rupee, color: AppTheme.secondaryColor, size: 30),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchText = val),
                    style: const TextStyle(color: AppTheme.textDark),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search items...',
                      hintStyle: const TextStyle(color: AppTheme.textLight),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                
                // LIVE VOICE Box (if active)
                if (_isListening || _liveText != "Using Microphone...")
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mic, color: AppTheme.primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_liveText, style: const TextStyle(color: Colors.white))),
                        ],
                      ),
                    ),
                  ),

                // List
                Expanded(
                  child: ListenableBuilder(
                    listenable: _cartService,
                    builder: (context, child) {
                      final allItems = _cartService.items;
                      final filtered = _searchText.isEmpty 
                        ? allItems 
                        : allItems.where((i) => i.name.toLowerCase().contains(_searchText.toLowerCase())).toList();
                        
                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              Text('Cart is empty', style: GoogleFonts.inter(color: Colors.grey)),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 150),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.shopping_bag, color: AppTheme.secondaryColor),
                              ),
                              title: Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quantity: ${item.quantity.toStringAsFixed(1)} ${item.unit}',
                                    style: GoogleFonts.inter(color: AppTheme.textLight),
                                  ),
                                  Text(
                                    'Price: ₹${item.price.toStringAsFixed(0)}',
                                    style: GoogleFonts.inter(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildQtyBtn(Icons.remove, () => _cartService.updateQuantity(item.id, -1)),
                                  const SizedBox(width: 8),
                                  _buildQtyBtn(Icons.add, () => _cartService.updateQuantity(item.id, 1)),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                    onPressed: () => _cartService.removeItem(item.id),
                                  ),
                                ],
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
            
            // FLOATING PTT BUTTON & CHECKOUT
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListenableBuilder(
                      listenable: _cartService,
                      builder: (context, _) {
                        if (_cartService.items.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BillingScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: AppTheme.secondaryColor,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                              shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_cart_checkout),
                                const SizedBox(width: 12),
                                Text(
                                  'CHECKOUT (₹${_cartService.totalCartValue.toStringAsFixed(0)})',
                                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                    PushToTalkButton(
                      onPressed: _toggleListening,
                      isListening: _isListening,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.secondaryColor, size: 20),
      ),
    );
  }
}
