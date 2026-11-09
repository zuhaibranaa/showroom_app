import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/operations_models.dart';

class OperationsService {
  final _db=FirebaseFirestore.instance;
  CollectionReference<Map<String,dynamic>> get _payments=>_db.collection(AppConfig.paymentsCollection);
  CollectionReference<Map<String,dynamic>> get _history=>_db.collection(AppConfig.documentHistoryCollection);
  CollectionReference<Map<String,dynamic>> get _services=>_db.collection(AppConfig.vehicleServicesCollection);
  CollectionReference<Map<String,dynamic>> get _options=>_db.collection(AppConfig.optionsCollection);
  CollectionReference<Map<String,dynamic>> get _prices=>_db.collection(AppConfig.retailPricesCollection);

  Stream<List<PaymentModel>> payments()=>_payments.snapshots().map((s)=>s.docs.map((d)=>PaymentModel.fromJson({...d.data(),'id':d.id})).toList());
  Stream<List<PaymentModel>> paymentsForSale(String saleId)=>_payments.where('saleId',isEqualTo:saleId).snapshots().map((s)=>s.docs.map((d)=>PaymentModel.fromJson({...d.data(),'id':d.id})).toList());
  Future<void> savePayment(PaymentModel p,{String? id}) async {
    if(id==null) {
      await _payments.add(p.toJson());
    } else {
      await _payments.doc(id).update(p.toJson());
    }
    final sale=await _db.collection(AppConfig.salesCollection).doc(p.saleId).get();
    if(sale.exists){
      final all=await _payments.where('saleId',isEqualTo:p.saleId).get();
      final received=all.docs.where((d)=>d.data()['cancelled']!=true).fold<double>(0,(s,d)=>s+(d.data()['amount']??0).toDouble());
      final price=(sale.data()!['salePrice']??0).toDouble();
      await sale.reference.update({'amountReceived':received,'amountPaid':received,'balancePending':price-received,'pendingAmount':price-received,'promisedDate':p.promisedDate==null?null:Timestamp.fromDate(p.promisedDate!)});
    }
  }
  Future<void> cancelPayment(PaymentModel p,String? reason,DateTime promisedDate)=>savePayment(p.copyWith(cancelled:true,cancelReason:reason,promisedDate:promisedDate),id:p.id);

  Stream<List<DocumentHistoryModel>> documentHistory(String vehicleId)=>_history.where('vehicleId',isEqualTo:vehicleId).snapshots().map((s)=>s.docs.map((d)=>DocumentHistoryModel.fromJson({...d.data(),'id':d.id})).toList());
  Future<void> updateDocuments(DocumentHistoryModel h) async {
    await _db.runTransaction((tx) async {
      tx.set(_history.doc(),h.toJson());
      tx.update(_db.collection(AppConfig.vehiclesCollection).doc(h.vehicleId),{'documentStatus':h.status,'remarks':h.remarks,'registrationStatus':h.registrationStatus,'registeredFrom':h.registeredFrom,'plateNo':h.numberPlate,'registrationBook':h.registrationBook,'documentsReceived':h.checklist,'updatedAt':Timestamp.fromDate(DateTime.now())});
    });
  }

  Stream<List<VehicleServiceRecord>> vehicleServices()=>_services.snapshots().map((s)=>s.docs.map((d)=>VehicleServiceRecord.fromJson({...d.data(),'id':d.id})).toList());
  Future<void> saveVehicleService(VehicleServiceRecord r,{String? id})=>id==null?_services.add(r.toJson()):_services.doc(id).update(r.toJson());
  Future<void> deleteVehicleService(String id)=>_services.doc(id).delete();

  Stream<List<AppOptionModel>> options()=>_options.snapshots().map((s)=>s.docs.map((d)=>AppOptionModel.fromJson({...d.data(),'id':d.id})).toList());
  Future<void> saveOption(AppOptionModel o,{String? id})=>id==null?_options.add(o.toJson()):_options.doc(id).update(o.toJson());
  Stream<List<RetailPriceModel>> retailPrices()=>_prices.snapshots().map((s)=>s.docs.map((d)=>RetailPriceModel.fromJson({...d.data(),'id':d.id})).toList());
  Future<void> saveRetailPrice(RetailPriceModel p,{String? id})=>id==null?_prices.add(p.toJson()):_prices.doc(id).update(p.toJson());
  Future<void> deleteRetailPrice(String id)=>_prices.doc(id).delete();
}
