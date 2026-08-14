import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:showroom_app/models/dealer_model.dart';
import 'package:showroom_app/models/sale_model.dart';
import 'package:showroom_app/models/user_model.dart';
import 'package:showroom_app/models/vehicle_model.dart';
import 'package:showroom_app/utils/validators.dart';
import 'package:showroom_app/widgets/custom_button.dart';

void main() {
  group('VehicleModel', () {
    test('round-trips through JSON', () {
      final now = DateTime.now();
      final vehicle = VehicleModel(
        id: 'v1',
        make: 'Toyota',
        model: 'Corolla',
        year: 2022,
        color: 'Red',
        licensePlate: 'ABC-1234',
        vin: '1HGBH41JXMN109186',
        createdAt: now,
        updatedAt: now,
      );

      final restored = VehicleModel.fromJson(vehicle.toJson());

      expect(restored.id, 'v1');
      expect(restored.make, 'Toyota');
      expect(restored.model, 'Corolla');
      expect(restored.year, 2022);
      expect(restored.color, 'Red');
      expect(restored.vin, '1HGBH41JXMN109186');
      expect(restored.createdAt, now);
    });
  });

  group('SaleModel', () {
    test('calculates profit', () {
      final now = DateTime.now();
      final sale = SaleModel(
        id: 's1',
        vehicleId: 'v1',
        dealerId: 'd1',
        buyerName: 'John Doe',
        buyerEmail: 'john@example.com',
        buyerPhone: '1234567890',
        purchasePrice: 8000,
        salePrice: 10000,
        saleDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(sale.profit, 2000);
    });

    test('round-trips through JSON', () {
      final now = DateTime.now();
      final sale = SaleModel(
        id: 's1',
        vehicleId: 'v1',
        dealerId: 'd1',
        buyerName: 'John Doe',
        buyerEmail: 'john@example.com',
        buyerPhone: '1234567890',
        purchasePrice: 8000,
        salePrice: 10000,
        notes: 'Cash deal',
        saleDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final restored = SaleModel.fromJson(sale.toJson());

      expect(restored.id, 's1');
      expect(restored.buyerName, 'John Doe');
      expect(restored.purchasePrice, 8000);
      expect(restored.salePrice, 10000);
      expect(restored.notes, 'Cash deal');
      expect(restored.profit, 2000);
    });
  });

  group('DealerModel', () {
    test('round-trips a numeric commissionPercent', () {
      final now = DateTime.now();
      final dealer = DealerModel(
        id: 'd1',
        name: 'Best Auto',
        email: 'contact@bestauto.com',
        phone: '1234567890',
        address: '1 Main St',
        city: 'Springfield',
        commissionPercent: 5.0,
        createdAt: now,
        updatedAt: now,
      );

      final restored = DealerModel.fromJson(dealer.toJson());

      expect(restored.id, 'd1');
      expect(restored.commissionPercent, 5.0);
    });
  });

  group('UserModel', () {
    test('round-trips through JSON', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'u1',
        email: 'user@example.com',
        username: 'johndoe',
        role: 'dealer',
        createdAt: now,
        updatedAt: now,
      );

      final restored = UserModel.fromJson(user.toJson());

      expect(restored.id, 'u1');
      expect(restored.email, 'user@example.com');
      expect(restored.username, 'johndoe');
      expect(restored.role, 'dealer');
      expect(restored.userRole.name, 'dealer');
    });
  });

  group('Validators', () {
    test('accepts valid email', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
    });

    test('rejects invalid email', () {
      expect(Validators.validateEmail('not-an-email'), isNotNull);
    });

    test('rejects empty email', () {
      expect(Validators.validateEmail(''), isNotNull);
    });

    test('accepts valid password', () {
      expect(Validators.validatePassword('secret123'), isNull);
    });

    test('rejects short password', () {
      expect(Validators.validatePassword('12345'), isNotNull);
    });

    test('accepts valid phone', () {
      expect(Validators.validatePhone('1234567890'), isNull);
    });

    test('rejects short phone', () {
      expect(Validators.validatePhone('12345'), isNotNull);
    });
  });

  group('CustomButton', () {
    testWidgets('renders label and handles tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Save',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Save'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('disables button while loading', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Save',
              isLoading: true,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });
  });
}
