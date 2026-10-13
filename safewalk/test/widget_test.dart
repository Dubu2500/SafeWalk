import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safewalk/main.dart';
import 'package:safewalk/screens/home_screen.dart';
import 'package:safewalk/widgets/destination_card.dart';

void main() {
  testWidgets('App starts at the placeholder login', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Home searches and changes the selected destination', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(
      tester
          .widget<DestinationCard>(find.byType(DestinationCard).first)
          .selected,
      isTrue,
    );

    await tester.tap(find.text('Destino reciente'));
    await tester.pump();
    expect(
      tester
          .widget<DestinationCard>(find.byType(DestinationCard).last)
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<DestinationCard>(find.byType(DestinationCard).first)
          .selected,
      isFalse,
    );

    await tester.enterText(find.byType(TextField), 'Serrano');
    await tester.pump();
    expect(find.text('Casa'), findsOneWidget);
    expect(find.text('Destino reciente'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Sin resultados');
    await tester.pump();
    expect(find.text('No se encontraron destinos.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home scrolls on a small display with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const HomeScreen(),
      ),
    );
    await tester.ensureVisible(find.text('INICIAR SAFEWALK'));
    await tester.tap(find.text('INICIAR SAFEWALK'));
    await tester.pump();
    expect(
      find.textContaining('El inicio del trayecto estará disponible'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
