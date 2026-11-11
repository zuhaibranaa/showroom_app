import '../core/domain/entities/agency.dart';
import '../core/domain/entities/dealer.dart';
import '../core/domain/entities/dealer_permissions.dart';
import '../core/domain/entities/document_history.dart';
import '../core/domain/entities/expense.dart';
import '../core/domain/entities/pending_payment.dart';
import '../core/domain/entities/retail_price.dart';
import '../core/domain/entities/sale.dart';
import '../core/domain/entities/user.dart';
import '../core/domain/entities/vehicle.dart';
import '../core/domain/entities/vehicle_service_record.dart';
import '../models/agency_model.dart';
import '../models/dealer_model.dart';
import '../models/dealer_permissions.dart';
import '../models/expense_model.dart';
import '../models/operations_models.dart';
import '../models/pending_payment_model.dart';
import '../models/sale_model.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';

/// Converts a [VehicleEntity] to a [VehicleModel].
VehicleModel vehicleEntityToModel(VehicleEntity e) {
  return VehicleModel(
    id: e.id,
    agencyId: e.agencyId,
    make: e.make,
    model: e.model,
    year: e.year,
    color: e.color,
    licensePlate: e.licensePlate,
    vin: e.vin,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
    documentStatus: e.documentStatus,
    priceAmount: e.priceAmount,
    isZeroMeter: e.isZeroMeter,
    engineNo: e.engineNo,
    plateNo: e.plateNo,
    chassisNo: e.chassisNo,
    purchaseDate: e.purchaseDate,
  );
}

/// Converts a [VehicleModel] to a [VehicleEntity].
VehicleEntity vehicleModelToEntity(VehicleModel m) {
  return VehicleEntity(
    id: m.id,
    agencyId: m.agencyId,
    make: m.make,
    model: m.model,
    year: m.year,
    color: m.color,
    licensePlate: m.licensePlate,
    chassisNo: m.chassisNo ?? '',
    engineNo: m.engineNo ?? '',
    plateNo: m.plateNo ?? '',
    vin: m.vin ?? '',
    priceAmount: m.priceAmount ?? 0.0,
    isZeroMeter: m.isZeroMeter,
    documentStatus: m.documentStatus ?? '',
    purchaseDate: m.purchaseDate ?? DateTime.now(),
    createdAt: m.createdAt,
    updatedAt: m.updatedAt,
  );
}

/// Converts a [SaleEntity] to a [SaleModel].
SaleModel saleEntityToModel(SaleEntity e) {
  return SaleModel(
    id: e.id,
    agencyId: e.agencyId,
    vehicleId: e.vehicleId,
    dealerId: e.dealerId,
    buyerName: e.buyerName,
    buyerEmail: '',
    buyerPhone: e.buyerPhone,
    purchaserCNIC: e.purchaserCNIC,
    purchasePrice: e.purchasePrice,
    salePrice: e.salePrice,
    imageUrls: const [],
    notes: null,
    saleDate: e.saleDate,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
    receiptNo: e.receiptNo,
    referenceNo: e.referenceNo,
    purchaserFatherName: null,
    purchaserAddress: null,
    documentStatus: e.documentStatus,
    pendingAmount: e.balance,
    pendingDate: null,
    paymentMode: null,
    bank: null,
    amountPaid: e.received,
    amountReceived: e.received,
    balancePending: e.balance,
  );
}

/// Converts a [SaleModel] to a [SaleEntity].
SaleEntity saleModelToEntity(SaleModel m) {
  return SaleEntity(
    id: m.id,
    vehicleId: m.vehicleId,
    buyerName: m.buyerName,
    purchaserCNIC: m.purchaserCNIC ?? '',
    buyerPhone: m.buyerPhone,
    salePrice: m.salePrice,
    purchasePrice: m.purchasePrice,
    profit: m.profit ?? 0.0,
    received: m.amountReceived ?? 0.0,
    hasBalance: (m.balancePending ?? 0.0) > 0,
    dealerId: m.dealerId,
    receiptNo: m.receiptNo,
    referenceNo: m.referenceNo,
    numberPlate: null,
    documentStatus: m.documentStatus,
    saleDate: m.saleDate,
    agencyId: m.agencyId,
    createdAt: m.createdAt,
    updatedAt: m.updatedAt,
  );
}

/// Converts a [DealerEntity] to a [DealerModel].
DealerModel dealerEntityToModel(DealerEntity e) {
  return DealerModel(
    id: e.id,
    agencyId: e.agencyId,
    userId: e.userId,
    name: e.name,
    email: e.email,
    phone: e.phone,
    address: e.address,
    city: e.city,
    licenseNumber: e.licenseNumber,
    commissionPercent: e.commissionPercent,
    permissions: DealerPermissions(
      vehicles: ModulePermission(
        create: e.permissions.vehicles.create,
        edit: e.permissions.vehicles.edit,
        view: e.permissions.vehicles.view,
      ),
      sales: ModulePermission(
        create: e.permissions.sales.create,
        edit: e.permissions.sales.edit,
        view: e.permissions.sales.view,
      ),
      dealers: ModulePermission(
        create: e.permissions.dealers.create,
        edit: e.permissions.dealers.edit,
        view: e.permissions.dealers.view,
      ),
    ),
    totalCommission: e.totalCommission,
    totalSales: e.totalSales,
    isActive: e.isActive,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );
}

/// Converts a [DealerModel] to a [DealerEntity].
DealerEntity dealerModelToEntity(DealerModel m) {
  return DealerEntity(
    id: m.id,
    agencyId: m.agencyId,
    userId: m.userId,
    name: m.name,
    email: m.email,
    phone: m.phone,
    address: m.address,
    city: m.city,
    licenseNumber: m.licenseNumber,
    commissionPercent: m.commissionPercent,
    permissions: DealerPermissionsEntity(
      vehicles: ModulePermissionEntity(
        create: m.permissions.vehicles.create,
        edit: m.permissions.vehicles.edit,
        view: m.permissions.vehicles.view,
      ),
      sales: ModulePermissionEntity(
        create: m.permissions.sales.create,
        edit: m.permissions.sales.edit,
        view: m.permissions.sales.view,
      ),
      dealers: ModulePermissionEntity(
        create: m.permissions.dealers.create,
        edit: m.permissions.dealers.edit,
        view: m.permissions.dealers.view,
      ),
    ),
    totalCommission: m.totalCommission,
    totalSales: m.totalSales,
    isActive: m.isActive,
    createdAt: m.createdAt,
    updatedAt: m.updatedAt,
  );
}

/// Converts a [UserEntity] to a [UserModel].
UserModel userEntityToModel(UserEntity e) {
  return UserModel(
    id: e.id,
    email: e.email,
    username: e.username,
    fullName: e.fullName,
    profileImageUrl: e.profileImageUrl,
    role: e.role,
    agencyIds: e.agencyIds,
    agencyId: e.agencyId,
    isActive: e.isActive,
    mustChangePassword: e.mustChangePassword,
    isAgencyOwner: e.isAgencyOwner,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );
}

/// Converts a [UserModel] to a [UserEntity].
UserEntity userModelToEntity(UserModel m) {
  return UserEntity(
    id: m.id,
    email: m.email,
    username: m.username,
    fullName: m.fullName,
    profileImageUrl: m.profileImageUrl,
    role: m.role,
    agencyIds: m.agencyIds,
    agencyId: m.agencyId,
    isActive: m.isActive,
    mustChangePassword: m.mustChangePassword,
    isAgencyOwner: m.isAgencyOwner,
    createdAt: m.createdAt,
    updatedAt: m.updatedAt,
  );
}

/// Converts an [AgencyEntity] to an [AgencyModel].
AgencyModel agencyEntityToModel(AgencyEntity e) {
  return AgencyModel(
    id: e.id,
    name: e.name,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );
}

/// Converts an [AgencyModel] to an [AgencyEntity].
AgencyEntity agencyModelToEntity(AgencyModel m) {
  return AgencyEntity(
    id: m.id,
    name: m.name,
    createdAt: m.createdAt,
    updatedAt: m.updatedAt,
  );
}

/// Converts an [ExpenseEntity] to an [ExpenseModel].
ExpenseModel expenseEntityToModel(ExpenseEntity e) {
  return ExpenseModel(
    id: e.id,
    agencyId: e.agencyId,
    vehicleId: e.vehicleId,
    kind: e.kind,
    category: e.category,
    amount: e.amount,
    notes: e.notes,
    date: e.date,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );
}

/// Converts an [ExpenseModel] to an [ExpenseEntity].
ExpenseEntity expenseModelToEntity(ExpenseModel m) {
  return ExpenseEntity(
    id: m.id,
    agencyId: m.agencyId,
    vehicleId: m.vehicleId,
    kind: m.kind,
    category: m.category,
    amount: m.amount,
    notes: m.notes,
    date: m.date,
    createdAt: m.createdAt,
    updatedAt: m.updatedAt,
  );
}

/// Converts a [PendingPaymentEntity] to a [PendingPaymentModel].
PendingPaymentModel pendingPaymentEntityToModel(PendingPaymentEntity e) {
  return PendingPaymentModel(
    id: e.id,
    agencyId: e.agencyId,
    saleId: e.saleId,
    vehicleId: e.vehicleId,
    buyerName: e.buyerName,
    amount: e.amount,
    dueDate: e.dueDate,
    status: e.status,
    notes: e.notes,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );
}

/// Converts a [PendingPaymentModel] to a [PendingPaymentEntity].
PendingPaymentEntity pendingPaymentModelToEntity(PendingPaymentModel m) {
  return PendingPaymentEntity(
    id: m.id,
    agencyId: m.agencyId,
    saleId: m.saleId,
    vehicleId: m.vehicleId,
    buyerName: m.buyerName,
    amount: m.amount,
    dueDate: m.dueDate,
    status: m.status,
    notes: m.notes,
    createdAt: m.createdAt,
    updatedAt: m.updatedAt,
  );
}

/// Converts a [DocumentHistoryEntity] to a [DocumentHistoryModel].
DocumentHistoryModel documentHistoryEntityToModel(DocumentHistoryEntity e) {
  return DocumentHistoryModel(
    id: e.id,
    vehicleId: e.vehicleId,
    agencyId: e.agencyId,
    status: e.status,
    changedBy: e.changedBy,
    remarks: e.remarks,
    registrationStatus: e.registrationStatus,
    registeredFrom: e.registeredFrom,
    numberPlate: e.numberPlate,
    registrationBook: e.registrationBook,
    checklist: e.checklist,
    statusDate: e.statusDate,
    createdAt: e.createdAt,
  );
}

/// Converts a [DocumentHistoryModel] to a [DocumentHistoryEntity].
DocumentHistoryEntity documentHistoryModelToEntity(DocumentHistoryModel m) {
  return DocumentHistoryEntity(
    id: m.id,
    vehicleId: m.vehicleId,
    agencyId: m.agencyId,
    status: m.status,
    changedBy: m.changedBy,
    remarks: m.remarks,
    registrationStatus: m.registrationStatus,
    registeredFrom: m.registeredFrom,
    numberPlate: m.numberPlate,
    registrationBook: m.registrationBook,
    checklist: m.checklist,
    statusDate: m.statusDate,
    createdAt: m.createdAt,
  );
}

/// Converts a [VehicleServiceRecordEntity] to a [VehicleServiceRecord].
VehicleServiceRecord vehicleServiceRecordEntityToModel(
    VehicleServiceRecordEntity e) {
  return VehicleServiceRecord(
    id: e.id,
    type: e.type,
    chassisNo: e.chassisNo,
    oldNumber: e.oldNumber,
    newNumber: e.newNumber,
    customerName: e.customerName,
    firstOwner: e.firstOwner,
    secondOwner: e.secondOwner,
    phone: e.phone,
    amount: e.amount,
    receivedBy: e.receivedBy,
    agencyId: e.agencyId,
    date: e.date,
    note: e.note,
    firstOwnerBiometricPending: e.firstOwnerBiometricPending,
    secondOwnerBiometricPending: e.secondOwnerBiometricPending,
  );
}

/// Converts a [VehicleServiceRecord] to a [VehicleServiceRecordEntity].
VehicleServiceRecordEntity vehicleServiceRecordModelToEntity(
    VehicleServiceRecord m) {
  return VehicleServiceRecordEntity(
    id: m.id,
    type: m.type,
    phone: m.phone,
    receivedBy: m.receivedBy,
    agencyId: m.agencyId,
    chassisNo: m.chassisNo,
    oldNumber: m.oldNumber,
    newNumber: m.newNumber,
    customerName: m.customerName,
    firstOwner: m.firstOwner,
    secondOwner: m.secondOwner,
    note: m.note,
    amount: m.amount,
    firstOwnerBiometricPending: m.firstOwnerBiometricPending,
    secondOwnerBiometricPending: m.secondOwnerBiometricPending,
    date: m.date,
  );
}

/// Converts a [RetailPriceEntity] to a [RetailPriceModel].
RetailPriceModel retailPriceEntityToModel(RetailPriceEntity e) {
  return RetailPriceModel(
    id: e.id,
    make: e.make,
    model: e.model,
    agencyId: e.agencyId,
    price: e.price,
    updatedAt: e.updatedAt,
  );
}

/// Converts a [RetailPriceModel] to a [RetailPriceEntity].
RetailPriceEntity retailPriceModelToEntity(RetailPriceModel m) {
  return RetailPriceEntity(
    id: m.id,
    make: m.make,
    model: m.model,
    agencyId: m.agencyId,
    price: m.price,
    updatedAt: m.updatedAt,
  );
}
