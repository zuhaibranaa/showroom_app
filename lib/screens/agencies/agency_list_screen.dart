import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/agency_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_and_error.dart';

class AgencyListScreen extends ConsumerStatefulWidget {
  const AgencyListScreen({super.key});

  @override
  ConsumerState<AgencyListScreen> createState() => _AgencyListScreenState();
}

class _AgencyListScreenState extends ConsumerState<AgencyListScreen> {
  Future<void> _deleteAgency(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Agency'),
        content: Text('Are you sure you want to delete "$name"?'),
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

    await ref.read(deleteAgencyProvider.notifier).deleteAgency(id);
    if (!mounted) return;

    final state = ref.read(deleteAgencyProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agency deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final agencies = ref.watch(agenciesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agencies'),
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
        onPressed: () => context.push('/agencies/add'),
        child: const Icon(Icons.add),
      ),
      body: agencies.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('No agencies found'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(agenciesStreamProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final agency = data[index];
                return CustomCard(
                  onTap: () => context.push('/agencies/${agency.id}/edit'),
                  child: Row(
                    children: [
                      const Icon(Icons.business, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          agency.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteAgency(agency.id, agency.name),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading agencies...'),
        error: (error, stackTrace) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(agenciesStreamProvider),
        ),
      ),
    );
  }
}
