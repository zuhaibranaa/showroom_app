import 'package:equatable/equatable.dart';

/// Domain entity for a pending payment linked to a sale and vehicle within an agency.
class PendingPaymentEntity extends Equatable {
  final String id;
  final String agencyId;
  final String? saleId;
  final String? vehicleId;
  final String? buyerName;
  final double amount;
  final DateTime? dueDate;
  final String status; // pending/paid
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PendingPaymentEntity({
    required this.id,
    required this.agencyId,
    this.saleId,
    this.vehicleId,
    this.buyerName,
    required this.amount,
    this.dueDate,
    this.status = 'pending',
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        agencyId,
        saleId,
        vehicleId,
        buyerName,
        amount,
        dueDate,
        status,
        notes,
        createdAt,
        updatedAt,
      ];

  PendingPaymentEntity copyWith({
    String? id,
    String? agencyId,
    String? saleId,
    String? vehicleId,
    String? buyerName,
    double? amount,
    DateTime? dueDate,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PendingPaymentEntity(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      saleId: saleId ?? this.saleId,
      vehicleId: vehicleId ?? this.vehicleId,
      buyerName: buyerName ?? this.buyerName,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
