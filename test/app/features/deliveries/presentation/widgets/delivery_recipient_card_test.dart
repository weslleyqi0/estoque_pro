import 'package:estoque_pro/app/features/deliveries/presentation/widgets/delivery_recipient_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DeliveryRecipientCard hides map, call and whatsapp buttons when phone and address are empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeliveryRecipientCard(
            customerName: 'Cliente Teste',
            customerAddress: '',
            customerPhone: null,
            onOpenMap: () {},
            onCall: () {},
            onWhatsApp: () {},
          ),
        ),
      ),
    );

    expect(find.text('Cliente Teste'), findsOneWidget);
    expect(find.text('Endereço não cadastrado'), findsOneWidget);
    expect(find.byTooltip('Abrir no Maps'), findsNothing);
    expect(find.byTooltip('Ligar'), findsNothing);
    expect(find.byTooltip('WhatsApp'), findsNothing);
  });

  testWidgets('DeliveryRecipientCard displays map button when address is present, and phone buttons when phone is present', (tester) async {
    var mapClicked = false;
    var callClicked = false;
    var whatsAppClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeliveryRecipientCard(
            customerName: 'Maria Silva',
            customerAddress: 'Av. Paulista, 1000',
            customerPhone: '(11) 98765-4321',
            onOpenMap: () => mapClicked = true,
            onCall: () => callClicked = true,
            onWhatsApp: () => whatsAppClicked = true,
          ),
        ),
      ),
    );

    expect(find.text('Maria Silva'), findsOneWidget);
    expect(find.text('Av. Paulista, 1000'), findsOneWidget);
    expect(find.text('(11) 98765-4321'), findsOneWidget);

    expect(find.byTooltip('Abrir no Maps'), findsOneWidget);
    expect(find.byTooltip('Ligar'), findsOneWidget);
    expect(find.byTooltip('WhatsApp'), findsOneWidget);

    await tester.tap(find.byTooltip('Abrir no Maps'));
    expect(mapClicked, isTrue);

    await tester.tap(find.byTooltip('Ligar'));
    expect(callClicked, isTrue);

    await tester.tap(find.byTooltip('WhatsApp'));
    expect(whatsAppClicked, isTrue);
  });
}
