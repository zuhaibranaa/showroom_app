import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/vehicle_model.dart';

class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create vehicle
  Future<String> createVehicle(VehicleModel vehicle) async {
    final doc = await _firestore
        .collection(AppConfig.vehiclesCollection)
        .add(vehicle.toJson());
    return doc.id;
  }

  // Get all vehicles
  Future<List<VehicleModel>> getVehicles() async {
    final querySnapshot =
        await _firestore.collection(AppConfig.vehiclesCollection).get();
    return querySnapshot.docs
        .map((doc) => VehicleModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Get vehicles for an agency
  Future<List<VehicleModel>> getVehiclesByAgency(String agencyId) async {
    final querySnapshot = await _firestore
        .collection(AppConfig.vehiclesCollection)
        .where('agencyId', isEqualTo: agencyId)
        .get();
    return querySnapshot.docs
        .map((doc) => VehicleModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Get vehicle by ID
  Future<VehicleModel> getVehicleById(String id) async {
    final doc = await _firestore
        .collection(AppConfig.vehiclesCollection)
        .doc(id)
        .get();
    if (!doc.exists) throw Exception('Vehicle not found');
    return VehicleModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  // Update vehicle
  Future<void> updateVehicle(String id, VehicleModel vehicle) async {
    await _firestore
        .collection(AppConfig.vehiclesCollection)
        .doc(id)
        .update(vehicle.toJson());
  }

  // Delete vehicle
  Future<void> deleteVehicle(String id) async {
    await _firestore
        .collection(AppConfig.vehiclesCollection)
        .doc(id)
        .delete();
  }

  // Stream all vehicles
  Stream<List<VehicleModel>> vehiclesStream() {
    return _firestore
        .collection(AppConfig.vehiclesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VehicleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Stream vehicles for an agency
  Stream<List<VehicleModel>> vehiclesStreamByAgency(String agencyId) {
    return _firestore
        .collection(AppConfig.vehiclesCollection)
        .where('agencyId', isEqualTo: agencyId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VehicleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }
}
