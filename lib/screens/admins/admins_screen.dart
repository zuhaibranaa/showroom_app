import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';

class AdminsScreen extends ConsumerStatefulWidget {
  const AdminsScreen({super.key});

  @override
  ConsumerState<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends ConsumerState<AdminsScreen> {
  Future<void> _deleteInvite(String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invite'),
        content: Text('Remove the invite for $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(deleteAdminInviteProvider.notifier).deleteInvite(email);
    if (!mounted) return;

    final state = ref.read(deleteAdminInviteProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
    } else {
      ref.invalidate(adminInvitesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admins = ref.watch(adminsProvider);
    final invites = ref.watch(adminInvitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admins'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admins/add'),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.refresh(adminsProvider.future),
            ref.refresh(adminInvitesProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Pending Invites',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            invites.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No pending invites'),
                  );
                }
                return Column(
                  children: data.map((invite) {
                    final email = (invite['email'] as String?) ?? '';
                    return CustomCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.mail_outline, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (invite['name'] as String?) ?? 'Admin',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Waiting for registration',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteInvite(email),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Error: $error'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Registered Admins',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            admins.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No admins yet'),
                  );
                }
                return Column(
                  children: data.map((admin) => _AdminTile(admin: admin)).toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTile extends ConsumerWidget {
  final UserModel admin;

  const _AdminTile({required this.admin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withValues(alpha: 0.2),
            child: const Icon(Icons.person, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  admin.email,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (admin.agencyIds.isEmpty)
            Text(
              'No agencies',
              style: TextStyle(fontSize: 12, color: Colors.orange[700]),
            )
          else
            Text(
              '${admin.agencyIds.length} agenc${admin.agencyIds.length == 1 ? 'y' : 'ies'}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }
}
