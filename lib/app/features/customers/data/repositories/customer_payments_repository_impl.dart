import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/customers/data/models/customer_payment_model.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';
import 'package:flutter/foundation.dart';

class CustomerPaymentsRepositoryImpl implements CustomerPaymentsRepository {
  final DatabaseService<CustomerPaymentEntity> _databaseService;

  CustomerPaymentsRepositoryImpl(this._databaseService);

  @override
  Stream<List<CustomerPaymentEntity>> watchAll() {
    return _databaseService
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
          debugPrint('---> CustomerPayments: Erro no listener: $e');
        });
  }

  @override
  Future<Result<List<CustomerPaymentEntity>>> getAll() async {
    try {
      final data = await _databaseService.getOnce();
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
      return Result.success(entities);
    } catch (e, stackTrace) {
      debugPrint('---> CustomerPayments: Erro getAll: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> save(CustomerPaymentEntity payment) async {
    final model = CustomerPaymentModel.fromEntity(payment);
    try {
      if (payment.id.isEmpty) {
        await _databaseService.add(model.toMap());
      } else {
        await _databaseService.update(payment.id, model.toMap());
      }
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> CustomerPayments: Erro ao salvar: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _databaseService.delete(id);
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> CustomerPayments: Erro ao deletar: $e');
      return Result.failure(e, stackTrace);
    }
  }
}
