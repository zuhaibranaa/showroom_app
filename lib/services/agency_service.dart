import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/agency_model.dart';

class AgencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createAgency(AgencyModel agency) async {
    final doc = await _firestore
        .collection(AppConfig.agenciesCollection)
        .add(agency.toJson());
    return doc.id;
  }

  Future<List<AgencyModel>> getAgencies() async {
    final querySnapshot =
        await _firestore.collection(AppConfig.agenciesCollection).get();
    return querySnapshot.docs
        .map((doc) => AgencyModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<AgencyModel> getAgencyById(String id) async {
    final doc = await _firestore
        .collection(AppConfig.agenciesCollection)
        .doc(id)
        .get();
    if (!doc.exists) throw Exception('Agency not found');
    return AgencyModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<List<AgencyModel>> getAgenciesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final results = <AgencyModel>[];
    // Firestore allows at most 30 values per `whereIn` query.
    for (final chunk in _chunks(ids, 30)) {
      final querySnapshot = await _firestore
          .collection(AppConfig.agenciesCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(querySnapshot.docs
          .map((doc) => AgencyModel.fromJson({...doc.data(), 'id': doc.id})));
    }
    return results;
  }

  Stream<List<AgencyModel>> agenciesStream() {
    return _firestore
        .collection(AppConfig.agenciesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AgencyModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  Future<void> updateAgency(String id, AgencyModel agency) async {
    await _firestore
        .collection(AppConfig.agenciesCollection)
        .doc(id)
        .update(agency.toJson());
  }

  Future<void> deleteAgency(String id) async {
    await _firestore
        .collection(AppConfig.agenciesCollection)
        .doc(id)
        .delete();
  }

  List<List<T>> _chunks<T>(List<T> list, int size) {
    final result = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      final end = i + size > list.length ? list.length : i + size;
      result.add(list.sublist(i, end));
    }
    return result;
  }
}
