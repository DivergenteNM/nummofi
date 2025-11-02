import 'package:flutter/foundation.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/monthly_summary_model.dart';
import '../../data/models/channel_balance_model.dart';
import '../../data/models/goal_model.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';

class FinanceProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  FinanceProvider(this._firestoreService) {
    _initializeStreams();
  }

  // Estado
  List<TransactionModel> _transactions = [];
  List<BudgetModel> _budgets = [];
  List<MonthlySummaryModel> _monthlySummaries = [];
  List<ChannelBalanceModel> _channelBalances = [];
  List<GoalModel> _goals = [];
  
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;
  bool _isLoading = false;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  List<BudgetModel> get budgets => _budgets;
  List<MonthlySummaryModel> get monthlySummaries => _monthlySummaries;
  List<ChannelBalanceModel> get channelBalances => _channelBalances;
  List<GoalModel> get goals => _goals;
  int get currentMonth => _currentMonth;
  int get currentYear => _currentYear;
  bool get isLoading => _isLoading;

  // Filtrar transacciones del mes actual
  List<TransactionModel> get currentMonthTransactions {
    return _transactions.where((t) {
      return t.date.month == _currentMonth && t.date.year == _currentYear;
    }).toList();
  }

  // Presupuesto del mes actual
  BudgetModel? get currentMonthBudget {
    try {
      return _budgets.firstWhere(
        (b) => b.month == _currentMonth && b.year == _currentYear,
      );
    } catch (e) {
      return null;
    }
  }

  // Total de ingresos del mes
  double get totalIncome {
    return currentMonthTransactions
        .where((t) => t.type == 'Ingreso')
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Total de egresos del mes
  double get totalExpenses {
    return currentMonthTransactions
        .where((t) => t.type == 'Egreso')
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Egresos por categoría
  Map<String, double> get expensesByCategory {
    Map<String, double> result = {};
    for (var transaction in currentMonthTransactions) {
      if (transaction.type == 'Egreso' && transaction.category != null) {
        result[transaction.category!] = 
            (result[transaction.category!] ?? 0) + transaction.amount;
      }
    }
    return result;
  }

  // Verificar si se puede cerrar el mes
  bool get canCloseMonth {
    return !_monthlySummaries.any(
      (s) => s.month == _currentMonth && s.year == _currentYear,
    );
  }

  // Inicializar streams
  void _initializeStreams() {
    _firestoreService.getTransactionsStream().listen((transactions) {
      _transactions = transactions;
      _calculateBalances();
      notifyListeners();
    });

    _firestoreService.getBudgetsStream().listen((budgets) {
      _budgets = budgets;
      notifyListeners();
    });

    _firestoreService.getMonthlySummariesStream().listen((summaries) {
      _monthlySummaries = summaries;
      _calculateBalances();
      notifyListeners();
    });

    _firestoreService.getGoalsStream().listen((goals) {
      _goals = goals;
      notifyListeners();
    });
  }

  // Calcular balances de canales
  void _calculateBalances() {
    if (_transactions.isEmpty) {
      _channelBalances = AppConstants.canales
          .map((channel) => ChannelBalanceModel(name: channel, balance: 0))
          .toList();
      return;
    }

    // Obtener saldos iniciales del mes anterior
    MonthlySummaryModel? previousMonthSummary;
    try {
      DateTime previousMonth = DateTime(_currentYear, _currentMonth - 1, 1);
      previousMonthSummary = _monthlySummaries.firstWhere(
        (s) => s.month == previousMonth.month && s.year == previousMonth.year,
      );
    } catch (e) {
      previousMonthSummary = null;
    }

    Map<String, double> balances = {
      "Nequi": previousMonthSummary?.finalBalances["Nequi"] ?? 0,
      "NuBank": previousMonthSummary?.finalBalances["NuBank"] ?? 0,
      "Efectivo": previousMonthSummary?.finalBalances["Efectivo"] ?? 0,
    };

    // Calcular balances con las transacciones del mes actual
    for (var transaction in currentMonthTransactions) {
      if (transaction.type == "Ingreso" && transaction.channel != null) {
        balances[transaction.channel!] = 
            (balances[transaction.channel!] ?? 0) + transaction.amount;
      } else if (transaction.type == "Egreso" && transaction.channel != null) {
        balances[transaction.channel!] = 
            (balances[transaction.channel!] ?? 0) - transaction.amount;
      } else if (transaction.type == "Transferencia") {
        if (transaction.channelFrom != null) {
          balances[transaction.channelFrom!] = 
              (balances[transaction.channelFrom!] ?? 0) - transaction.amount;
        }
        if (transaction.channelTo != null) {
          balances[transaction.channelTo!] = 
              (balances[transaction.channelTo!] ?? 0) + transaction.amount;
        }
      }
    }

    _channelBalances = AppConstants.canales
        .map((channel) => ChannelBalanceModel(
              name: channel,
              balance: balances[channel] ?? 0,
            ))
        .toList();
  }

  // Cambiar mes
  void setMonth(int month, int year) {
    _currentMonth = month;
    _currentYear = year;
    _calculateBalances();
    notifyListeners();
  }

  // Agregar transacción
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.addTransaction(transaction);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Actualizar transacción
  Future<void> updateTransaction(String id, TransactionModel transaction) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.updateTransaction(id, transaction);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Eliminar transacción
  Future<void> deleteTransaction(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.deleteTransaction(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Guardar presupuesto
  Future<void> saveBudget(BudgetModel budget) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.saveBudget(budget);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Cerrar mes
  Future<void> closeMonth() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Obtener saldos iniciales del mes anterior
      MonthlySummaryModel? previousMonthSummary;
      try {
        DateTime previousMonth = DateTime(_currentYear, _currentMonth - 1, 1);
        previousMonthSummary = _monthlySummaries.firstWhere(
          (s) => s.month == previousMonth.month && s.year == previousMonth.year,
        );
      } catch (e) {
        previousMonthSummary = null;
      }

      Map<String, double> initialBalances = {
        "Nequi": previousMonthSummary?.finalBalances["Nequi"] ?? 0,
        "NuBank": previousMonthSummary?.finalBalances["NuBank"] ?? 0,
        "Efectivo": previousMonthSummary?.finalBalances["Efectivo"] ?? 0,
      };

      Map<String, double> finalBalances = {};
      for (var channel in _channelBalances) {
        finalBalances[channel.name] = channel.balance;
      }

      BudgetModel? budget = currentMonthBudget;
      
      MonthlySummaryModel summary = MonthlySummaryModel(
        month: _currentMonth,
        year: _currentYear,
        initialBalances: initialBalances,
        finalBalances: finalBalances,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        budgetComparison: {
          'income': {
            'planned': budget?.totalIncome ?? 0,
            'actual': totalIncome,
          },
          'expense': {
            'planned': budget?.totalExpense ?? 0,
            'actual': totalExpenses,
          },
        },
      );

      await _firestoreService.closeMonth(summary);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ==================== METAS ====================

  // Agregar meta
  Future<void> addGoal(GoalModel goal) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.addGoal(goal);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Actualizar meta
  Future<void> updateGoal(String id, GoalModel goal) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.updateGoal(id, goal);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Eliminar meta
  Future<void> deleteGoal(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.deleteGoal(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Actualizar progreso de meta
  Future<void> updateGoalProgress(String id, double newAmount) async {
    try {
      await _firestoreService.updateGoalProgress(id, newAmount);
    } catch (e) {
      rethrow;
    }
  }
}
