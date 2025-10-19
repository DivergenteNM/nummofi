import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String? id;
  final int month;
  final int year;
  final Map<String, double> incomes;
  final Map<String, double> expenses;

  BudgetModel({
    this.id,
    required this.month,
    required this.year,
    required this.incomes,
    required this.expenses,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'year': year,
      'incomes': incomes,
      'expenses': expenses,
    };
  }

  // Crear desde Firestore
  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      month: data['month'] ?? DateTime.now().month,
      year: data['year'] ?? DateTime.now().year,
      incomes: Map<String, double>.from(data['incomes'] ?? {}),
      expenses: Map<String, double>.from(data['expenses'] ?? {}),
    );
  }

  double get totalIncome => incomes.values.fold(0, (sum, val) => sum + val);
  double get totalExpense => expenses.values.fold(0, (sum, val) => sum + val);
}
