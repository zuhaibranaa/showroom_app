import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agency_model.dart';
import '../services/agency_service.dart';

// Agency Service Provider
final agencyServiceProvider = Provider((ref) => AgencyService());

// Get all agencies
final agenciesProvider = FutureProvider<List<AgencyModel>>((ref) async {
  final agencyService = ref.watch(agencyServiceProvider);
  return agencyService.getAgencies();
});

// Stream agencies
final agenciesStreamProvider = StreamProvider<List<AgencyModel>>((ref) {
  final agencyService = ref.watch(agencyServiceProvider);
  return agencyService.agenciesStream();
});

// Get agency by ID
final agencyByIdProvider =
    FutureProvider.family<AgencyModel, String>((ref, id) async {
  final agencyService = ref.watch(agencyServiceProvider);
  return agencyService.getAgencyById(id);
});

// Create agency state
final createAgencyProvider =
    StateNotifierProvider<CreateAgencyNotifier, AsyncValue<String>>((ref) {
  final agencyService = ref.watch(agencyServiceProvider);
  return CreateAgencyNotifier(agencyService);
});

class CreateAgencyNotifier extends StateNotifier<AsyncValue<String>> {
  final AgencyService _agencyService;

  CreateAgencyNotifier(this._agencyService) : super(const AsyncValue.data(''));

  Future<void> createAgency(AgencyModel agency) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _agencyService.createAgency(agency),
    );
  }
}

// Update agency state
final updateAgencyProvider =
    StateNotifierProvider<UpdateAgencyNotifier, AsyncValue<void>>((ref) {
  final agencyService = ref.watch(agencyServiceProvider);
  return UpdateAgencyNotifier(agencyService);
});

class UpdateAgencyNotifier extends StateNotifier<AsyncValue<void>> {
  final AgencyService _agencyService;

  UpdateAgencyNotifier(this._agencyService) : super(const AsyncValue.data(null));

  Future<void> updateAgency(String id, AgencyModel agency) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _agencyService.updateAgency(id, agency),
    );
  }
}

// Delete agency state
final deleteAgencyProvider =
    StateNotifierProvider<DeleteAgencyNotifier, AsyncValue<void>>((ref) {
  final agencyService = ref.watch(agencyServiceProvider);
  return DeleteAgencyNotifier(agencyService);
});

class DeleteAgencyNotifier extends StateNotifier<AsyncValue<void>> {
  final AgencyService _agencyService;

  DeleteAgencyNotifier(this._agencyService) : super(const AsyncValue.data(null));

  Future<void> deleteAgency(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _agencyService.deleteAgency(id),
    );
  }
}
