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

Estructura:

```text
users/{uid}
  name, email, phone, city, createdAt, updatedAt, primaryContactId
  preferences: { darkMode, notifications, journeyReminders }
  contacts/{contactId}: name, relationship, phone
  destinations/{destinationId}: title, address
  trips/{tripId}: status (lectura; seguimiento pendiente)
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

## Funcionalidades pendientes fuera de este cambio

Selección de foto desde galería, token de notificaciones del dispositivo, recuperación de contraseña, contenido de términos/soporte, mapa/GPS, seguimiento de trayectos y envío real de alertas. La pantalla de trayecto muestra el destino y contacto guardados; no presenta distancias, horas de llegada ni disponibilidad inventadas. El contador de trayectos lee los documentos completados de Firestore y es cero cuando no existen; esta versión aún no crea trayectos.
