import 'dart:async';

import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/features/customers/data/models/customer_payment_model.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';
import 'package:flutter/foundation.dart';

class CustomerPaymentsRepositoryImpl implements CustomerPaymentsRepository {
  final FirebaseDatabaseService _firebaseDb;

  CustomerPaymentsRepositoryImpl(this._firebaseDb);

  @override
  Stream<List<CustomerPaymentEntity>> watchAll() {
    return _firebaseDb
        .listen()
        .map((data) {
          final List<CustomerPaymentEntity> entities = [];
          if (data != null) {
            for (final entry in data.entries) {
              if (entry.value is Map) {
                final model = CustomerPaymentModel.fromMap(
                  entry.key,
                  Map<dynamic, dynamic>.from(entry.value as Map),
                );
                entities.add(model.toEntity());
              }
            }
          }
          entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return entities;
        })
        .handleError((e) {
          debugPrint('---> CustomerPayments: Erro no listener Firebase: $e');
        });
  }

  @override
  Future<List<CustomerPaymentEntity>> getAll() async {
    try {
      final data = await _firebaseDb.getOnce();
      final List<CustomerPaymentEntity> entities = [];
      if (data != null) {
        for (final entry in data.entries) {
          if (entry.value is Map) {
            final model = CustomerPaymentModel.fromMap(
              entry.key,
              Map<dynamic, dynamic>.from(entry.value as Map),
            );
            entities.add(model.toEntity());
          }
        }
      }
      entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entities;
    } catch (e) {
      debugPrint('---> CustomerPayments: Erro getAll Firebase: $e');
      return [];
    }
  }

  @override
  Future<void> save(CustomerPaymentEntity payment) async {
    final model = CustomerPaymentModel.fromEntity(payment);
    try {
      if (payment.id.isEmpty) {
        await _firebaseDb.add(model.toMap());
      } else {
        await _firebaseDb.update(payment.id, model.toMap());
      }
    } catch (e) {
      debugPrint('---> CustomerPayments: Erro ao salvar no Firebase: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _firebaseDb.delete(id);
    } catch (e) {
      debugPrint('---> CustomerPayments: Erro ao deletar no Firebase: $e');
      rethrow;
    }
  }
}
