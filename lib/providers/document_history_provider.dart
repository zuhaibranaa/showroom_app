import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../compat/model_converters.dart';
import '../core/application/services/document_history_application_service.dart';
import '../core/domain/entities/document_history.dart';
import '../core/domain/repositories/document_history_repository.dart';
import '../infrastructure/repositories/firestore_document_history_repository.dart';
import '../models/operations_models.dart';

// Repository provider (DIP: depends on abstraction)
final documentHistoryRepositoryProvider =
    Provider<IDocumentHistoryRepository>((ref) {
  return FirestoreDocumentHistoryRepository(FirebaseFirestore.instance);
});

// Application service provider (depends on repository abstraction)
final documentHistoryApplicationServiceProvider =
    Provider<DocumentHistoryApplicationService>((ref) {
  return DocumentHistoryApplicationService(
    ref.watch(documentHistoryRepositoryProvider),
  );
});

// Document history model providers (agency-scoped)
final documentHistoryByAgencyProvider =
    FutureProvider.family<List<DocumentHistoryModel>, String>(
  (ref, agencyId) async {
    final service = ref.watch(documentHistoryApplicationServiceProvider);
    final entities = await service.getByAgency(agencyId);
    return entities.map(documentHistoryEntityToModel).toList();
  },
);

final documentHistoryByVehicleProvider =
    FutureProvider.family<List<DocumentHistoryModel>, String>((ref, vehicleId) async {
  final service = ref.watch(documentHistoryApplicationServiceProvider);
  final entities = await service.getByVehicle(vehicleId);
  return entities.map(documentHistoryEntityToModel).toList();
});

final documentHistoryStreamByAgencyProvider =
    StreamProvider.family<List<DocumentHistoryModel>, String>((ref, agencyId) {
  final service = ref.watch(documentHistoryApplicationServiceProvider);
  return service.streamByAgency(agencyId).map((entities) =>
      entities.map(documentHistoryEntityToModel).toList());
});

final documentHistoryByIdProvider =
    FutureProvider.family<DocumentHistoryModel?, String>((ref, id) async {
  final service = ref.watch(documentHistoryApplicationServiceProvider);
  final entity = await service.getById(id);
  return entity != null ? documentHistoryEntityToModel(entity) : null;
});

// Create document history state
final createDocumentHistoryProvider =
    StateNotifierProvider<CreateDocumentHistoryNotifier, AsyncValue<String>>(
  (ref) {
    final service = ref.watch(documentHistoryApplicationServiceProvider);
    return CreateDocumentHistoryNotifier(service);
  },
);

class CreateDocumentHistoryNotifier
    extends StateNotifier<AsyncValue<String>> {
  final DocumentHistoryApplicationService _service;

  CreateDocumentHistoryNotifier(this._service)
      : super(const AsyncValue.data(''));

  Future<void> createDocumentHistory(DocumentHistoryModel history) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.create(documentHistoryModelToEntity(history)),
    );
  }
}

// Update document history state
final updateDocumentHistoryProvider =
    StateNotifierProvider<UpdateDocumentHistoryNotifier, AsyncValue<void>>(
  (ref) {
    final service = ref.watch(documentHistoryApplicationServiceProvider);
    return UpdateDocumentHistoryNotifier(service);
  },
);

class UpdateDocumentHistoryNotifier
    extends StateNotifier<AsyncValue<void>> {
  final DocumentHistoryApplicationService _service;

  UpdateDocumentHistoryNotifier(this._service)
      : super(const AsyncValue.data(null));

  Future<void> updateDocumentHistory(
          String id, DocumentHistoryModel history) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.update(id, documentHistoryModelToEntity(history)),
    );
  }
}

// Delete document history state
final deleteDocumentHistoryProvider =
    StateNotifierProvider<DeleteDocumentHistoryNotifier, AsyncValue<void>>(
  (ref) {
    final service = ref.watch(documentHistoryApplicationServiceProvider);
    return DeleteDocumentHistoryNotifier(service);
  },
);

class DeleteDocumentHistoryNotifier
    extends StateNotifier<AsyncValue<void>> {
  final DocumentHistoryApplicationService _service;

  DeleteDocumentHistoryNotifier(this._service)
      : super(const AsyncValue.data(null));

  Future<void> deleteDocumentHistory(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.delete(id));
  }
}
