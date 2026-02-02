import '../../features/home/domain/models/cart_item.dart';
import 'package:uuid/uuid.dart';
import 'grocery_data.dart';

class CommandParser {
  static final _uuid = Uuid();


  static const Map<String, double> _wordToNum = {
    'one': 1, 'a': 1, 'an': 1,
    'two': 2, 'three': 3, 'four': 4, 'five': 5,
    'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
    'twenty': 20, 'thirty': 30, 'forty': 40, 'fifty': 50,
  };

  /// Parses a command string into a list of CartItems.
  static List<CartItem> parse(String command) {
    var clean = command.toLowerCase().trim();
    clean = clean.replaceAll(RegExp(r'[^\w\s]+$'), '');
    
    // Normalize splitting keywords
    clean = clean.replaceAll(' plus ', ' add ');
    clean = clean.replaceAll(' and ', ' add ');
    
    // If it doesn't contain 'add', assume it's a single item command
    if (!clean.contains('add ')) {
      final item = _parseSingleSegment(clean);
      return item != null ? [item] : [];
    }

    final segments = clean.split('add ');
    final List<CartItem> items = [];

    for (var segment in segments) {
      if (segment.trim().isEmpty) continue;
      final item = _parseSingleSegment(segment.trim());
      if (item != null) items.add(item);
    }
    
    return items;
  }

  static CartItem? _parseSingleSegment(String rawSegment) {
    String rest = rawSegment;

    // Convert number words to digits (one -> 1)
    for (var entry in _wordToNum.entries) {
      if (rest.startsWith(entry.key)) {
        rest = rest.replaceFirst(entry.key, entry.value.toInt().toString());
        break;
      }
    }

    // Extract Price first (e.g. "for 500 rupees", "at 50 rs")
    double price = 0.0;
    final priceMatch = RegExp(r'(?:for|at|price)\s+(\d+(?:\.\d+)?)\s*(?:rupees|rs|r|bucks)?').firstMatch(rest);
    if (priceMatch != null) {
      price = double.parse(priceMatch.group(1)!);
      rest = rest.replaceAll(priceMatch.group(0)!, '').trim();
    } else {
      final strictPriceMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:rupees|rs|r|bucks)').firstMatch(rest);
      if (strictPriceMatch != null) {
        price = double.parse(strictPriceMatch.group(1)!);
        rest = rest.replaceAll(strictPriceMatch.group(0)!, '').trim();
      }
    }

    // Pattern 1: {qty}{unit} {name} (e.g., "5kg Rice" or "5 kg Rice")
    final match1 = RegExp(r'^(\d+(?:\.\d+)?)\s*([a-z]+)\s+(.+)$').firstMatch(rest);
    if (match1 != null) {
      final name = match1.group(3)!;
      final qty = double.parse(match1.group(1)!);
      final unit = match1.group(2)!;
      return _finalizeParsedItem(name, qty, unit, price);
    }

    // Pattern 2: {name} {qty}{unit} (e.g., "Rice 5kg" or "Rice 5 kg")
    final match2 = RegExp(r'^(.+?)\s+(\d+(?:\.\d+)?)\s*([a-z]+)$').firstMatch(rest);
    if (match2 != null) {
      final name = match2.group(1)!;
      final qty = double.parse(match2.group(2)!);
      final unit = match2.group(3)!;
      return _finalizeParsedItem(name, qty, unit, price);
    }

    // Pattern 3: {qty} {name} (e.g., "5 Soaps")
    final match3 = RegExp(r'^(\d+(?:\.\d+)?)\s+(.+)$').firstMatch(rest);
    if (match3 != null) {
      final name = match3.group(2)!;
      final qty = double.parse(match3.group(1)!);
      return _finalizeParsedItem(name, qty, 'units', price);
    }

    // Pattern 4: {name} {qty} (e.g., "Soaps 5")
    final match4 = RegExp(r'^(.+?)\s+(\d+(?:\.\d+)?)$').firstMatch(rest);
    if (match4 != null) {
      final name = match4.group(1)!;
      final qty = double.parse(match4.group(2)!);
      return _finalizeParsedItem(name, qty, 'units', price);
    }

    return null;
  }

  static CartItem _finalizeParsedItem(String name, double qty, String unit, double price) {
    if (price == 0.0) {
      double unitPrice = GroceryData.getPrice(name);
      if (unitPrice > 0) price = unitPrice * qty;
    }
    return _createItem(qty: qty, unit: unit, name: name, price: price);
  }

  static CartItem _createItem({
    required double qty,
    required String unit,
    required String name,
    required double price,
  }) {
    return CartItem(
      id: _uuid.v4(),
      name: _capitalize(name),
      quantity: qty,
      unit: unit,
      timestamp: DateTime.now(),
      price: price,
    );
  }



  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
