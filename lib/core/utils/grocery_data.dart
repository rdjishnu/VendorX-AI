class GroceryData {
  static const Map<String, double> prices = {
    'rice': 60.0, // per unit/kg
    'sugar': 45.0,
    'milk': 30.0, // per packet
    'dal': 120.0,
    'toor dal': 140.0,
    'moong dal': 110.0,
    'oil': 130.0, // per liter
    'sunflower oil': 140.0,
    'groundnut oil': 180.0,
    'salt': 20.0,
    'tea': 120.0, // 250g approx, standardized to unit
    'coffee': 250.0,
    'wheat': 40.0,
    'atta': 45.0,
    'maida': 35.0,
    'sooji': 40.0,
    'besan': 90.0,
    'poha': 50.0,
    'maggie': 12.0, // per pack
    'biscuit': 10.0,
    'soap': 35.0,
    'shampoo': 3.0, // sachet
    'toothpaste': 80.0,
    'detergent': 110.0,
    'chips': 20.0,
    'chocolate': 10.0,
    'bread': 40.0,
    'butter': 55.0,
    'cheese': 120.0,
    'paneer': 90.0, // 200g
    'curd': 30.0,
    'potato': 30.0,
    'onion': 40.0,
    'tomato': 50.0,
    'egg': 7.0,
  };

  static double getPrice(String itemName) {
    // Basic fuzzy match
    final key = itemName.toLowerCase();
    
    // Exact match
    if (prices.containsKey(key)) return prices[key]!;
    
    // Partial match (e.g. "basmati rice" -> match "rice")
    for (var k in prices.keys) {
      if (key.contains(k)) return prices[k]!;
    }
    
    return 0.0; // Unknown
  }
}
