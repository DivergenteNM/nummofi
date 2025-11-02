import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String? id;
  final String title;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdAt;
  final DateTime? targetDate;
  final String? icon; // Emoji o nombre de icono
  final String? color; // Color hex para personalización

  GoalModel({
    this.id,
    required this.title,
    this.description,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.createdAt,
    this.targetDate,
    this.icon,
    this.color,
  });

  // Calcular porcentaje de progreso
  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    final percentage = (currentAmount / targetAmount) * 100;
    return percentage.clamp(0, 100);
  }

  // Monto restante para alcanzar la meta
  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining > 0 ? remaining : 0;
  }

  // Verificar si la meta está completada
  bool get isCompleted => currentAmount >= targetAmount;

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
      'icon': icon,
      'color': color,
    };
  }

  // Crear desde Firestore
  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetDate: (data['targetDate'] as Timestamp?)?.toDate(),
      icon: data['icon'],
      color: data['color'],
    );
  }

  // Copiar con modificaciones
  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? createdAt,
    DateTime? targetDate,
    String? icon,
    String? color,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
