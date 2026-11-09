import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vehicle_model.g.dart';

DateTime _vehicleDateFromJson(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.parse(value as String);
}

DateTime? _optionalVehicleDateFromJson(dynamic value) =>
    value == null ? null : _vehicleDateFromJson(value);

dynamic _vehicleDateToJson(DateTime value) => value.toIso8601String();
dynamic _optionalVehicleDateToJson(DateTime? value) => value?.toIso8601String();

@JsonSerializable()
class VehicleModel {
  final String id;
  final String agencyId;
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final String vin;
  final String? description;
  @JsonKey(fromJson: _vehicleDateFromJson, toJson: _vehicleDateToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _vehicleDateFromJson, toJson: _vehicleDateToJson)
  final DateTime updatedAt;

  // Purchase and bike fields retained for backwards compatibility.
  final String? receiptNo;
  final double? eChallanFine;
  @JsonKey(
    fromJson: _optionalVehicleDateFromJson,
    toJson: _optionalVehicleDateToJson,
  )
  final DateTime? biometricAvailableDate;
  final String? biometricPhone;
  final String? biometricStatus;
  final String? company;
  final String? engineCC;
  final String? documentStatus;
  final String? source;
  final String? engineNo;
  final String? chassisNo;
  final String? plateNo;
  final String? sellerName;
  final String? sellerFatherName;
  final String? sellerCNIC;
  final String? sellerPhone;
  final String? sellerAddress;
  final double? priceAmount;
  final bool isZeroMeter;
  final String? horsePower;
  final String? registrationNo;
  final String? registrationCity;
  final String? registrationStatus;
  final String? registeredFrom;
  final String? registeredInNameOf;
  final double? challanAmount;
  final String? challanStatus;
  final double? retailPrice;
  final String? firstOwner;
  final String? secondOwner;
  final String? notes;
  final String? remarks;

  // Bobby Motors purchase, seller, document and stock fields.
  @JsonKey(
    fromJson: _optionalVehicleDateFromJson,
    toJson: _optionalVehicleDateToJson,
  )
  final DateTime? purchaseDate;
  final double? amountPaidToSeller;
  final String? paidBy;
  final String? dealerId;
  final String? sellerWitnessName;
  final String? sellerWitnessMobile;
  final List<String> documentsReceived;
  final String? registrationBook;
  final String? paymentMode;
  final String? paymentBank;
  final String stockStatus;
  final List<String>? imageUrls;

  VehicleModel({
    required this.id,
    this.agencyId = '',
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.vin,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.receiptNo,
    this.eChallanFine,
    this.biometricAvailableDate,
    this.biometricPhone,
    this.biometricStatus,
    this.company,
    this.engineCC,
    this.documentStatus,
    this.source,
    this.engineNo,
    this.chassisNo,
    this.plateNo,
    this.sellerName,
    this.sellerFatherName,
    this.sellerCNIC,
    this.sellerPhone,
    this.sellerAddress,
    this.priceAmount,
    this.isZeroMeter = false,
    this.horsePower,
    this.registrationNo,
    this.registrationCity,
    this.registrationStatus,
    this.registeredFrom,
    this.registeredInNameOf,
    this.challanAmount,
    this.challanStatus,
    this.retailPrice,
    this.firstOwner,
    this.secondOwner,
    this.notes,
    this.remarks,
    this.purchaseDate,
    this.amountPaidToSeller,
    this.paidBy,
    this.dealerId,
    this.sellerWitnessName,
    this.sellerWitnessMobile,
    this.documentsReceived = const [],
    this.registrationBook,
    this.paymentMode,
    this.paymentBank,
    this.stockStatus = 'IN_STOCK',
    this.imageUrls,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);

  VehicleModel copyWith({
    String? id,
    String? agencyId,
    String? make,
    String? model,
    int? year,
    String? color,
    String? licensePlate,
    String? vin,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? receiptNo,
    double? eChallanFine,
    DateTime? biometricAvailableDate,
    String? biometricPhone,
    String? biometricStatus,
    String? company,
    String? engineCC,
    String? documentStatus,
    String? source,
    String? engineNo,
    String? chassisNo,
    String? plateNo,
    String? sellerName,
    String? sellerFatherName,
    String? sellerCNIC,
    String? sellerPhone,
    String? sellerAddress,
    double? priceAmount,
    bool? isZeroMeter,
    String? horsePower,
    String? registrationNo,
    String? registrationCity,
    String? registrationStatus,
    String? registeredFrom,
    String? registeredInNameOf,
    double? challanAmount,
    String? challanStatus,
    double? retailPrice,
    String? firstOwner,
    String? secondOwner,
    String? notes,
    String? remarks,
    DateTime? purchaseDate,
    double? amountPaidToSeller,
    String? paidBy,
    String? dealerId,
    String? sellerWitnessName,
    String? sellerWitnessMobile,
    List<String>? documentsReceived,
    String? registrationBook,
    String? paymentMode,
    String? paymentBank,
    String? stockStatus,
    List<String>? imageUrls,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      vin: vin ?? this.vin,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      receiptNo: receiptNo ?? this.receiptNo,
      eChallanFine: eChallanFine ?? this.eChallanFine,
      biometricAvailableDate:
          biometricAvailableDate ?? this.biometricAvailableDate,
      biometricPhone: biometricPhone ?? this.biometricPhone,
      biometricStatus: biometricStatus ?? this.biometricStatus,
      company: company ?? this.company,
      engineCC: engineCC ?? this.engineCC,
      documentStatus: documentStatus ?? this.documentStatus,
      source: source ?? this.source,
      engineNo: engineNo ?? this.engineNo,
      chassisNo: chassisNo ?? this.chassisNo,
      plateNo: plateNo ?? this.plateNo,
      sellerName: sellerName ?? this.sellerName,
      sellerFatherName: sellerFatherName ?? this.sellerFatherName,
      sellerCNIC: sellerCNIC ?? this.sellerCNIC,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      sellerAddress: sellerAddress ?? this.sellerAddress,
      priceAmount: priceAmount ?? this.priceAmount,
      isZeroMeter: isZeroMeter ?? this.isZeroMeter,
      horsePower: horsePower ?? this.horsePower,
      registrationNo: registrationNo ?? this.registrationNo,
      registrationCity: registrationCity ?? this.registrationCity,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      registeredFrom: registeredFrom ?? this.registeredFrom,
      registeredInNameOf: registeredInNameOf ?? this.registeredInNameOf,
      challanAmount: challanAmount ?? this.challanAmount,
      challanStatus: challanStatus ?? this.challanStatus,
      retailPrice: retailPrice ?? this.retailPrice,
      firstOwner: firstOwner ?? this.firstOwner,
      secondOwner: secondOwner ?? this.secondOwner,
      notes: notes ?? this.notes,
      remarks: remarks ?? this.remarks,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      amountPaidToSeller: amountPaidToSeller ?? this.amountPaidToSeller,
      paidBy: paidBy ?? this.paidBy,
      dealerId: dealerId ?? this.dealerId,
      sellerWitnessName: sellerWitnessName ?? this.sellerWitnessName,
      sellerWitnessMobile: sellerWitnessMobile ?? this.sellerWitnessMobile,
      documentsReceived: documentsReceived ?? this.documentsReceived,
      registrationBook: registrationBook ?? this.registrationBook,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentBank: paymentBank ?? this.paymentBank,
      stockStatus: stockStatus ?? this.stockStatus,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}
