import 'package:equatable/equatable.dart';

/// Domain entity for an expense.
class ExpenseEntity extends Equatable {
  final String id;
  final String agencyId;
  final String? vehicleId;
  final String kind; // bike, showroom
  final String category;
  final double amount;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseEntity({
    required this.id,
    required this.agencyId,
    this.vehicleId,
    required this.kind,
    required this.category,
    required this.amount,
    this.notes,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        agencyId,
        vehicleId,
        kind,
        category,
        amount,
        notes,
        date,
        createdAt,
        updatedAt,
      ];

  ExpenseEntity copyWith({
    String? id,
    String? agencyId,
    String? vehicleId,
    String? kind,
    String? category,
    double? amount,
    String? notes,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      vehicleId: vehicleId ?? this.vehicleId,
      kind: kind ?? this.kind,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
