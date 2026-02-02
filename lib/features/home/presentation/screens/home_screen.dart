import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/finance_service.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/services/shop_service.dart';
import '../../../../core/utils/command_parser.dart';
import '../widgets/push_to_talk_button.dart';
import 'cart_screen.dart';
import 'inventory_screen.dart';
import 'billing_screen.dart';
import 'khata_screen.dart';
import 'insights_screen.dart';
import 'shop_profile_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VoiceService _voiceService = VoiceService();
  final CartService _cartService = CartService();
  bool _isListening = false;
  String _liveText = "Using Microphone...";

  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
    
    // Sync UI state with actual voice service status
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${items.length} items to Cart'), backgroundColor: AppTheme.secondaryColor),
      );
    }
 else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not understand command'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 45,
                                width: 45,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome Back,', style: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 13)),
                              ListenableBuilder(
                                listenable: ShopService(),
                                builder: (context, _) => Text(
                                  ShopService().shopName,
                                  style: GoogleFonts.outfit(color: AppTheme.textDark, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'profile') {
                            _nav(const ShopProfileScreen());
                          } else if (value == 'logout') {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                Icon(Icons.person_outline, size: 20, color: AppTheme.secondaryColor),
                                SizedBox(width: 8),
                                Text('Shop Profile'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Logout', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        child: const CircleAvatar(
                          backgroundColor: AppTheme.secondaryColor,
                          child: Icon(Icons.store, color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // SUMMARY CARDS ROW
                  ListenableBuilder(
                    listenable: FinanceService(),
                    builder: (context, _) {
                      final finance = FinanceService();
                      return Row(
                        children: [
                          Expanded(child: _buildSummaryCard(Icons.account_balance_wallet, 'Balance', '₹${finance.totalBalance.toStringAsFixed(0)}', AppTheme.primaryColor, true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSummaryCard(Icons.arrow_upward, 'Income', '₹${(finance.totalIncome / 1000).toStringAsFixed(1)}K', Colors.white, false)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSummaryCard(Icons.arrow_downward, 'Expense', '₹${(finance.totalExpense / 1000).toStringAsFixed(1)}K', Colors.white, false)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // CHART SECTION (Simplistic UI representation)
                  Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                  const SizedBox(height: 12),
                  _buildDashboardGrid(),
                  const SizedBox(height: 24),

                  // RECENT TRANSACTIONS / INVENTORY ADDITIONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Items', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                      TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: AppTheme.textLight))),
                    ],
                  ),
                  
                  // LIVE VOICE Box (if active)
                  if (_isListening || _liveText != "Using Microphone...")
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
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

                  ListenableBuilder(
                    listenable: _cartService,
                    builder: (context, child) {
                      final items = _cartService.items.take(5).toList();
                      if (items.isEmpty) return const Center(child: Text('No items yet', style: TextStyle(color: Colors.black26)));
                      
                      return Column(
                        children: items.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(item.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                                    Text('Added via Voice', style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text(
                                '${item.quantity.toStringAsFixed(0)} ${item.unit}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => _cartService.updateQuantity(item.id, 1),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.add, color: AppTheme.primaryColor, size: 20),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      );
                    },
                  ),
                   const SizedBox(height: 80), // Space for PTT
                ],
              ),
            ),
            
            // FLOATING PTT BUTTON
             Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: PushToTalkButton(
                  onPressed: _toggleListening,
                  isListening: _isListening,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(IconData icon, String label, String value, Color bgColor, bool isPrimary) {
    final fgColor = isPrimary ? AppTheme.secondaryColor : AppTheme.textDark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isPrimary) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isPrimary ? Colors.white.withOpacity(0.3) : AppTheme.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: fgColor),
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 12, color: isPrimary ? fgColor.withOpacity(0.7) : AppTheme.textLight)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fgColor)),
        ],
      ),
    );
  }
  
  Widget _buildDashboardGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildActionBtn(Icons.receipt_long, 'Billing', () => _nav(const BillingScreen())),
        _buildActionBtn(Icons.search, 'Inventory', () => _nav(const InventoryScreen())),
        _buildActionBtn(Icons.shopping_cart_outlined, 'Cart', () => _nav(const CartScreen())),
        _buildActionBtn(Icons.book_outlined, 'Khata', () => _nav(const KhataScreen())),
        _buildActionBtn(Icons.bar_chart, 'Insights', () => _nav(const InsightsScreen())),
      ],
    );
  }
  
  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return _AnimatedActionBtn(icon: icon, label: label, onTap: onTap);
  }

  void _nav(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.05); // Slight slide up
          const end = Offset.zero;
          const curve = Curves.easeOutQuart;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          var fadeAnimation = animation.drive(CurveTween(curve: curve));

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

class _AnimatedActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AnimatedActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  State<_AnimatedActionBtn> createState() => _AnimatedActionBtnState();
}

class _AnimatedActionBtnState extends State<_AnimatedActionBtn> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
                ],
              ),
              child: Icon(widget.icon, color: AppTheme.secondaryColor),
            ),
            const SizedBox(height: 8),
            Text(widget.label, style: const TextStyle(fontSize: 12, color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }
}
