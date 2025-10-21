import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlySummaryModel {
  final String? id;
  final int month;
  final int year;
  final Map<String, double> initialBalances;
  final Map<String, double> finalBalances;
  final double totalIncome;
  final double totalExpenses;
  final Map<String, dynamic> budgetComparison;

  MonthlySummaryModel({
    this.id,
    required this.month,
    required this.year,
    required this.initialBalances,
    required this.finalBalances,
    required this.totalIncome,
    required this.totalExpenses,
    required this.budgetComparison,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'year': year,
      'initialBalances': initialBalances,
      'finalBalances': finalBalances,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'budgetComparison': budgetComparison,
    };
  }

  // Crear desde Firestore
  factory MonthlySummaryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MonthlySummaryModel(
      id: doc.id,
      month: data['month'] ?? DateTime.now().month,
      year: data['year'] ?? DateTime.now().year,
      initialBalances: Map<String, double>.from(data['initialBalances'] ?? {}),
      finalBalances: Map<String, double>.from(data['finalBalances'] ?? {}),
      totalIncome: (data['totalIncome'] ?? 0).toDouble(),
      totalExpenses: (data['totalExpenses'] ?? 0).toDouble(),
      budgetComparison: data['budgetComparison'] ?? {},
    );
  }
}
