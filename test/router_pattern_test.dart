import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final authProvider = StreamProvider<String?>((ref) async* {
  yield 'user1';
});

final profileProvider =
    StreamProvider.family<String?, String>((ref, uid) async* {
  yield 'role-user';
});

class FakeNotifier {
  FakeNotifier(this.container) {
    _authSub = container.listen(authProvider, (_, next) {
      if (next.hasValue) _onAuthChanged(next.value);
    });
  }

  final ProviderContainer container;
  late final ProviderSubscription _authSub;
  ProviderSubscription? _profileSub;
  String? role;
  bool fired = false;

  void _onAuthChanged(String? user) {
    if (user != null) {
      _profileSub = container.listen(profileProvider(user), (_, next) {
        if (next.hasValue) {
          role = next.value;
        }
      });
    }
    fired = true;
  }

  void dispose() {
    _authSub.close();
    _profileSub?.close();
  }
}

void main() {
  test('ref.listen with instance members updates without throwing', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = FakeNotifier(container);
    addTearDown(notifier.dispose);

    // Flush several event-loop turns so the single-emission streams fully
    // propagate through the provider graph before asserting.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(notifier.fired, isTrue);
    expect(notifier.role, 'role-user');
  });
}
