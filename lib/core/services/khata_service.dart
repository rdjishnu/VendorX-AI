import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class KhataCustomer {
  final String id;
  final String name;
  final String phone;
  double balance;

  KhataCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
  });
}

class KhataService extends ChangeNotifier {
  static final KhataService _instance = KhataService._internal();
  factory KhataService() => _instance;
  KhataService._internal() {
    _seedData();
  }

  final List<KhataCustomer> _customers = [];
  final _uuid = const Uuid();

  List<KhataCustomer> get customers => List.unmodifiable(_customers);

  double get totalCreditGiven => _customers.fold(0, (sum, c) => sum + c.balance);
  int get activeCustomers => _customers.where((c) => c.balance > 0).length;

  void _seedData() {
    _customers.addAll([
      KhataCustomer(id: _uuid.v4(), name: 'Ramesh Kumar', phone: '9876543210', balance: 450.0),
      KhataCustomer(id: _uuid.v4(), name: 'Sita Ram', phone: '9123456789', balance: 1200.0),
      KhataCustomer(id: _uuid.v4(), name: 'Mohit Singh', phone: '7766554433', balance: 0.0),
    ]);
  }

  void addCustomer(String name, String phone, {double balance = 0.0}) {
    _customers.insert(0, KhataCustomer(
      id: _uuid.v4(),
      name: name,
      phone: phone,
      balance: balance,
    ));
    notifyListeners();
  }

  void updateBalance(String id, double adjustment) {
    final index = _customers.indexWhere((c) => c.id == id);
    if (index != -1) {
      _customers[index].balance = (_customers[index].balance + adjustment).clamp(0, double.infinity);
      notifyListeners();
    }
  }
}
