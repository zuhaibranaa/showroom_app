import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../compat/model_converters.dart';
import '../core/application/services/pending_payment_application_service.dart';
import '../core/domain/entities/pending_payment.dart';
import '../core/domain/repositories/pending_payment_repository.dart';
import '../infrastructure/repositories/firestore_pending_payment_repository.dart';
import '../models/pending_payment_model.dart';

// Repository provider (DIP: depends on abstraction)
final pendingPaymentRepositoryProvider =
    Provider<IPendingPaymentRepository>((ref) {
  return FirestorePendingPaymentRepository(FirebaseFirestore.instance);
});

// Application service provider (depends on repository abstraction)
final pendingPaymentApplicationServiceProvider =
    Provider<PendingPaymentApplicationService>((ref) {
  return PendingPaymentApplicationService(
    ref.watch(pendingPaymentRepositoryProvider),
  );
});

// Pending payment model providers (agency-scoped)
final pendingPaymentsProvider = FutureProvider<List<PendingPaymentModel>>(
  (ref) async {
    final service = ref.watch(pendingPaymentApplicationServiceProvider);
    final entities = await service.getAll();
    return entities.map(pendingPaymentEntityToModel).toList();
  },
);

final pendingPaymentsByAgencyProvider =
    FutureProvider.family<List<PendingPaymentModel>, String>((ref, agencyId) async {
  final service = ref.watch(pendingPaymentApplicationServiceProvider);
  final entities = await service.getByAgency(agencyId);
  return entities.map(pendingPaymentEntityToModel).toList();
});

final pendingPaymentsStreamByAgencyProvider =
    StreamProvider.family<List<PendingPaymentModel>, String>((ref, agencyId) {
  final service = ref.watch(pendingPaymentApplicationServiceProvider);
  return service.streamByAgency(agencyId).map((entities) =>
      entities.map(pendingPaymentEntityToModel).toList());
});

final pendingPaymentByIdProvider =
    FutureProvider.family<PendingPaymentModel?, String>((ref, id) async {
  final service = ref.watch(pendingPaymentApplicationServiceProvider);
  final entity = await service.getById(id);
  return entity != null ? pendingPaymentEntityToModel(entity) : null;
});

// Create pending payment state
final createPendingPaymentProvider =
    StateNotifierProvider<CreatePendingPaymentNotifier, AsyncValue<String>>(
  (ref) {
    final service = ref.watch(pendingPaymentApplicationServiceProvider);
    return CreatePendingPaymentNotifier(service);
  },
);

class CreatePendingPaymentNotifier
    extends StateNotifier<AsyncValue<String>> {
  final PendingPaymentApplicationService _service;

  CreatePendingPaymentNotifier(this._service)
      : super(const AsyncValue.data(''));

  Future<void> createPendingPayment(PendingPaymentModel payment) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.create(pendingPaymentModelToEntity(payment)),
    );
  }
}

// Update pending payment state
final updatePendingPaymentProvider =
    StateNotifierProvider<UpdatePendingPaymentNotifier, AsyncValue<void>>(
  (ref) {
    final service = ref.watch(pendingPaymentApplicationServiceProvider);
    return UpdatePendingPaymentNotifier(service);
  },
);

class UpdatePendingPaymentNotifier
    extends StateNotifier<AsyncValue<void>> {
  final PendingPaymentApplicationService _service;

  UpdatePendingPaymentNotifier(this._service)
      : super(const AsyncValue.data(null));

  Future<void> updatePendingPayment(
          String id, PendingPaymentModel payment) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.update(id, pendingPaymentModelToEntity(payment)),
    );
  }
}

// Delete pending payment state
final deletePendingPaymentProvider =
    StateNotifierProvider<DeletePendingPaymentNotifier, AsyncValue<void>>(
  (ref) {
    final service = ref.watch(pendingPaymentApplicationServiceProvider);
    return DeletePendingPaymentNotifier(service);
  },
);

class DeletePendingPaymentNotifier
    extends StateNotifier<AsyncValue<void>> {
  final PendingPaymentApplicationService _service;

  DeletePendingPaymentNotifier(this._service)
      : super(const AsyncValue.data(null));

  Future<void> deletePendingPayment(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.delete(id));
  }
}
