import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/finalize_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/save_draft_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFinalizeSaleUseCase extends Mock implements FinalizeSaleUseCase {}
class MockSaveDraftSaleUseCase extends Mock implements SaveDraftSaleUseCase {}

void main() {
  late MockFinalizeSaleUseCase mockFinalizeSaleUseCase;
  late MockSaveDraftSaleUseCase mockSaveDraftSaleUseCase;
  late CartViewModel cartViewModel;

  setUp(() {
    mockFinalizeSaleUseCase = MockFinalizeSaleUseCase();
    mockSaveDraftSaleUseCase = MockSaveDraftSaleUseCase();
    cartViewModel = CartViewModel(mockFinalizeSaleUseCase, mockSaveDraftSaleUseCase);
  });

  final sampleSale = SaleEntity(
    id: 'sale-1',
    saleNumber: 'SL-001',
    userId: 'u1',
    userName: 'Vendedor',
    items: const [
      SaleItemEntity(
        productId: 'prod-1',
        productName: 'Camisa Polo',
        productImgUrl: '',
        unitPrice: 50.0,
        quantity: 2,
      ),
    ],
    subtotal: 100.0,
    discountValue: 0.0,
    total: 100.0,
    paymentMethod: PaymentMethod.pix,
    status: SaleStatus.inProgress,
    createdAt: DateTime(2026, 8, 25),
  );

  final realProductInStock = const ProductEntity(
    id: 'prod-1',
    name: 'Camisa Polo',
    price: 50.0,
    stock: 10,
    imgUrl: '',
    description: '',
    categories: [],
    minStock: 1,
  );

  test('loadSale and updateAvailableProducts allows increasing item quantity up to real stock', () {
    // 1. Carrega a venda antes dos produtos do catálogo chegarem do Firebase (lista vazia)
    cartViewModel.loadSale(sampleSale, []);

    expect(cartViewModel.items.length, 1);
    expect(cartViewModel.items.first.quantity, 2);

    // Sem os produtos reais, o stock de fallback era 2, então não conseguiria aumentar
    expect(cartViewModel.items.first.product.stock, 2);
    expect(cartViewModel.increaseQty('prod-1'), isFalse);

    // 2. Os produtos chegam da stream do ProductsViewModel e atualizam o CartViewModel
    cartViewModel.updateAvailableProducts([realProductInStock]);

    expect(cartViewModel.items.first.product.stock, 10);

    // 3. Agora consegue aumentar a quantidade normalmente até o estoque real (10)
    expect(cartViewModel.increaseQty('prod-1'), isTrue);
    expect(cartViewModel.items.first.quantity, 3);

    // addProduct também deve conseguir aumentar a quantidade
    expect(cartViewModel.addProduct(realProductInStock), isTrue);
    expect(cartViewModel.items.first.quantity, 4);
  });

  test('finalizeSaleCommand executes and clears cart on success', () async {
    cartViewModel.addProduct(realProductInStock);
    expect(cartViewModel.items.length, 1);

    when(
      () => mockFinalizeSaleUseCase.execute(
        items: any(named: 'items'),
        saleNumber: any(named: 'saleNumber'),
        editingSaleId: any(named: 'editingSaleId'),
        discountType: any(named: 'discountType'),
        discountValue: any(named: 'discountValue'),
        subtotal: any(named: 'subtotal'),
        total: any(named: 'total'),
        paymentMethod: any(named: 'paymentMethod'),
        amountPaid: any(named: 'amountPaid'),
        change: any(named: 'change'),
        userId: any(named: 'userId'),
        userName: any(named: 'userName'),
        availableProducts: any(named: 'availableProducts'),
      ),
    ).thenAnswer((_) async => Result.success(sampleSale));

    await cartViewModel.finalizeSaleCommand.execute((
      userId: 'u1',
      userName: 'Vendedor',
      availableProducts: [realProductInStock],
    ));

    expect(cartViewModel.finalizeSaleCommand.isSuccess, isTrue);
    expect(cartViewModel.items.isEmpty, isTrue);
  });

  test('saveDraftCommand executes and clears cart on success', () async {
    cartViewModel.addProduct(realProductInStock);
    expect(cartViewModel.items.length, 1);

    when(
      () => mockSaveDraftSaleUseCase.execute(
        items: any(named: 'items'),
        saleNumber: any(named: 'saleNumber'),
        editingSaleId: any(named: 'editingSaleId'),
        discountType: any(named: 'discountType'),
        discountValue: any(named: 'discountValue'),
        subtotal: any(named: 'subtotal'),
        total: any(named: 'total'),
        paymentMethod: any(named: 'paymentMethod'),
        amountPaid: any(named: 'amountPaid'),
        change: any(named: 'change'),
        userId: any(named: 'userId'),
        userName: any(named: 'userName'),
        availableProducts: any(named: 'availableProducts'),
        createdAt: any(named: 'createdAt'),
      ),
    ).thenAnswer((_) async {});

    await cartViewModel.saveDraftCommand.execute((
      userId: 'u1',
      userName: 'Vendedor',
      availableProducts: [realProductInStock],
    ));

    expect(cartViewModel.saveDraftCommand.isSuccess, isTrue);
    expect(cartViewModel.items.isEmpty, isTrue);
  });
}
