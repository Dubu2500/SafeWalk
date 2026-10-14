# SafeWalk — Entrega 1

Prototipo visual de acompañamiento durante trayectos. Datos locales de ejemplo; no hay autenticación, GPS, notificaciones ni conexión a una base de datos.

## Ejecutar

```bash
flutter pub get
flutter run
```

La app inicia con un texto provisional “Login”, sin diseño ni controles. Registro se puede previsualizar con la ruta `/register`. Crear cuenta muestra una alerta; **Explorar demo** abre Home sin autenticar. El avatar de Home abre un Drawer con Perfil (alerta provisional) y Ajustes. Ajustes permite volver a Home y cerrar la demo para regresar al login.

Para previsualizar una pantalla: `flutter run --dart-define=INITIAL_ROUTE=/register` (también `/home` y `/settings`).

## Interfaz y componentes

- Tres pantallas diseñadas: registro, Home y ajustes. La ruta inicial solo muestra el texto provisional “Login”.
- Componentes reutilizables en `lib/widgets`, modelos en `lib/models`, datos de ejemplo en `lib/data` y temas en `lib/theme`.
- Modo oscuro global, visibilidad de contraseñas, casilla de términos, búsqueda, selección de destino y preferencias que redibujan la interfaz.
- Preferencias mantenidas durante la sesión; al reiniciar vuelven a sus valores iniciales.
- Acciones pendientes explicadas mediante AlertDialog. El prototipo no crea cuentas ni valida los campos de registro.
- Paquete [flutter_svg](https://pub.dev/packages/flutter_svg): dibuja el símbolo vectorial de SafeWalk en registro, menú y ajustes.
- Nombre SafeWalk e icono propio de escudo con camino, instalado en Android e iOS (también macOS). Fuente vectorial en `assets/safewalk_mark.svg` y PNG en `assets/app_icon.png`.

## Widgets para presentar en clase

`AnimatedSwitcher` anima el icono al mostrar u ocultar contraseñas; `ExpansionTile` despliega la explicación de privacidad de ubicación en ajustes. Verificar que no se hayan visto en clase; no se dispone del temario del semestre. Catálogo: https://docs.flutter.dev/ui/widgets.

## Factor WOW propuesto para entrega final

Mapa con ruta y seguimiento de ubicación en tiempo real compartido con un contacto de confianza durante el trayecto. Punto de entrada: **Elegir destino** e **INICIAR SAFEWALK** en Home. En esta entrega ambas acciones solo muestran alertas; el mapa aún no está implementado.

## Verificación

```bash
flutter analyze
flutter test
```
