import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safewalk/main.dart';
import 'package:safewalk/models/app_settings.dart';
import 'package:safewalk/screens/register_screen.dart';
import 'package:safewalk/screens/settings_screen.dart';
import 'package:safewalk/theme/app_theme.dart';
import 'package:safewalk/screens/home_screen.dart';
import 'package:safewalk/widgets/destination_card.dart';

void main() {
  testWidgets('App starts at the plain login placeholder', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets(
    'Register controls and demo navigate to Home, drawer and settings',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp());
      Navigator.of(tester.element(find.text('Login'))).pushNamed('/register');
      await tester.pumpAndSettle();
      expect(find.text('Nombre completo'), findsOneWidget);
      await tester.tap(find.byTooltip('Mostrar contraseña').first);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).at(2)).obscureText,
        isFalse,
      );
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      await tester.ensureVisible(find.text('CREAR CUENTA'));
      await tester.tap(find.text('CREAR CUENTA'));
      await tester.pumpAndSettle();
      expect(find.text('Funcionalidad pendiente'), findsOneWidget);
      await tester.tap(find.text('Explorar demo'));
      await tester.pumpAndSettle();
      expect(find.text('Hola, Rubén 👋'), findsOneWidget);
      await tester.tap(find.byTooltip('Abrir menú de perfil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.text('Modo oscuro'))).brightness,
        Brightness.dark,
      );
      await tester.tap(find.byTooltip('Volver a Home'));
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.text('Casa'))).brightness,
        Brightness.dark,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Logout returns to the login placeholder', (tester) async {
    await tester.pumpWidget(const MyApp());
    Navigator.of(tester.element(find.text('Login'))).pushNamed('/home');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Abrir menú de perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Cerrar sesión'), 300);
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Register and settings fit small screens with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final settings = AppSettings();
    addTearDown(settings.dispose);
    for (final screen in [const RegisterScreen(), const SettingsScreen()]) {
      await tester.pumpWidget(
        SettingsScope(
          settings: settings,
          child: MaterialApp(
            theme: buildAppTheme(Brightness.light),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
            home: screen,
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (screen is RegisterScreen) {
        await tester.ensureVisible(find.text('CREAR CUENTA'));
      } else {
        await tester.scrollUntilVisible(find.text('Cerrar sesión'), 300);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
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
