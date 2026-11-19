# SafeWalk — Entrega 2

Aplicación Flutter de acompañamiento durante trayectos. Esta versión conecta la información de la cuenta a Cloud Firestore y agrega un CRUD completo de contactos de confianza.

## Configurar Firebase

La app ya contiene la configuración del proyecto `safewalk-fb1e9` para Android e iOS. Para probarla contra el servicio real:

1. En Firebase Console, habilitar Authentication → Email/Password (y Google si se utilizará ese proveedor).
2. Crear la base **Cloud Firestore**, con ID `(default)`, si todavía no existe. Elegir la región del equipo. Usar modo producción.
3. Publicar el contenido de `firestore.rules` en Firestore → Reglas. También se puede ejecutar, desde esta carpeta con Firebase CLI y una cuenta autorizada:

   ```bash
   firebase deploy --only firestore:rules --project safewalk-fb1e9
   ```

4. Ejecutar:

   ```bash
   flutter pub get
   flutter run
   ```

No hay credenciales administrativas ni reglas públicas en el repositorio. La creación de la base y la publicación de reglas requieren acceso al proyecto Firebase; no se realizan al iniciar la app. No se han desplegado desde esta implementación.

Google en Android requiere las huellas SHA de la aplicación registradas en Firebase. La configuración de Firebase para web/escritorio todavía no está implementada.

## Datos y Provider

- `UserProvider`: autenticación por correo/contraseña y Google, registro y cierre de sesión. Al registrar se crea el perfil en Firestore; nunca se guardan contraseñas en la base de datos.
- `AccountRepository`: lectura/escritura de Firestore y transacciones para crear el perfil sin sobrescribir sus datos y para mantener el contacto principal consistente al eliminarlo.
- `AccountProvider`: escucha la sesión y las colecciones del usuario, publica perfil, contactos, destinos, preferencias y número real de trayectos completados. Cancela suscripciones y limpia el estado al cambiar de cuenta o cerrar sesión.
- `AccountGate`: protege las pantallas y muestra carga, errores, reintento o login según corresponda.
- Home, Drawer, Perfil, Ajustes y Trayecto consumen los mismos datos. La edición del nombre en Perfil se refleja en las demás pantallas. El correo es de solo lectura y corresponde a la identidad de Firebase Auth.
- Los perfiles de cuentas de Auth ya existentes se crean al iniciar sesión, usando su nombre, correo y fecha de creación reales. No se precargan contactos ni destinos ficticios.
- Home y Contactos permiten deslizar hacia abajo para recargar desde el servidor. Las actualizaciones también llegan mediante listeners en tiempo real.

Estructura de los datos privados:

```text
users/{uid}
  name, email, phone, city, createdAt, updatedAt, primaryContactId
  preferences: { darkMode, notifications, journeyReminders }
  contacts/{contactId}: name, relationship, phone
  destinations/{destinationId}: title, address
  trips/{tripId}: destination, status, arrived, startedAt, endedAt
```

Las reglas restringen los datos al usuario autenticado dueño de cada ruta y validan los campos que se escriben. No se requieren índices compuestos.

## CRUD de contactos

Desde Home → Contacto de confianza o Drawer → Contactos:

- **Crear:** Agregar → nombre, relación y teléfono → Guardar.
- **Leer:** lista proveniente de Firestore, con estado vacío para cuentas nuevas.
- **Actualizar:** menú de cada contacto → Editar → Guardar.
- **Eliminar:** menú → Eliminar → confirmar. Si era el principal, se borra también esa selección en una transacción.
- **Principal:** tocar la estrella. Home, Ajustes y Trayecto reflejan la selección.

Home permite guardar destinos con nombre y dirección reales. Las preferencias se guardan por usuario; activar el interruptor no implementa aún el envío de notificaciones.

## Verificación

```bash
flutter analyze --no-fatal-infos
flutter test
```

Las pruebas con Firestore/Auth simulados cubren creación y conservación de perfiles, CRUD, selección/eliminación del principal, actualizaciones del proveedor, limpieza de sesión, destinos y estadísticas. No sustituyen la prueba de integración con Firebase ni validan las reglas del servidor.

Prueba manual con Firebase configurado:

1. Registrar una cuenta y verificar `users/{uid}` en la consola.
2. Crear y editar un contacto; elegirlo como principal y comprobarlo en Home/Ajustes.
3. Reiniciar la app: verificar que perfil, preferencias y contactos se conservan.
4. Editar el perfil y comprobar el nombre en Home/Drawer.
5. Agregar un destino y recargar desde Home y Contactos.
6. Eliminar el principal: no debe quedar seleccionado en ninguna pantalla.
7. Iniciar sesión con otra cuenta: no debe mostrar los datos de la anterior.
8. Comprobar en el simulador de reglas de Firebase que una cuenta no puede acceder a `users/{otroUid}` ni sus subcolecciones, y que un usuario sin sesión tampoco puede hacerlo.

## Configuración de rutas y geocodificación

La app compila sin archivos privados. Para usar las rutas se necesita una clave propia de OpenRouteService:

1. Copiar `config.example.json` a `config.local.json` y completar `ORS_API_KEY`.
2. Ejecutar `flutter run --dart-define-from-file=config.local.json`.

`config.local.json` está excluido de Git. Las claves incluidas en una app móvil se pueden extraer de su binario; aplicar las restricciones/cuotas del proveedor. No se incluye una clave de terceros en el repositorio.

Si falta la clave, se muestra un error de configuración al buscar rutas. Las peticiones tienen un tiempo límite de 20 segundos.

## Seguimiento compartido y alertas

La rama `ruben` incluye un visor web en `tracking/` para compartir el trayecto desde la app:

1. Iniciar el trayecto y esperar la ubicación GPS.
2. Tocar **Compartir viaje**, aceptar la explicación y enviar el enlace al contacto.
3. El contacto abre el enlace en el navegador y lo mantiene abierto. Puede activar el sonido de alertas.
4. Cada nueva lectura GPS (10 metros, con un máximo de una subida cada 5 segundos) actualiza el mismo documento; el visor lo escucha en tiempo real. Si no hay datos nuevos, muestra la antigüedad de la última posición.
5. Al detectar un desvío, la app presenta una cuenta regresiva real de 20 segundos. **Sí, estoy bien** la cancela; **Necesito ayuda** o el vencimiento publican una alerta en el enlace, además de ofrecer SMS/llamada manual.
6. **Detener ubicación compartida** revoca el enlace. Finalizar o salir del trayecto detiene las actualizaciones y bloquea la lectura de la sesión terminada. Cada enlace caduca en un máximo de 4 horas.

El enlace es una credencial temporal: cualquier persona que lo reciba puede leer la ubicación mientras esté activo. Usa un identificador aleatorio de 256 bits en el fragmento de la URL. No permite listar sesiones ni contiene teléfono, correo o nombre del contacto. Las colecciones privadas `users/{uid}` siguen restringidas a su propietario.

### Publicar el visor

Se preparó la configuración; **no se han desplegado los cambios**. Antes de probar el enlace en otro teléfono:

1. Habilitar Firebase Hosting estático en el proyecto `safewalk-fb1e9`. No requiere App Hosting ni Cloud Functions.
2. Si el proyecto no tiene una app Web, registrarla en Configuración del proyecto; el visor usa `/__/firebase/init.json`, provisto por Hosting.
3. Con Firebase CLI y una cuenta autorizada, desde esta carpeta:

   ```bash
   firebase deploy --only firestore:rules,hosting --project safewalk-fb1e9
   ```

4. Comprobar `https://safewalk-fb1e9.web.app/track`. Sin fragmento debe indicar que el enlace no es válido.
5. Si se usa otro dominio, ajustar `TRACKING_BASE_URL` en `config.local.json` y reconstruir la app.

El visor usa Firestore `onSnapshot` y los SDK oficiales de Firebase. La solución utiliza servicios con cuotas gratuitas de Spark. La lectura de ubicaciones mediante enlaces es una ampliación explícita del acceso: revisar las nuevas reglas antes de publicarlas.

### Recordatorios y alcance

**Recordatorios** ahora activa un aviso dentro de la app cada 10 minutos durante el trayecto. Su acción **Avisar** abre un SMS para confirmar al contacto que sigues en camino. Se cancela al desactivar la preferencia o terminar/salir del trayecto. El SMS requiere confirmación en la app del teléfono.

Esta implementación funciona con el trayecto abierto y el visor del contacto abierto. No garantiza ejecución con la app cerrada o suspendida, ni envía SMS/push automáticamente en segundo plano. El código FCM existente permite recibir notificaciones, pero enviar push desde un servidor es una integración distinta. Ningún mensaje de ayuda se envía automáticamente al número de teléfono: la alerta automática se publica en el enlace que el usuario decidió compartir.

Prueba de integración pendiente de credenciales y despliegue: usar dos dispositivos, compartir el enlace, caminar, comprobar cambios, simular un desvío y esperar los 20 segundos, responder antes del vencimiento en otra prueba, revocar el enlace, finalizar el trayecto y comprobar que ya no puede leerse. Probar también permisos denegados, pérdida de conexión y caducidad.
