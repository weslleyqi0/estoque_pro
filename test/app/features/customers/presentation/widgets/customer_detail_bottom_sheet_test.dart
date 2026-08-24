import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testCustomer = CustomerEntity(
    id: 'cust_123',
    name: 'Roberto Carlos',
    address: 'Av Paulista, 1000',
    cpf: '12345678901',
    phone: '11987654321',
    isActive: true,
  );

  Widget createWidgetUnderTest({required CustomerEntity customer, bool canEdit = true}) {
    return MaterialApp(
      home: Scaffold(
        body: CustomerDetailBottomSheet(
          customer: customer,
          canEdit: canEdit,
        ),
      ),
    );
  }

  testWidgets('CustomerDetailBottomSheet displays customer info and edit button when canEdit is true',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(customer: testCustomer, canEdit: true));

    expect(find.text('Detalhes do Cliente'), findsOneWidget);
    expect(find.text('Roberto Carlos'), findsOneWidget);
    expect(find.text('Ativo'), findsOneWidget);
    expect(find.text('123.456.789-01'), findsOneWidget);
    expect(find.text('(11) 98765-4321'), findsOneWidget);
    expect(find.text('Av Paulista, 1000'), findsOneWidget);
    expect(find.byIcon(AppIcons.edit), findsOneWidget);
  });

  testWidgets('CustomerDetailBottomSheet hides edit button when canEdit is false', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(customer: testCustomer, canEdit: false));

    expect(find.byIcon(AppIcons.edit), findsNothing);
  });
}
