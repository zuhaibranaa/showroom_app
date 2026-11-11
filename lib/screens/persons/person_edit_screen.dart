import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sale_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_and_error.dart';

class PersonEditScreen extends ConsumerStatefulWidget {
  final String name;
  final String? saleId;
  final String? vehicleId;

  const PersonEditScreen({
    super.key,
    required this.name,
    this.saleId,
    this.vehicleId,
  });

  @override
  ConsumerState<PersonEditScreen> createState() => _PersonEditScreenState();
}

class _PersonEditScreenState extends ConsumerState<PersonEditScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _cnic = TextEditingController();
  final _father = TextEditingController();
  final _address = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _cnic.dispose();
    _father.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.saleId != null) {
      final saleAsync = ref.watch(saleByIdProvider(widget.saleId!));
      return saleAsync.when(
        loading: () =>
            const Scaffold(body: LoadingWidget(message: 'Loading...')),
        error: (e, _) => Scaffold(body: ErrorView(message: e.toString())),
        data: (sale) {
          if (sale == null) {
            return const Scaffold(body: Center(child: Text('Sale not found')));
          }
          if (!_loaded) {
            _name.text = sale.buyerName;
            _phone.text = sale.buyerPhone;
            _cnic.text = sale.purchaserCNIC ?? '';
            _father.text = sale.purchaserFatherName ?? '';
            _address.text = sale.purchaserAddress ?? '';
            _loaded = true;
          }
          return _buildForm(
            context,
            onSave: () async {
              setState(() => _saving = true);
              try {
                await ref
                    .read(updateSaleProvider.notifier)
                    .updateSale(
                      sale.id,
                      sale.copyWith(
                        buyerName: _name.text.trim(),
                        buyerPhone: _phone.text.trim(),
                        purchaserCNIC: _cnic.text.trim().isEmpty
                            ? null
                            : _cnic.text.trim(),
                        purchaserFatherName: _father.text.trim().isEmpty
                            ? null
                            : _father.text.trim(),
                        purchaserAddress: _address.text.trim().isEmpty
                            ? null
                            : _address.text.trim(),
                      ),
                    );
                ref.invalidate(saleByIdProvider(sale.id));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Person updated')),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              } finally {
                if (mounted) setState(() => _saving = false);
              }
            },
          );
        },
      );
    }

    if (widget.vehicleId != null) {
      final vehicleAsync = ref.watch(vehicleByIdProvider(widget.vehicleId!));
      return vehicleAsync.when(
        loading: () =>
            const Scaffold(body: LoadingWidget(message: 'Loading...')),
        error: (e, _) => Scaffold(body: ErrorView(message: e.toString())),
        data: (vehicle) {
          if (vehicle == null) {
            return const Scaffold(
                body: Center(child: Text('Vehicle not found')));
          }
          if (!_loaded) {
            _name.text = vehicle.sellerName ?? '';
            _phone.text = vehicle.sellerPhone ?? '';
            _cnic.text = vehicle.sellerCNIC ?? '';
            _father.text = vehicle.sellerFatherName ?? '';
            _address.text = vehicle.sellerAddress ?? '';
            _loaded = true;
          }
          return _buildForm(
            context,
            onSave: () async {
              setState(() => _saving = true);
              try {
                await ref
                    .read(updateVehicleProvider.notifier)
                    .updateVehicle(
                      vehicle.id,
                      vehicle.copyWith(
                        sellerName: _name.text.trim().isEmpty
                            ? null
                            : _name.text.trim(),
                        sellerPhone: _phone.text.trim().isEmpty
                            ? null
                            : _phone.text.trim(),
                        sellerCNIC: _cnic.text.trim().isEmpty
                            ? null
                            : _cnic.text.trim(),
                        sellerFatherName: _father.text.trim().isEmpty
                            ? null
                            : _father.text.trim(),
                        sellerAddress: _address.text.trim().isEmpty
                            ? null
                            : _address.text.trim(),
                      ),
                    );
                ref.invalidate(vehicleByIdProvider(vehicle.id));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Person updated')),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              } finally {
                if (mounted) setState(() => _saving = false);
              }
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: const Center(child: Text('No editable record selected')),
    );
  }

  Widget _buildForm(
    BuildContext context, {
    required Future<void> Function() onSave,
  }) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Person')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CustomTextField(label: 'Name *', controller: _name),
          CustomTextField(
            label: 'Phone',
            controller: _phone,
            keyboardType: TextInputType.phone,
          ),
          CustomTextField(
            label: 'CNIC',
            controller: _cnic,
            keyboardType: TextInputType.number,
          ),
          CustomTextField(label: 'Father name', controller: _father),
          CustomTextField(label: 'Address', controller: _address, maxLines: 2),
          CustomButton(
            label: 'Save',
            isLoading: _saving,
            onPressed: _saving ? () {} : () => onSave(),
          ),
        ],
      ),
    );
  }
}
