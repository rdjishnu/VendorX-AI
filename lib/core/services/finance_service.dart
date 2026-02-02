import 'package:flutter/foundation.dart';

enum PaymentType { upi, cash, credit }

class Transaction {
  final String id;
  final double amount;
  final PaymentType type;
  final DateTime date;
  final String description;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.description,
  });
}

class FinanceService extends ChangeNotifier {
  static final FinanceService _instance = FinanceService._internal();
  factory FinanceService() => _instance;
  FinanceService._internal();

  double _totalBalance = 40500.0;
  double _totalIncome = 12000.0;
  double _totalExpense = 2000.0;
  
  double _upiSales = 4500.0;
  double _cashSales = 7500.0;

  final List<Transaction> _transactions = [
    Transaction(id: '1', amount: 450, type: PaymentType.upi, date: DateTime.now().subtract(const Duration(hours: 2)), description: 'Grocery Sale'),
    Transaction(id: '2', amount: 120, type: PaymentType.cash, date: DateTime.now().subtract(const Duration(hours: 5)), description: 'Soap/Detergent'),
    Transaction(id: '3', amount: 1500, type: PaymentType.upi, date: DateTime.now().subtract(const Duration(days: 1)), description: 'Monthly Stock'),
  ];

  double get totalBalance => _totalBalance;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get upiSales => _upiSales;
  double get cashSales => _cashSales;
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  void recordSale(double amount, PaymentType type) {
    if (type == PaymentType.upi) {
      _upiSales += amount;
      _totalIncome += amount;
      _totalBalance += amount;
    } else if (type == PaymentType.cash) {
      _cashSales += amount;
      _totalIncome += amount;
      _totalBalance += amount;
    }
    
    _transactions.insert(0, Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: type,
      date: DateTime.now(),
      description: 'Sale recorded',
    ));
    
    notifyListeners();
  }

  void recordExpense(double amount) {
    _totalExpense += amount;
    _totalBalance -= amount;
    notifyListeners();
  }
}
