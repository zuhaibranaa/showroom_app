import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class ExpenseModel {
  final String id;
  final String agencyId;
  final String? vehicleId;
  final String kind;
  final String category;
  final double amount;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    required this.id,
    this.agencyId = '',
    this.vehicleId,
    this.kind = 'showroom',
    required this.category,
    required this.amount,
    this.notes,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);

  ExpenseModel copyWith({
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
    return ExpenseModel(
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
