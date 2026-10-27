# SafeWalk — Entrega 1

Prototipo de acompañamiento durante trayectos. El inicio de sesión y el registro usan Firebase Authentication (correo y contraseña). Los destinos, el contacto de confianza y el mapa siguen usando datos locales de ejemplo; no hay GPS ni notificaciones reales.

## Ejecutar

```bash
flutter pub get
flutter run
```

Antes de ejecutar, en la consola de Firebase (proyecto `safewalk-fb1e9`) activa **Authentication → Sign-in method → Email/Password**.

La app inicia en `AuthGate`: muestra el login o, si ya hay una sesión abierta, Home. **Crea una** lleva al registro, que crea la cuenta en Firebase y guarda el nombre del usuario. Home saluda con ese nombre; el avatar abre un Drawer con Perfil (alerta provisional) y Ajustes. Ajustes permite volver a Home y cerrar sesión. **INICIAR SAFEWALK** abre la pantalla del trayecto.

Para previsualizar una pantalla: `flutter run --dart-define=INITIAL_ROUTE=/register` (también `/home`, `/map` y `/settings`).

## Interfaz y componentes

- Pantallas: login, registro, Home, trayecto (mapa) y ajustes.
- Inicio de sesión con Google (`google_sign_in` + `GoogleAuthProvider.credential` en `lib/data/current_user.dart`). Requiere registrar la huella SHA-1 de la app Android en Firebase.
- Firebase Authentication con correo y contraseña: registro, inicio de sesión, sesión persistente y cierre de sesión. `lib/auth_gate.dart` escucha `userChanges()` con un `StreamBuilder` y muestra el login o Home según haya sesión. Los campos vacíos o inválidos muestran su error en rojo debajo de cada campo; los errores de Firebase aparecen en rojo arriba del botón.
- Componentes reutilizables en `lib/widgets`, modelos en `lib/models`, datos de ejemplo en `lib/data` y temas en `lib/theme`.
- Modo oscuro global, visibilidad de contraseñas, casilla de términos, búsqueda, selección de destino y preferencias que redibujan la interfaz.
- Preferencias mantenidas durante la sesión; al reiniciar vuelven a sus valores iniciales.
- Acciones pendientes explicadas mediante AlertDialog. El registro valida campos vacíos, contraseña de al menos 6 caracteres, que las contraseñas coincidan y la casilla de términos.
- Paquete [flutter_svg](https://pub.dev/packages/flutter_svg): dibuja el símbolo vectorial de SafeWalk en registro, menú y ajustes.
- Nombre SafeWalk e icono propio de escudo con camino, instalado en Android e iOS (también macOS). Fuente vectorial en `assets/safewalk_mark.svg` y PNG en `assets/app_icon.png`.

## Widgets para presentar en clase

`AnimatedSwitcher` anima el icono al mostrar u ocultar contraseñas; `ExpansionTile` despliega la explicación de privacidad de ubicación en ajustes. Verificar que no se hayan visto en clase; no se dispone del temario del semestre. Catálogo: https://docs.flutter.dev/ui/widgets.

## Factor WOW propuesto para entrega final

Mapa con ruta y seguimiento de ubicación en tiempo real compartido con un contacto de confianza durante el trayecto. **INICIAR SAFEWALK** ya abre la pantalla del trayecto con su estado, tiempo estimado, contacto acompañante, botón de ayuda y la alerta simulada de "fuera de ruta". Falta el mapa real (el área del mapa es un fondo de color), la ubicación por GPS y el envío de alertas.

## Verificación

```bash
flutter analyze
flutter test
```
