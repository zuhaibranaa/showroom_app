import '../../config/reference_options.dart';
import '../../models/operations_models.dart';

const optionKinds = <String, String>{
  'make': 'Makes',
  'model': 'Models',
  'color': 'Colors',
  'city': 'Cities',
  'expense_category': 'Expense categories',
  'checklist': 'Checklist',
};

class DisplayOption {
  final String id;
  final String kind;
  final String name;
  final String scope;
  final String make;
  final bool visible;
  final bool isDefault;

  const DisplayOption({
    required this.id,
    required this.kind,
    required this.name,
    required this.scope,
    required this.make,
    required this.visible,
    required this.isDefault,
  });

  AppOptionModel toModel({String? name, bool? visible}) => AppOptionModel(
        id: id,
        kind: kind,
        name: name ?? this.name,
        scope: scope,
        make: make,
        visible: visible ?? this.visible,
      );
}

List<AppOptionModel> defaultOptions() => [
      ...ReferenceOptions.makes.map((name) => _default('make', name)),
      for (final entry in ReferenceOptions.modelsByMake.entries)
        ...entry.value.map((name) => _default('model', name, make: entry.key)),
      ...ReferenceOptions.colors.map((name) => _default('color', name)),
      ...ReferenceOptions.cities.map((name) => _default('city', name)),
      ...ReferenceOptions.bikeExpenseCategories.map(
          (name) => _default('expense_category', name, scope: 'bike')),
      ...ReferenceOptions.showroomExpenseCategories.map(
          (name) => _default('expense_category', name, scope: 'showroom')),
      ...ReferenceOptions.newChecklist
          .map((name) => _default('checklist', name, scope: 'new')),
      ...ReferenceOptions.usedChecklist
          .map((name) => _default('checklist', name, scope: 'used')),
    ];

/// Merges reference values with Firestore overrides and user-created values.
/// A stored record matching a default acts as its hide/show override.
List<DisplayOption> mergeOptions(Iterable<AppOptionModel> stored) {
  final remaining = stored.toList();
  final result = <DisplayOption>[];
  for (final option in defaultOptions()) {
    final index = remaining.indexWhere((item) => _sameIdentity(item, option));
    if (index >= 0) {
      final override = remaining.removeAt(index);
      result.add(_display(override, isDefault: true));
    } else {
      result.add(_display(option, isDefault: true));
    }
  }
  result.addAll(remaining.map((item) => _display(item, isDefault: false)));
  return result;
}

List<String> optionNames(
  Iterable<AppOptionModel> stored,
  String kind, {
  String? make,
  String? scope,
}) {
  final names = mergeOptions(stored)
      .where((item) =>
          item.kind == kind &&
          item.visible &&
          (make == null || item.make == make) &&
          (scope == null || item.scope == scope))
      .map((item) => item.name)
      .toSet()
      .toList();
  names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return names;
}

AppOptionModel _default(String kind, String name,
        {String scope = '', String make = ''}) =>
    AppOptionModel(kind: kind, name: name, scope: scope, make: make);

DisplayOption _display(AppOptionModel item, {required bool isDefault}) =>
    DisplayOption(
      id: item.id,
      kind: item.kind,
      name: item.name,
      scope: item.scope,
      make: item.make,
      visible: item.visible,
      isDefault: isDefault,
    );

bool _sameIdentity(AppOptionModel a, AppOptionModel b) =>
    a.kind == b.kind &&
    a.scope == b.scope &&
    a.make == b.make &&
    a.name.trim().toLowerCase() == b.name.trim().toLowerCase();
