import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String? id;
  final DateTime date;
  final String description;
  final double amount;
  final String type; // Ingreso, Egreso, Transferencia
  final String? category;
  final String? channel;
  final String? channelFrom;
  final String? channelTo;

  TransactionModel({
    this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    this.category,
    this.channel,
    this.channelFrom,
    this.channelTo,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'description': description,
      'amount': amount,
      'type': type,
      'category': category,
      'channel': channel,
      'channelFrom': channelFrom,
      'channelTo': channelTo,
    };
  }

  // Crear desde Firestore
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] ?? 'Egreso',
      category: data['category'],
      channel: data['channel'],
      channelFrom: data['channelFrom'],
      channelTo: data['channelTo'],
    );
  }

  // Copiar con modificaciones
  TransactionModel copyWith({
    String? id,
    DateTime? date,
    String? description,
    double? amount,
    String? type,
    String? category,
    String? channel,
    String? channelFrom,
    String? channelTo,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      channel: channel ?? this.channel,
      channelFrom: channelFrom ?? this.channelFrom,
      channelTo: channelTo ?? this.channelTo,
    );
  }
}
