import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _date(dynamic value) => value is Timestamp ? value.toDate() : value is DateTime ? value : DateTime.tryParse('$value') ?? DateTime.now();
DateTime? _optionalDate(dynamic value) => value == null ? null : _date(value);

class PaymentModel {
  final String id, saleId, vehicleId, mode;
  final double amount;
  final DateTime date;
  final String? bank, note, cancelReason;
  final DateTime? promisedDate;
  final bool cancelled;
  const PaymentModel({this.id='',required this.saleId,this.vehicleId='',required this.amount,required this.date,this.mode='CASH',this.bank,this.note,this.promisedDate,this.cancelled=false,this.cancelReason});
  factory PaymentModel.fromJson(Map<String,dynamic> j)=>PaymentModel(id:j['id']??'',saleId:j['saleId']??'',vehicleId:j['vehicleId']??'',amount:(j['amount']??0).toDouble(),date:_date(j['date']),mode:j['mode']??'CASH',bank:j['bank'],note:j['note'],promisedDate:_optionalDate(j['promisedDate']),cancelled:j['cancelled']??false,cancelReason:j['cancelReason']);
  Map<String,dynamic> toJson()=>{'saleId':saleId,'vehicleId':vehicleId,'amount':amount,'date':Timestamp.fromDate(date),'mode':mode,'bank':bank,'note':note,'promisedDate':promisedDate==null?null:Timestamp.fromDate(promisedDate!),'cancelled':cancelled,'cancelReason':cancelReason};
  PaymentModel copyWith({double? amount,DateTime? date,String? mode,String? bank,String? note,DateTime? promisedDate,bool? cancelled,String? cancelReason})=>PaymentModel(id:id,saleId:saleId,vehicleId:vehicleId,amount:amount??this.amount,date:date??this.date,mode:mode??this.mode,bank:bank??this.bank,note:note??this.note,promisedDate:promisedDate??this.promisedDate,cancelled:cancelled??this.cancelled,cancelReason:cancelReason??this.cancelReason);
}

class DocumentHistoryModel {
  final String id, vehicleId, status, changedBy;
  final String? remarks, registrationStatus, registeredFrom, numberPlate, registrationBook;
  final List<String> checklist;
  final DateTime statusDate, createdAt;
  const DocumentHistoryModel({this.id='',required this.vehicleId,required this.status,this.changedBy='',this.remarks,this.registrationStatus,this.registeredFrom,this.numberPlate,this.registrationBook,this.checklist=const[],required this.statusDate,required this.createdAt});
  factory DocumentHistoryModel.fromJson(Map<String,dynamic> j)=>DocumentHistoryModel(id:j['id']??'',vehicleId:j['vehicleId']??'',status:j['status']??'PENDING',changedBy:j['changedBy']??'',remarks:j['remarks'],registrationStatus:j['registrationStatus'],registeredFrom:j['registeredFrom'],numberPlate:j['numberPlate'],registrationBook:j['registrationBook'],checklist:List<String>.from(j['checklist']??[]),statusDate:_date(j['statusDate']),createdAt:_date(j['createdAt']));
  Map<String,dynamic> toJson()=>{'vehicleId':vehicleId,'status':status,'changedBy':changedBy,'remarks':remarks,'registrationStatus':registrationStatus,'registeredFrom':registeredFrom,'numberPlate':numberPlate,'registrationBook':registrationBook,'checklist':checklist,'statusDate':Timestamp.fromDate(statusDate),'createdAt':Timestamp.fromDate(createdAt)};
}

class VehicleServiceRecord {
  final String id, type, phone, receivedBy;
  final String? chassisNo, oldNumber, newNumber, customerName, firstOwner, secondOwner, note;
  final double amount;
  final bool firstOwnerBiometricPending, secondOwnerBiometricPending;
  final DateTime date;
  const VehicleServiceRecord({this.id='',required this.type,this.chassisNo,this.oldNumber,this.newNumber,this.customerName,this.firstOwner,this.secondOwner,required this.phone,required this.amount,required this.receivedBy,required this.date,this.note,this.firstOwnerBiometricPending=false,this.secondOwnerBiometricPending=false});
  factory VehicleServiceRecord.fromJson(Map<String,dynamic> j)=>VehicleServiceRecord(id:j['id']??'',type:j['type']??'REGISTRATION',chassisNo:j['chassisNo'],oldNumber:j['oldNumber'],newNumber:j['newNumber'],customerName:j['customerName'],firstOwner:j['firstOwner'],secondOwner:j['secondOwner'],phone:j['phone']??'',amount:(j['amount']??0).toDouble(),receivedBy:j['receivedBy']??'',date:_date(j['date']),note:j['note'],firstOwnerBiometricPending:j['firstOwnerBiometricPending']??false,secondOwnerBiometricPending:j['secondOwnerBiometricPending']??false);
  Map<String,dynamic> toJson()=>{'type':type,'chassisNo':chassisNo,'oldNumber':oldNumber,'newNumber':newNumber,'customerName':customerName,'firstOwner':firstOwner,'secondOwner':secondOwner,'phone':phone,'amount':amount,'receivedBy':receivedBy,'date':Timestamp.fromDate(date),'note':note,'firstOwnerBiometricPending':firstOwnerBiometricPending,'secondOwnerBiometricPending':secondOwnerBiometricPending};
}

class AppOptionModel {
  final String id, kind, name, scope, make;
  final bool visible;
  const AppOptionModel({this.id='',required this.kind,required this.name,this.scope='',this.make='',this.visible=true});
  factory AppOptionModel.fromJson(Map<String,dynamic> j)=>AppOptionModel(id:j['id']??'',kind:j['kind']??'',name:j['name']??'',scope:j['scope']??'',make:j['make']??'',visible:j['visible']??true);
  Map<String,dynamic> toJson()=>{'kind':kind,'name':name,'scope':scope,'make':make,'visible':visible};
}

class RetailPriceModel {
  final String id, make, model;
  final double price;
  final DateTime updatedAt;
  const RetailPriceModel({this.id='',required this.make,required this.model,required this.price,required this.updatedAt});
  factory RetailPriceModel.fromJson(Map<String,dynamic> j)=>RetailPriceModel(id:j['id']??'',make:j['make']??'',model:j['model']??'',price:(j['price']??0).toDouble(),updatedAt:_date(j['updatedAt']));
  Map<String,dynamic> toJson()=>{'make':make,'model':model,'price':price,'updatedAt':Timestamp.fromDate(updatedAt)};
}
