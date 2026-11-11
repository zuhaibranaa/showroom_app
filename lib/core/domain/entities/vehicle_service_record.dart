import 'package:equatable/equatable.dart';

/// Domain entity for a vehicle service record (registration / transfer) within an agency.
class VehicleServiceRecordEntity extends Equatable {
  final String id;
  final String type; // REGISTRATION / TRANSFER
  final String phone;
  final String receivedBy;
  final String agencyId;
  final String? chassisNo;
  final String? oldNumber;
  final String? newNumber;
  final String? customerName;
  final String? firstOwner;
  final String? secondOwner;
  final String? note;
  final double amount;
  final bool firstOwnerBiometricPending;
  final bool secondOwnerBiometricPending;
  final DateTime date;

  const VehicleServiceRecordEntity({
    required this.id,
    required this.type,
    required this.phone,
    required this.receivedBy,
    required this.agencyId,
    this.chassisNo,
    this.oldNumber,
    this.newNumber,
    this.customerName,
    this.firstOwner,
    this.secondOwner,
    this.note,
    required this.amount,
    this.firstOwnerBiometricPending = false,
    this.secondOwnerBiometricPending = false,
    required this.date,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        phone,
        receivedBy,
        agencyId,
        chassisNo,
        oldNumber,
        newNumber,
        customerName,
        firstOwner,
        secondOwner,
        note,
        amount,
        firstOwnerBiometricPending,
        secondOwnerBiometricPending,
        date,
      ];

  VehicleServiceRecordEntity copyWith({
    String? id,
    String? type,
    String? phone,
    String? receivedBy,
    String? agencyId,
    String? chassisNo,
    String? oldNumber,
    String? newNumber,
    String? customerName,
    String? firstOwner,
    String? secondOwner,
    String? note,
    double? amount,
    bool? firstOwnerBiometricPending,
    bool? secondOwnerBiometricPending,
    DateTime? date,
  }) {
    return VehicleServiceRecordEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      receivedBy: receivedBy ?? this.receivedBy,
      agencyId: agencyId ?? this.agencyId,
      chassisNo: chassisNo ?? this.chassisNo,
      oldNumber: oldNumber ?? this.oldNumber,
      newNumber: newNumber ?? this.newNumber,
      customerName: customerName ?? this.customerName,
      firstOwner: firstOwner ?? this.firstOwner,
      secondOwner: secondOwner ?? this.secondOwner,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      firstOwnerBiometricPending:
          firstOwnerBiometricPending ?? this.firstOwnerBiometricPending,
      secondOwnerBiometricPending:
          secondOwnerBiometricPending ?? this.secondOwnerBiometricPending,
      date: date ?? this.date,
    );
  }
}
