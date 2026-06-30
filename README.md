# SoftwArt — Mobile

> 🇨🇴 También disponible en [español](./README.es.md)

Android companion app for **Arte Café**, a framing and marquetry shop in Medellín, Colombia. Built as a quick-access tool for the owner and employees — the full web panel handles all CRUD operations, but the mobile app gives them instant visibility into the business from their phone without having to open a browser.

🌐 **Web platform:** [softwart.online](https://softwart.online)

---

## What it does

| Module | Available actions |
|---|---|
| Auth | Login, logout |
| Dashboard | KPIs: monthly sales, today's appointments, pending orders, pending payments |
| Appointments | List, search, filter by status, view detail, change status |
| Services | List, search, filter by status, view detail, change status |
| Sales | List, search, filter by status, view detail, view installment plan |
| Payments | List, search, filter by status, view detail, change status |
| Clients | List, search, view detail (read-only) |

---

## Tech stack

- **Flutter + Dart**
- **Provider** — state management (ChangeNotifier)
- **http** — REST API consumption
- **shared_preferences** — JWT token persistence + dismissed dashboard alerts
- **firebase_core** + **firebase_messaging** — push notifications (FCM)

---

## Architecture — Clean Architecture (modular)

```
lib/
├── core/
│   ├── constants/     — API base URL and all endpoints
│   ├── errors/        — custom exceptions
│   ├── services/      — push_notification_service (FCM, staff topic)
│   ├── theme/         — AppColors
│   └── utils/         — token storage, formatters, alert prefs
├── data/
│   ├── datasources/   — one per domain (auth, citas, ventas, pagos...)
│   ├── models/        — JSON deserialization
│   └── repositories/  — interface implementations
├── domain/
│   ├── entities/      — pure business objects
│   ├── repositories/  — contracts (interfaces)
│   └── usecases/      — one action per class, exposed via call()
└── presentation/
    ├── providers/     — ChangeNotifier per module
    ├── pages/         — screen-level widgets
    └── widgets/       — shared UI components
```

Data flows strictly in one direction:

```
Page → Provider → UseCase → Repository interface
                                    ↓
                         RepositoryImpl → DataSource → http
```

### Why Clean Architecture for a mobile companion app?

The app scope is read + status changes, but the domain logic (installment plans, appointment states, payment validation) lives in the same backend as the web panel. Clean Architecture makes it straightforward to add new use cases without touching presentation code — each layer has a single reason to change.

---

## Navigation

- `MainShell` with lateral `Drawer` + `IndexedStack` of 6 tabs: Dashboard → Appointments → Services → Sales → Payments → Clients
- Detail pages use `MaterialPageRoute` (named routes only for `/login` and `/home`)
- `UserMenuButton` in AppBar: shows user initial — tap reveals name, email, and logout

---

## Design system

```dart
primary:     Color(0xFF8B5A3C)  // sienna
secondary:   Color(0xFF2D4A47)  // dark teal
accent:      Color(0xFFD4B896)  // warm tan
background:  Color(0xFFFAFAFA)
```

Status changes use animated `AnimatedContainer` chips — selected state uses `primary` fill with white text, unselected uses white fill with border.

---

## Splash screen

On launch, the splash screen sends a silent warmup ping to `/services` (public route) to wake the Render server (free tier hibernates after inactivity) before the user reaches the login screen. It then validates the token — redirects to `/home` or `/login` accordingly.

---

## Push notifications (FCM)

The app subscribes to the **`staff` topic** on Admin/Employee login (no per-device tokens stored) and unsubscribes on logout. When a new appointment is booked, the backend pushes to the topic: Android shows the notification when the app is backgrounded/closed, and in the foreground the app shows a `SnackBar` and refreshes the affected lists live. Requires `android/app/google-services.json` (gitignored).

---

## Live updates & terminal states

- Lists refresh on tab navigation and on incoming push; every list is sorted newest-first
- Silent refresh: background reloads don't flash a loader and keep the current list if they fail
- Terminal states mirror the web: `Cancelado` (service) asks for confirmation then locks; `Validado` / `Anulado` (payment) cannot be changed — backed by the backend's 409 guards

---

## Building the APK

```bash
cd mobile-softwart
flutter pub get
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk (~49 MB)
```

The base URL defaults to production. To point the build at another API without touching code:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://other-api/api
```

---

## Related repositories

- [softwart-backend](https://github.com/SoftwArt/softwart-backend) — Node.js + Express + TypeScript + PostgreSQL
- [softwart-frontend](https://github.com/SoftwArt/softwart-frontend) — React + TypeScript + Vite + Tailwind
- [softwart-docs](https://github.com/SoftwArt/softwart-docs) — C4 diagrams, MHU, project documentation

---

## Academic context

Capstone project — Technology in Software Analysis and Development, SENA (Medellín, Colombia).
Built by **Sergio E. León V.**

---

## Development tools

Built with AI-assisted development using [Claude](https://claude.ai) and [Claude Code](https://claude.ai/code) by Anthropic.
