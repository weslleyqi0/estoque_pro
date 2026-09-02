import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/customers_debt_report_entity.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/deliveries_report_entity.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/report_period.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/reports_summary_entity.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/sales_chart_point.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/sales_report_entity.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/seller_ranking_item_entity.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/stock_report_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:intl/intl.dart';

class GetReportsUseCase {
  const GetReportsUseCase();

  ReportsSummaryEntity execute({
    required ReportPeriod period,
    required List<ProductEntity> products,
    required List<SaleEntity> sales,
    required List<DeliveryEntity> deliveries,
    required List<CustomerEntity> customers,
    required List<CustomerPaymentEntity> customerPayments,
  }) {
    final productMap = {for (final p in products) p.id: p};

    final salesReport = _buildSalesReport(
      period: period,
      sales: sales,
      productMap: productMap,
    );

    final stockReport = _buildStockReport(products);

    final customersDebtReport = _buildCustomersDebtReport(
      customers: customers,
      sales: sales,
      payments: customerPayments,
    );

    final deliveriesReport = _buildDeliveriesReport(
      period: period,
      deliveries: deliveries,
    );

    return ReportsSummaryEntity(
      period: period,
      sales: salesReport,
      stock: stockReport,
      customersDebt: customersDebtReport,
      deliveries: deliveriesReport,
    );
  }

  SalesReportEntity _buildSalesReport({
    required ReportPeriod period,
    required List<SaleEntity> sales,
    required Map<String, ProductEntity> productMap,
  }) {
    // Vendas ativas no período atual (convertendo sempre para horário local)
    final currentSales = sales.where((s) {
      if (s.status == SaleStatus.cancelled) return false;
      final dt = s.createdAt.toLocal();
      return !dt.isBefore(period.startDate) && !dt.isAfter(period.endDate);
    }).toList();

    // Vendas ativas no período anterior (convertendo sempre para horário local)
    final previousSales = sales.where((s) {
      if (s.status == SaleStatus.cancelled) return false;
      final dt = s.createdAt.toLocal();
      return !dt.isBefore(period.previousStartDate) &&
          !dt.isAfter(period.previousEndDate);
    }).toList();

    final totalSales = currentSales.fold(0.0, (sum, s) => sum + s.total);
    final previousTotalSales = previousSales.fold(0.0, (sum, s) => sum + s.total);
    final totalDiscount = currentSales.fold(0.0, (sum, s) => sum + s.calculatedDiscount);

    // Custo total das mercadorias vendidas no período atual
    double totalCost = 0.0;
    for (final sale in currentSales) {
      for (final item in sale.items) {
        final product = productMap[item.productId];
        final cost = product?.costPrice ?? 0.0;
        totalCost += cost * item.quantity;
      }
    }

    final grossProfit = totalSales - totalCost;
    final marginPercent = totalSales > 0 ? (grossProfit / totalSales) * 100 : 0.0;

    // Formas de pagamento
    double cashAmount = 0.0;
    double cardCreditAmount = 0.0;
    double cardDebitAmount = 0.0;
    double fiadoAmount = 0.0;
    double pixAmount = 0.0;

    int fiadoSalesCount = 0;

    for (final s in currentSales) {
      switch (s.paymentMethod) {
        case PaymentMethod.dinheiro:
          cashAmount += s.total;
          break;
        case PaymentMethod.credito:
          cardCreditAmount += s.total;
          break;
        case PaymentMethod.debito:
          cardDebitAmount += s.total;
          break;
        case PaymentMethod.fiado:
          fiadoAmount += s.total;
          fiadoSalesCount++;
          break;
        case PaymentMethod.pix:
          pixAmount += s.total;
          break;
      }
    }

    final cancelledSalesCount = sales.where((s) {
      return s.status == SaleStatus.cancelled &&
          !s.createdAt.isBefore(period.startDate) &&
          !s.createdAt.isAfter(period.endDate);
    }).length;

    final chartPoints = _buildChartPoints(
      period: period,
      currentSales: currentSales,
      previousSales: previousSales,
    );

    // Ranking de vendedores no período
    final sellerMap = <String, _SellerAccumulator>{};
    for (final sale in currentSales) {
      final acc = sellerMap.putIfAbsent(
        sale.userId,
        () => _SellerAccumulator(userId: sale.userId, userName: sale.userName),
      );
      acc.salesCount++;
      acc.totalAmount += sale.total;
    }

    final sellerRanking = sellerMap.values.map((a) {
      return SellerRankingItemEntity(
        userId: a.userId,
        userName: a.userName.trim().isNotEmpty ? a.userName : 'Vendedor',
        salesCount: a.salesCount,
        totalAmount: a.totalAmount,
      );
    }).toList()
      ..sort((a, b) {
        final cmp = b.totalAmount.compareTo(a.totalAmount);
        if (cmp != 0) return cmp;
        return b.salesCount.compareTo(a.salesCount);
      });

    return SalesReportEntity(
      salesCount: currentSales.length,
      totalSales: totalSales,
      totalCost: totalCost,
      grossProfit: grossProfit,
      marginPercent: marginPercent,
      totalDiscount: totalDiscount,
      cashAmount: cashAmount,
      cardCreditAmount: cardCreditAmount,
      cardDebitAmount: cardDebitAmount,
      fiadoAmount: fiadoAmount,
      pixAmount: pixAmount,
      previousTotalSales: previousTotalSales,
      chartPoints: chartPoints,
      sellerRanking: sellerRanking,
      cancelledSalesCount: cancelledSalesCount,
      fiadoSalesCount: fiadoSalesCount,
    );
  }

  List<SalesChartPoint> _buildChartPoints({
    required ReportPeriod period,
    required List<SaleEntity> currentSales,
    required List<SaleEntity> previousSales,
  }) {
    switch (period.type) {
      case ReportPeriodType.today:
        // Divisão por blocos de 2 horas das 06h às 20h
        const hours = [6, 8, 10, 12, 14, 16, 18, 20];
        return hours.map((h) {
          final label = '${h.toString().padLeft(2, '0')}h';
          bool matches(DateTime dt) {
            final local = dt.toLocal();
            if (h == 6) return local.hour < 8;
            if (h == 20) return local.hour >= 20;
            return local.hour >= h && local.hour < h + 2;
          }

          final current = currentSales
              .where((s) => matches(s.createdAt))
              .fold(0.0, (sum, s) => sum + s.total);
          final previous = previousSales
              .where((s) => matches(s.createdAt))
              .fold(0.0, (sum, s) => sum + s.total);
          return SalesChartPoint(label: label, currentAmount: current, previousAmount: previous);
        }).toList();

      case ReportPeriodType.week:
        // Segunda a sábado (DateTime.monday == 1, saturday == 6)
        const days = [
          (1, 'Seg'),
          (2, 'Ter'),
          (3, 'Qua'),
          (4, 'Qui'),
          (5, 'Sex'),
          (6, 'Sáb'),
        ];
        return days.map((day) {
          final current = currentSales
              .where((s) => s.createdAt.weekday == day.$1)
              .fold(0.0, (sum, s) => sum + s.total);
          final previous = previousSales
              .where((s) => s.createdAt.weekday == day.$1)
              .fold(0.0, (sum, s) => sum + s.total);
          return SalesChartPoint(label: day.$2, currentAmount: current, previousAmount: previous);
        }).toList();

      case ReportPeriodType.month:
        // Agrupamento por 4 semanas / períodos do mês (Dias 1-7, 8-14, 15-21, 22+)
        const periods = [
          ('1-7', 1, 7),
          ('8-14', 8, 14),
          ('15-21', 15, 21),
          ('22-28', 22, 28),
          ('29+', 29, 31),
        ];
        return periods.map((p) {
          final current = currentSales
              .where((s) => s.createdAt.day >= p.$2 && s.createdAt.day <= p.$3)
              .fold(0.0, (sum, s) => sum + s.total);
          final previous = previousSales
              .where((s) => s.createdAt.day >= p.$2 && s.createdAt.day <= p.$3)
              .fold(0.0, (sum, s) => sum + s.total);
          return SalesChartPoint(label: p.$1, currentAmount: current, previousAmount: previous);
        }).toList();

      case ReportPeriodType.year:
        // 12 meses do ano
        const months = [
          (1, 'Jan'),
          (2, 'Fev'),
          (3, 'Mar'),
          (4, 'Abr'),
          (5, 'Mai'),
          (6, 'Jun'),
          (7, 'Jul'),
          (8, 'Ago'),
          (9, 'Set'),
          (10, 'Out'),
          (11, 'Nov'),
          (12, 'Dez'),
        ];
        return months.map((m) {
          final current = currentSales
              .where((s) => s.createdAt.month == m.$1)
              .fold(0.0, (sum, s) => sum + s.total);
          final previous = previousSales
              .where((s) => s.createdAt.month == m.$1)
              .fold(0.0, (sum, s) => sum + s.total);
          return SalesChartPoint(label: m.$2, currentAmount: current, previousAmount: previous);
        }).toList();

      case ReportPeriodType.custom:
        final durationInDays = period.endDate.difference(period.startDate).inDays;
        if (durationInDays <= 7) {
          // Pontos diários
          final points = <SalesChartPoint>[];
          for (int i = 0; i <= durationInDays; i++) {
            final curDay = period.startDate.add(Duration(days: i));
            final prevDay = period.previousStartDate.add(Duration(days: i));
            final label = DateFormat('dd/MM').format(curDay);

            final current = currentSales
                .where((s) =>
                    s.createdAt.year == curDay.year &&
                    s.createdAt.month == curDay.month &&
                    s.createdAt.day == curDay.day)
                .fold(0.0, (sum, s) => sum + s.total);

            final previous = previousSales
                .where((s) =>
                    s.createdAt.year == prevDay.year &&
                    s.createdAt.month == prevDay.month &&
                    s.createdAt.day == prevDay.day)
                .fold(0.0, (sum, s) => sum + s.total);

            points.add(SalesChartPoint(label: label, currentAmount: current, previousAmount: previous));
          }
          return points;
        } else {
          // 5 divisões equivalentes do período
          final step = (durationInDays / 5).ceil();
          final points = <SalesChartPoint>[];
          for (int i = 0; i < 5; i++) {
            final segStart = period.startDate.add(Duration(days: i * step));
            final segEnd = i == 4 ? period.endDate : segStart.add(Duration(days: step - 1, hours: 23, minutes: 59));
            final prevSegStart = period.previousStartDate.add(Duration(days: i * step));
            final prevSegEnd = i == 4 ? period.previousEndDate : prevSegStart.add(Duration(days: step - 1, hours: 23, minutes: 59));

            final label = '${DateFormat('dd/MM').format(segStart)}';

            final current = currentSales
                .where((s) => !s.createdAt.isBefore(segStart) && !s.createdAt.isAfter(segEnd))
                .fold(0.0, (sum, s) => sum + s.total);

            final previous = previousSales
                .where((s) => !s.createdAt.isBefore(prevSegStart) && !s.createdAt.isAfter(prevSegEnd))
                .fold(0.0, (sum, s) => sum + s.total);

            points.add(SalesChartPoint(label: label, currentAmount: current, previousAmount: previous));
          }
          return points;
        }
    }
  }

  StockReportEntity _buildStockReport(List<ProductEntity> products) {
    final unarchived = products.where((p) => !p.isArchived).toList();
    final archived = products.where((p) => p.isArchived).toList();
    final active = unarchived.where((p) => p.isActive).toList();
    final inactive = unarchived.where((p) => !p.isActive).toList();

    int totalUnits = 0;
    int lowStock = 0;
    int outOfStock = 0;
    double totalCost = 0.0;
    double totalSelling = 0.0;
    double totalProjectedProfit = 0.0;

    for (final p in unarchived) {
      totalUnits += p.stock;
      if (p.isActive) {
        if (p.stock <= 0) {
          outOfStock++;
        } else if (p.stock <= p.minStock) {
          lowStock++;
        }
      }
      totalCost += p.totalCostStock;
      totalSelling += p.totalSellingStock;
      totalProjectedProfit += p.totalProjectedProfit;
    }

    return StockReportEntity(
      totalProducts: unarchived.length,
      activeProducts: active.length,
      totalUnitsInStock: totalUnits,
      lowStockCount: lowStock,
      outOfStockCount: outOfStock,
      archivedCount: archived.length,
      inactiveCount: inactive.length,
      totalCostStock: totalCost,
      totalSellingStock: totalSelling,
      totalProjectedProfit: totalProjectedProfit,
    );
  }

  CustomersDebtReportEntity _buildCustomersDebtReport({
    required List<CustomerEntity> customers,
    required List<SaleEntity> sales,
    required List<CustomerPaymentEntity> payments,
  }) {
    int customersInDebt = 0;
    double totalDebtAmount = 0.0;

    // Calcular dívida de cada cliente
    for (final customer in customers) {
      final customerSales = sales.where(
        (s) =>
            s.customerId == customer.id &&
            s.paymentMethod == PaymentMethod.fiado &&
            s.status != SaleStatus.cancelled,
      );
      final debt = customerSales.fold(0.0, (sum, s) => sum + s.total);

      final customerPayments = payments.where(
        (p) => p.customerId == customer.id && !p.isCancelled,
      );
      final paid = customerPayments.fold(0.0, (sum, p) => sum + p.amount);

      final currentDebt = debt - paid;
      if (currentDebt > 0.009) {
        customersInDebt++;
        totalDebtAmount += currentDebt;
      }
    }

    return CustomersDebtReportEntity(
      totalCustomers: customers.length,
      customersInDebtCount: customersInDebt,
      totalDebtAmount: totalDebtAmount,
    );
  }

  DeliveriesReportEntity _buildDeliveriesReport({
    required ReportPeriod period,
    required List<DeliveryEntity> deliveries,
  }) {
    // Pendentes e Atrasadas: mostradas todas que estiverem pendentes ou atrasadas, independente do filtro
    int pending = 0;
    int delayed = 0;

    for (final d in deliveries) {
      if (d.status == DeliveryStatus.cancelled || d.status == DeliveryStatus.completed) {
        continue;
      }
      if (d.isDelayed) {
        delayed++;
      } else {
        pending++;
      }
    }

    // Concluídas (e canceladas): apenas as que pertencem ao período filtrado
    int completed = 0;
    int cancelled = 0;

    for (final d in deliveries) {
      final date = d.deliveredAt ?? d.scheduledAt;
      final inPeriod = !date.isBefore(period.startDate) && !date.isAfter(period.endDate);
      if (!inPeriod) continue;

      if (d.status == DeliveryStatus.completed) {
        completed++;
      } else if (d.status == DeliveryStatus.cancelled) {
        cancelled++;
      }
    }

    return DeliveriesReportEntity(
      totalDeliveries: completed + pending + delayed,
      pendingCount: pending,
      delayedCount: delayed,
      completedCount: completed,
      cancelledCount: cancelled,
    );
  }
}

class _SellerAccumulator {
  final String userId;
  final String userName;
  int salesCount = 0;
  double totalAmount = 0.0;

  _SellerAccumulator({
    required this.userId,
    required this.userName,
  });
}
