import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/report_period.dart';
import 'package:estoque_pro/app/features/reports/domain/usecases/get_reports_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GetReportsUseCase useCase;

  setUp(() {
    useCase = const GetReportsUseCase();
  });

  final testProducts = [
    const ProductEntity(
      id: 'prod1',
      name: 'Camisa Básica',
      imgUrl: '',
      description: '',
      categories: [],
      price: 100.0,
      costPrice: 40.0,
      stock: 10,
      minStock: 5,
    ),
    const ProductEntity(
      id: 'prod2',
      name: 'Bermuda Jeans',
      imgUrl: '',
      description: '',
      categories: [],
      price: 80.0,
      costPrice: 50.0,
      stock: 2, // Estoque baixo (< minStock)
      minStock: 5,
    ),
    const ProductEntity(
      id: 'prod3',
      name: 'Boné Preto',
      imgUrl: '',
      description: '',
      categories: [],
      price: 50.0,
      costPrice: 20.0,
      stock: 0, // Estoque vazio
      minStock: 3,
    ),
    const ProductEntity(
      id: 'prod4',
      name: 'Produto Arquivado',
      imgUrl: '',
      description: '',
      categories: [],
      price: 30.0,
      costPrice: 15.0,
      stock: 5,
      minStock: 2,
      isArchived: true,
    ),
    const ProductEntity(
      id: 'prod5',
      name: 'Produto Desativado',
      imgUrl: '',
      description: '',
      categories: [],
      price: 0.0,
      costPrice: 0.0,
      stock: 0,
      minStock: 0,
      isActive: false,
    ),
  ];

  final now = DateTime(2026, 9, 2, 14, 0); // Quarta-feira
  final period = ReportPeriod.today(now);

  final testSales = [
    SaleEntity(
      id: 's1',
      saleNumber: '001',
      items: const [
        SaleItemEntity(
          productId: 'prod1',
          productName: 'Camisa Básica',
          productImgUrl: '',
          unitPrice: 100.0,
          quantity: 2,
        ),
      ],
      subtotal: 200.0,
      total: 200.0,
      paymentMethod: PaymentMethod.dinheiro,
      userId: 'u1',
      userName: 'Admin',
      status: SaleStatus.completed,
      createdAt: DateTime(2026, 9, 2, 10, 0), // Período atual
    ),
    SaleEntity(
      id: 's2',
      saleNumber: '002',
      items: const [
        SaleItemEntity(
          productId: 'prod2',
          productName: 'Bermuda Jeans',
          productImgUrl: '',
          unitPrice: 80.0,
          quantity: 1,
        ),
      ],
      subtotal: 80.0,
      total: 80.0,
      paymentMethod: PaymentMethod.fiado,
      customerId: 'c1',
      customerName: 'Carlos',
      userId: 'u2',
      userName: 'Lucas',
      status: SaleStatus.completed,
      createdAt: DateTime(2026, 9, 2, 12, 0), // Período atual
    ),
    SaleEntity(
      id: 's3',
      saleNumber: '003',
      items: const [
        SaleItemEntity(
          productId: 'prod1',
          productName: 'Camisa Básica',
          productImgUrl: '',
          unitPrice: 100.0,
          quantity: 1,
        ),
      ],
      subtotal: 100.0,
      total: 100.0,
      paymentMethod: PaymentMethod.pix,
      userId: 'u1',
      userName: 'Admin',
      status: SaleStatus.cancelled, // Cancelada -> deve ser ignorada
      createdAt: DateTime(2026, 9, 2, 13, 0),
    ),
    SaleEntity(
      id: 's_prev',
      saleNumber: '000',
      items: const [
        SaleItemEntity(
          productId: 'prod1',
          productName: 'Camisa Básica',
          productImgUrl: '',
          unitPrice: 100.0,
          quantity: 1,
        ),
      ],
      subtotal: 100.0,
      total: 100.0,
      paymentMethod: PaymentMethod.credito,
      userId: 'u1',
      userName: 'Admin',
      status: SaleStatus.completed,
      createdAt: DateTime(2026, 9, 1, 15, 0), // Período anterior (ontem)
    ),
  ];

  final testDeliveries = [
    DeliveryEntity(
      id: 'd1',
      saleId: 's1',
      saleNumber: '001',
      customerId: 'c1',
      customerName: 'Carlos',
      customerAddress: 'Rua Central, 10',
      items: const [],
      subtotal: 200.0,
      totalAmount: 200.0,
      paymentMethod: PaymentMethod.dinheiro,
      status: DeliveryStatus.completed,
      scheduledAt: DateTime(2026, 9, 2, 11, 0),
      userId: 'u1',
      userName: 'Admin',
      createdAt: now,
    ),
  ];

  final testCustomers = [
    const CustomerEntity(id: 'c1', name: 'Carlos', phone: '11999999999'),
    const CustomerEntity(id: 'c2', name: 'Maria', phone: '11888888888'),
  ];

  final testPayments = <CustomerPaymentEntity>[];

  group('GetReportsUseCase', () {
    test('aggregates sales report with profit, cost and payment methods correctly', () {
      final summary = useCase.execute(
        period: period,
        products: testProducts,
        sales: testSales,
        deliveries: testDeliveries,
        customers: testCustomers,
        customerPayments: testPayments,
      );

      final sales = summary.sales;
      expect(sales.salesCount, 2); // s1 e s2 (s3 cancelada é ignorada)
      expect(sales.totalSales, 280.0); // 200 + 80
      expect(sales.previousTotalSales, 100.0); // 100 de ontem

      // Custo: s1 (2x40 = 80) + s2 (1x50 = 50) = 130
      expect(sales.totalCost, 130.0);
      // Lucro bruto: 280 - 130 = 150
      expect(sales.grossProfit, 150.0);

      // Métodos de pagamento
      expect(sales.cashAmount, 200.0);
      expect(sales.fiadoAmount, 80.0);

      // Ranking de vendedores
      expect(sales.sellerRanking.length, 2);
      expect(sales.sellerRanking.first.userId, 'u1');
      expect(sales.sellerRanking.first.userName, 'Admin');
      expect(sales.sellerRanking.first.salesCount, 1);
      expect(sales.sellerRanking.first.totalAmount, 200.0);

      expect(sales.sellerRanking[1].userId, 'u2');
      expect(sales.sellerRanking[1].userName, 'Lucas');
      expect(sales.sellerRanking[1].salesCount, 1);
      expect(sales.sellerRanking[1].totalAmount, 80.0);
    });

    test('aggregates stock report with low stock, empty stock and projections', () {
      final summary = useCase.execute(
        period: period,
        products: testProducts,
        sales: testSales,
        deliveries: testDeliveries,
        customers: testCustomers,
        customerPayments: testPayments,
      );

      final stock = summary.stock;
      expect(stock.totalProducts, 4);
      expect(stock.activeProducts, 3);
      expect(stock.lowStockCount, 1); // prod2 (2 <= 5)
      expect(stock.outOfStockCount, 1); // prod3 (0 <= 0)
      expect(stock.archivedCount, 1); // prod4
      expect(stock.inactiveCount, 1); // prod5
      expect(stock.totalUnitsInStock, 12); // 10 + 2 + 0 + 0

      // Custo total: 10*40 + 2*50 + 0*20 = 400 + 100 = 500
      expect(stock.totalCostStock, 500.0);
      // Faturamento projetado: 10*100 + 2*80 = 1000 + 160 = 1160
      expect(stock.totalSellingStock, 1160.0);
      // Lucro projetado: 1160 - 500 = 660
      expect(stock.totalProjectedProfit, 660.0);
    });

    test('aggregates customers debt report correctly', () {
      final summary = useCase.execute(
        period: period,
        products: testProducts,
        sales: testSales,
        deliveries: testDeliveries,
        customers: testCustomers,
        customerPayments: testPayments,
      );

      final debtReport = summary.customersDebt;
      expect(debtReport.totalCustomers, 2);
      expect(debtReport.customersInDebtCount, 1); // Carlos deve 80
      expect(debtReport.totalDebtAmount, 80.0);
    });

    test('aggregates deliveries with pending and delayed globally and completed by period', () {
      final oldDelayedDelivery = DeliveryEntity(
        id: 'd_old',
        saleId: 's_old',
        saleNumber: '000',
        customerId: 'c1',
        customerName: 'Carlos',
        customerAddress: 'Rua Central, 10',
        items: const [],
        subtotal: 50.0,
        totalAmount: 50.0,
        paymentMethod: PaymentMethod.dinheiro,
        status: DeliveryStatus.delayed,
        scheduledAt: DateTime(2026, 8, 15, 10, 0), // Data antiga fora do período atual
        userId: 'u1',
        userName: 'Admin',
        createdAt: DateTime(2026, 8, 15),
      );

      final oldCompletedDelivery = DeliveryEntity(
        id: 'd_comp_old',
        saleId: 's_comp',
        saleNumber: '002',
        customerId: 'c2',
        customerName: 'Maria',
        customerAddress: 'Rua B, 20',
        items: const [],
        subtotal: 70.0,
        totalAmount: 70.0,
        paymentMethod: PaymentMethod.dinheiro,
        status: DeliveryStatus.completed,
        scheduledAt: DateTime(2026, 8, 10, 10, 0),
        deliveredAt: DateTime(2026, 8, 10, 12, 0), // Concluída no passado (fora do período)
        userId: 'u1',
        userName: 'Admin',
        createdAt: DateTime(2026, 8, 10),
      );

      final pendingDelivery = DeliveryEntity(
        id: 'd_pend',
        saleId: 's_pend',
        saleNumber: '003',
        customerId: 'c1',
        customerName: 'Carlos',
        customerAddress: 'Rua C, 30',
        items: const [],
        subtotal: 30.0,
        totalAmount: 30.0,
        paymentMethod: PaymentMethod.dinheiro,
        status: DeliveryStatus.pending,
        scheduledAt: DateTime(2026, 10, 1, 10, 0), // Agendada no futuro (fora do período de hoje)
        userId: 'u1',
        userName: 'Admin',
        createdAt: now,
      );

      final allDeliveries = [
        ...testDeliveries, // d1: completed hoje (no período)
        oldDelayedDelivery, // atrasada antiga
        oldCompletedDelivery, // concluída antiga
        pendingDelivery, // pendente futura
      ];

      final summary = useCase.execute(
        period: period,
        products: testProducts,
        sales: testSales,
        deliveries: allDeliveries,
        customers: testCustomers,
        customerPayments: testPayments,
      );

      final deliveriesReport = summary.deliveries;
      expect(deliveriesReport.completedCount, 1); // Apenas d1 de hoje
      expect(deliveriesReport.delayedCount, 1); // d_old (globalmente atrasada)
      expect(deliveriesReport.pendingCount, 1); // d_pend (globalmente pendente)
    });
  });
}
