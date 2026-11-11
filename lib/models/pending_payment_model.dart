import 'package:json_annotation/json_annotation.dart';
part 'pending_payment_model.g.dart';

@JsonSerializable()
class PendingPaymentModel {
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

  PendingPaymentModel({
    required this.id,
    this.agencyId = '',
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

  factory PendingPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PendingPaymentModelFromJson(json);
  Map<String, dynamic> toJson() => _$PendingPaymentModelToJson(this);
  PendingPaymentModel copyWith({String? id, String? agencyId, String? saleId, String? vehicleId, String? buyerName, double? amount, DateTime? dueDate, String? status, String? notes, DateTime? createdAt, DateTime? updatedAt}) {
    return PendingPaymentModel(
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
