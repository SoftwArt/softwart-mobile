# SoftwArt — Mobile

> 🌐 Also available in [English](./README.md)

App Android complementaria para **Arte Café**, una marquetería PYME en Medellín, Colombia. Diseñada como herramienta de acceso rápido para la dueña y empleados — el panel web maneja todas las operaciones CRUD, pero la app móvil les da visibilidad inmediata del negocio desde el celular sin necesidad de abrir un navegador.

🌐 **Plataforma web:** [softwart.online](https://softwart.online)

---

## Qué hace

| Módulo | Acciones disponibles |
|---|---|
| Auth | Login, logout |
| Dashboard | KPIs: ventas del mes, citas de hoy, servicios pendientes, pagos pendientes |
| Citas | Listar, buscar, filtrar por estado, ver detalle, cambiar estado |
| Servicios | Listar, buscar, filtrar por estado, ver detalle, cambiar estado |
| Ventas | Listar, buscar, filtrar por estado, ver detalle, ver plan de abonos |
| Pagos | Listar, buscar, filtrar por estado, ver detalle, cambiar estado |
| Clientes | Listar, buscar, ver detalle (solo consulta) |

---

## Stack

- **Flutter + Dart**
- **Provider** — manejo de estado (ChangeNotifier)
- **http** — consumo de API REST
- **shared_preferences** — persistencia del token JWT + alertas del dashboard ignoradas
- **firebase_core** + **firebase_messaging** — notificaciones push (FCM)

---

## Arquitectura — Clean Architecture (modular)

```
lib/
├── core/
│   ├── constants/     — BASE_URL y todos los endpoints
│   ├── errors/        — excepciones custom
│   ├── services/      — push_notification_service (FCM, topic staff)
│   ├── theme/         — AppColors
│   └── utils/         — token storage, formatters, alert prefs
├── data/
│   ├── datasources/   — uno por dominio (auth, citas, ventas, pagos...)
│   ├── models/        — deserialización JSON
│   └── repositories/  — implementaciones de los contratos
├── domain/
│   ├── entities/      — objetos de negocio puros
│   ├── repositories/  — interfaces (contratos)
│   └── usecases/      — una acción por clase, expuesta vía call()
└── presentation/
    ├── providers/     — ChangeNotifier por módulo
    ├── pages/         — widgets de pantalla completa
    └── widgets/       — componentes UI compartidos
```

El flujo de datos es estrictamente unidireccional:

```
Page → Provider → UseCase → Repository (interface)
                                    ↓
                         RepositoryImpl → DataSource → http
```

### ¿Por qué Clean Architecture para una app complementaria?

El alcance de la app es lectura + cambios de estado, pero la lógica de dominio (planes de abonos, estados de cita, validación de pagos) vive en el mismo backend que el panel web. Clean Architecture permite agregar nuevos casos de uso sin tocar el código de presentación — cada capa tiene una sola razón para cambiar.

---

## Navegación

- `MainShell` con `Drawer` lateral + `IndexedStack` de 6 tabs: Dashboard → Citas → Servicios → Ventas → Pagos → Clientes
- Páginas de detalle usan `MaterialPageRoute` (rutas nombradas solo para `/login` y `/home`)
- `UserMenuButton` en el AppBar: muestra la inicial del usuario — tap revela nombre, correo y cerrar sesión

---

## Sistema de diseño

```dart
primary:     Color(0xFF8B5A3C)  // sienna
secondary:   Color(0xFF2D4A47)  // dark teal
accent:      Color(0xFFD4B896)  // warm tan
background:  Color(0xFFFAFAFA)
```

Los cambios de estado usan chips con `AnimatedContainer` — seleccionado: fondo `primary` con texto blanco; no seleccionado: fondo blanco con borde.

---

## Splash screen

Al iniciar, el splash lanza un ping silencioso a `/services` (ruta pública) para despertar el servidor de Render (el free tier hiberna tras inactividad) antes de que el usuario llegue al login. Luego valida el token y redirige a `/home` o `/login` según corresponda.

---

## Notificaciones push (FCM)

La app se suscribe al **topic `staff`** al iniciar sesión un Admin/Empleado (sin guardar tokens por dispositivo) y se desuscribe al cerrar sesión. Cuando se agenda una cita nueva, el backend hace push al topic: con la app en background/cerrada Android muestra la notificación sola, y en primer plano la app muestra un `SnackBar` y refresca las listas afectadas en vivo. Requiere `android/app/google-services.json` (gitignored).

---

## Actualización en vivo y estados terminales

- Las listas se recargan al navegar entre tabs y al llegar un push; todas ordenadas de más nuevo a más viejo
- Silent refresh: las recargas en segundo plano no muestran loader y conservan la lista si fallan
- Estados terminales con paridad web: `Cancelado` (servicio) pide confirmación y luego se bloquea; `Validado` / `Anulado` (pago) no se pueden modificar — respaldado por los guards 409 del backend

---

## Generar el APK

```bash
cd mobile-softwart
flutter pub get
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk (~49 MB)
```

La BASE_URL apunta a producción por defecto. Para apuntar el build a otra API sin tocar código:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://otra-api/api
```

---

## Repositorios relacionados

- [softwart-backend](https://github.com/SoftwArt/softwart-backend) — Node.js + Express + TypeScript + PostgreSQL
- [softwart-frontend](https://github.com/SoftwArt/softwart-frontend) — React + TypeScript + Vite + Tailwind
- [softwart-docs](https://github.com/SoftwArt/softwart-docs) — Diagramas C4, MHU, documentación del proyecto

---

## Contexto académico

Proyecto de grado — Tecnología en Análisis y Desarrollo de Software, SENA (Medellín, Colombia).
Desarrollado por **Sergio E. León V.**

---

## Herramientas de desarrollo

Desarrollado con AI-assisted development usando [Claude](https://claude.ai) y [Claude Code](https://claude.ai/code) de Anthropic.
