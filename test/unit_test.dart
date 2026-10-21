import 'package:flutter_test/flutter_test.dart';

import 'package:showroom_app/models/dealer_model.dart';
import 'package:showroom_app/models/sale_model.dart';
import 'package:showroom_app/utils/validators.dart';

void main() {
  group('SaleModel profit', () {
    test('returns positive profit when sale price exceeds purchase price', () {
      final sale = SaleModel(
        id: 's1',
        vehicleId: 'v1',
        dealerId: 'd1',
        buyerName: 'John',
        buyerEmail: 'john@example.com',
        buyerPhone: '123',
        purchasePrice: 8000,
        salePrice: 10000,
        saleDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(sale.profit, 2000);
    });

    test('returns zero profit when prices are equal', () {
      final sale = SaleModel(
        id: 's1',
        vehicleId: 'v1',
        dealerId: 'd1',
        buyerName: 'John',
        buyerEmail: 'john@example.com',
        buyerPhone: '123',
        purchasePrice: 10000,
        salePrice: 10000,
        saleDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(sale.profit, 0);
    });

    test('returns negative profit (loss) when purchase exceeds sale', () {
      final sale = SaleModel(
        id: 's1',
        vehicleId: 'v1',
        dealerId: 'd1',
        buyerName: 'John',
        buyerEmail: 'john@example.com',
        buyerPhone: '123',
        purchasePrice: 10000,
        salePrice: 8000,
        saleDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(sale.profit, -2000);
    });

    test('copies with overridden prices', () {
      final sale = SaleModel(
        id: 's1',
        vehicleId: 'v1',
        dealerId: 'd1',
        buyerName: 'John',
        buyerEmail: 'john@example.com',
        buyerPhone: '123',
        purchasePrice: 8000,
        salePrice: 10000,
        saleDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final updated = sale.copyWith(purchasePrice: 9000, salePrice: 11000);
      expect(updated.profit, 2000);
      expect(updated.purchasePrice, 9000);
      expect(updated.salePrice, 11000);
      expect(updated.id, 's1'); // unchanged fields preserved
    });
  });

  group('DealerModel commission & stats', () {
    test('defaults totalCommission to 0 and totalSales to 0', () {
      final dealer = DealerModel(
        id: 'd1',
        name: 'Best Auto',
        email: 'contact@bestauto.com',
        phone: '1234567890',
        address: '1 Main St',
        city: 'Springfield',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(dealer.totalCommission, 0.0);
      expect(dealer.totalSales, 0);
      expect(dealer.commissionPercent, isNull);
    });

    test('round-trips commissionPercent', () {
      final dealer = DealerModel(
        id: 'd1',
        name: 'Best Auto',
        email: 'contact@bestauto.com',
        phone: '1234567890',
        address: '1 Main St',
        city: 'Springfield',
        commissionPercent: 7.5,
        totalCommission: 525.0,
        totalSales: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final restored = DealerModel.fromJson(dealer.toJson());
      expect(restored.commissionPercent, 7.5);
      expect(restored.totalCommission, 525.0);
      expect(restored.totalSales, 3);
    });

    test('copies with updated stats', () {
      final dealer = DealerModel(
        id: 'd1',
        name: 'Best Auto',
        email: 'contact@bestauto.com',
        phone: '1234567890',
        address: '1 Main St',
        city: 'Springfield',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final updated = dealer.copyWith(
        totalSales: dealer.totalSales + 1,
        totalCommission: dealer.totalCommission + 250.0,
      );
      expect(updated.totalSales, 1);
      expect(updated.totalCommission, 250.0);
      expect(updated.id, 'd1');
    });
  });

  group('Validators edge cases', () {
    test('email accepts mixed case', () {
      expect(Validators.validateEmail('User@Example.COM'), isNull);
    });

    test('email rejects missing TLD', () {
      expect(Validators.validateEmail('user@localhost'), isNotNull);
    });

    test('password accepts exactly 6 chars', () {
      expect(Validators.validatePassword('abc123'), isNull);
    });

    test('password rejects 5 chars', () {
      expect(Validators.validatePassword('abc12'), isNotNull);
    });

    test('phone rejects fewer than 10 digits', () {
      expect(Validators.validatePhone('12345'), isNotNull);
    });

    test('phone accepts 10+ digits (formatting ignored)', () {
      expect(Validators.validatePhone('+1 555 123 4567'), isNull);
    });
  });
}
