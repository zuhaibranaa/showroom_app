import 'package:equatable/equatable.dart';

/// Domain entity for document history linked to a vehicle within an agency.
class DocumentHistoryEntity extends Equatable {
  final String id;
  final String vehicleId;
  final String agencyId;
  final String status;
  final String changedBy;
  final String? remarks;
  final String? registrationStatus;
  final String? registeredFrom;
  final String? numberPlate;
  final String? registrationBook;
  final List<String> checklist;
  final DateTime statusDate;
  final DateTime createdAt;

  const DocumentHistoryEntity({
    required this.id,
    required this.vehicleId,
    required this.agencyId,
    required this.status,
    required this.changedBy,
    this.remarks,
    this.registrationStatus,
    this.registeredFrom,
    this.numberPlate,
    this.registrationBook,
    this.checklist = const [],
    required this.statusDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        agencyId,
        status,
        changedBy,
        remarks,
        registrationStatus,
        registeredFrom,
        numberPlate,
        registrationBook,
        checklist,
        statusDate,
        createdAt,
      ];

  DocumentHistoryEntity copyWith({
    String? id,
    String? vehicleId,
    String? agencyId,
    String? status,
    String? changedBy,
    String? remarks,
    String? registrationStatus,
    String? registeredFrom,
    String? numberPlate,
    String? registrationBook,
    List<String>? checklist,
    DateTime? statusDate,
    DateTime? createdAt,
  }) {
    return DocumentHistoryEntity(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      agencyId: agencyId ?? this.agencyId,
      status: status ?? this.status,
      changedBy: changedBy ?? this.changedBy,
      remarks: remarks ?? this.remarks,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      registeredFrom: registeredFrom ?? this.registeredFrom,
      numberPlate: numberPlate ?? this.numberPlate,
      registrationBook: registrationBook ?? this.registrationBook,
      checklist: checklist ?? this.checklist,
      statusDate: statusDate ?? this.statusDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
