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
- **shared_preferences** — persistencia del token JWT

---

## Arquitectura — Clean Architecture (modular)

```
lib/
├── core/
│   ├── constants/     — BASE_URL y todos los endpoints
│   ├── errors/        — excepciones custom
│   ├── theme/         — AppColors
│   └── utils/         — token storage, formatters
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

Al iniciar, el splash lanza un ping silencioso a `/api/dashboard` para despertar el servidor de Render (el free tier hiberna tras inactividad) antes de que el usuario llegue al login. La validación del token corre en paralelo y redirige a `/home` o `/login` según corresponda.

---

## Generar el APK

```bash
cd mobile-softwart
flutter pub get
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk (~49 MB)
```

La URL de producción está configurada en `core/constants/api_constants.dart`. No se requiere configuración adicional para el build de release.

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
