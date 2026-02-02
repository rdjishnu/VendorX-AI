import 'package:flutter/foundation.dart';

class ShopService extends ChangeNotifier {
  static final ShopService _instance = ShopService._internal();
  factory ShopService() => _instance;
  ShopService._internal();

  String _shopName = 'VendorX AI';
  String _ownerName = 'Jishnu Priyan';
  String _gstNumber = '27AAAAA0000A1Z5';
  String _address = 'Sector 12, Bengaluru, Karnataka';
  String _phone = '+91 9876543210';

  String get shopName => _shopName;
  String get ownerName => _ownerName;
  String get gstNumber => _gstNumber;
  String get address => _address;
  String get phone => _phone;

  void updateProfile({
    String? shopName,
    String? ownerName,
    String? gstNumber,
    String? address,
    String? phone,
  }) {
    if (shopName != null) _shopName = shopName;
    if (ownerName != null) _ownerName = ownerName;
    if (gstNumber != null) _gstNumber = gstNumber;
    if (address != null) _address = address;
    if (phone != null) _phone = phone;
    notifyListeners();
  }
}
