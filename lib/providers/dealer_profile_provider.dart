import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dealer_model.dart';
import 'auth_provider.dart';
import 'dealer_provider.dart';

// Current dealer record streamed for the signed-in user.
// Uses the merged DealerModel (which now carries agency + permissions).
final currentDealerProfileProvider = StreamProvider<DealerModel?>((ref) {
  final uid = ref.watch(currentUserStreamProvider).value?.uid;
  if (uid == null) {
    return Stream.value(null);
  }
  final dealerService = ref.watch(dealerServiceProvider);
  return dealerService.dealerStreamByUserId(uid);
});
