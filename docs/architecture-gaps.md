# Arquitectura Flutter: qué falta cerrar para que el código coincida con los diagramas

Los diagramas de Lucid (documento "Juggle – Flutter Architecture (Sprint 2)") muestran la arquitectura **final**: MVVM, Repository, Singleton y Strategy. Este archivo lista lo que todavía no está en el código (estado verificado sobre `develop`, 2 de octubre de 2026) y qué hay que hacer para cerrarlo.

Leyenda: **Prioridad** A = el patrón no se sostiene sin esto, B = mejora clara, C = opcional. **Esfuerzo** S = menos de 1 h, M = 1-3 h, L = más de 3 h.

## Resumen

| Patrón | Estado hoy | Para el diagrama final |
|---|---|---|
| MVVM | Sólido: un `AsyncNotifier` + `*State` por feature | 2 ajustes menores |
| Repository | Hecho en la rama `refactor/repositories`: un repositorio por agregado | R3 y R6 creados pero sin conectar a pantallas; R7 opcional |
| Singleton | Cubierto con providers de Riverpod | Solo documentar el matiz |
| Strategy | Solo en el calendario, con 1 estrategia | 3 pendientes (3 de prioridad A) |

## Repository

Estado en la rama `refactor/repositories` (sin commit): existen `TaskRepository`, `GroupRepository`, `ProjectRepository`, `UserRepository`, `AuthRepository`, `NotificationsRepository`, `SettingsRepository` y `TelemetryRepository`. Pruebas en `test/data/repositories/`.

Nota PR #32: `ProjectRepository` y los modelos de proyecto se copiaron tal cual del PR #32 y se le añadieron `getProject`, `getGroupProjects`, `updateProject` y `deleteProject`; habrá un conflicto menor en `project_repository.dart` al fusionar (conservar la versión con más métodos).

| # | Pendiente | Archivos | Prio | Esf. |
|---|---|---|---|---|
| R1 | **HECHO.** **Separar `GroupRepository` de `TaskRepository`.** Hoy `TaskRepository` mezcla tareas, grupos (`getTaskGroups`, `addGroup`) y proyectos (`getProjects`, `projectNameFor` con un mapa interno `_projectIds` como caché). Un repositorio por agregado, como en Kotlin (`TaskRepository`, `GroupRepository`, `UserRepository`) | `data/repositories/tasks/task_repository.dart`, nuevo `data/repositories/groups/` y su provider; actualizar los view models de Tasks, Create/Edit task y el drawer | A | M |
| R2 | **HECHO.** **Usar un único `ProjectRepository`** (el del PR #32) y quitar `getProjects`/`projectNameFor` de `TaskRepository` (los usan Create/Edit task) | `task_repository.dart`, `create_task_viewmodel.dart`, `edit_task_viewmodel.dart`, PR #32 | A | M |
| R3 | **HECHO (repositorio listo; `currentUserProvider` sigue usando el nombre de Firebase porque `/users/create_user` aún no ha terminado cuando Firebase emite el usuario al registrarse; conectarlo requiere resolver esa carrera).** **`UserRepository`**: con el PR #35, `currentUserProvider` ya no consulta `/users/current_user` y arma el usuario con el nombre de Firebase (Home saludaba "Hi Demo!" y ahora "Hi Grupo!"). El nombre debe venir del backend, la fuente de verdad | nuevo `data/repositories/users/`, `ui/auth/providers/auth_providers.dart` | B | M |
| R4 | **HECHO.** **`NotificationsRepository` real.** Hoy es una lista fija con `Future.delayed`; el Backend ya expone `GET /notifications` | `data/repositories/profile/notifications_repository.dart` | B | M |
| R5 | **HECHO (sonido/vibración en el backend vía `/users/preferences` = `push_enabled`; el tema ya no se elige: la app sigue el del sistema, así que no se usa `shared_preferences`).** **`SettingsRepository` persistente.** Hoy guarda en memoria (se pierde al cerrar la app). Requiere **agregar la dependencia `shared_preferences`** (no está en `pubspec.yaml`) | `data/repositories/profile/settings_repository.dart`, `pubspec.yaml` | B | S |
| R6 | **HECHO (repositorio listo; falta medir el tiempo de carga en los view models y llamarlo).** **`TelemetryRepository`** para la BQ de tiempo de carga de pantallas. El Backend ya tiene `POST /telemetry/screen-load` y `GET /analytics/screen-load-time`; en Flutter no hay nada (ni medición ni repositorio) | nuevo repo + medición en los view models principales | B | L |
| R7 | Interfaces abstractas por repositorio (para pruebas con fakes). Kotlin tampoco las usa | todos los `*_repository.dart` | C | M |

## Strategy

Hoy: `ScheduleStrategy<T>` (interfaz) + `DayScheduleStrategy` en `ui/calendar/strategies/`. Solo una estrategia concreta, y el view model depende de la clase concreta.

| # | Pendiente | Archivos | Prio | Esf. |
|---|---|---|---|---|
| S1 | **El view model debe depender de la abstracción.** `CalendarViewModel` declara `final DayScheduleStrategy _scheduleStrategy = DayScheduleStrategy();` → tipar como `ScheduleStrategy<Task>` (idealmente inyectada) | `ui/calendar/view_models/calendar_view_model.dart` | A | S |
| S2 | **Segunda estrategia: `WeekScheduleStrategy`.** Con una sola implementación el patrón no se justifica. El calendario ya navega por semanas (`previousWeek`/`nextWeek`), así que la vista semanal es el caso natural | `ui/calendar/strategies/` | A | M |
| S3 | **`TaskFilterStrategy` en All tasks.** `AllTasksViewModel._load` hace un `switch (filter)` con 3 ramas (`urgent`, `dueSoon`, `assignedToMe`) que llaman a `getAllTasks` con distintos parámetros → una estrategia por filtro | `ui/tasks/all_tasks/view_models/all_tasks_viewmodel.dart` | A | M |
| S4 | **Filtros de estado del detalle de proyecto** (All / Pending / Completed): hoy un `switch` sobre un `String` en el widget (PR #32) → reutilizar una estrategia de filtro por estado compartida con S3 | PR #32 `project_detail_screen.dart` | B | S |
| S5 | `TasksState._sorted` (orden por deadline, prioridad e id) → `TaskSortStrategy`. Opcional: no forzar el patrón si no aporta | `ui/tasks/tasks/view_models/tasks_viewmodel.dart` | C | S |
| S6 | **Pruebas unitarias de las estrategias** (son funciones puras, fáciles). Sirven de "Example" en la tabla de la Wiki | `test/` | B | S |

## MVVM

| # | Pendiente | Archivos | Prio | Esf. |
|---|---|---|---|---|
| M1 | El filtro seleccionado del detalle de proyecto vive en el `State` del widget → moverlo al view model (PR #32). El resto de pantallas usa `setState` solo para estado puramente visual (pestaña de Home, FAB expandido), lo cual es aceptable | PR #32 `project_detail_screen.dart` | B | S |
| M2 | `ref.mounted` tras cada `await` y `AsyncValue.guard` donde falte (`AuthViewModel` y `HomeViewModel` no se tocaron en la revisión del #27) | `ui/auth/view_models/auth_viewmodel.dart`, `ui/home/view_models/home_viewmodel.dart` | C | S |
| M3 | Formato de fechas hecho a mano en pantallas nuevas (`'${d.day}/${d.month}/${d.year}'`) → usar `deadlineDate` de `ui/core/utils/deadline_format.dart` | PR #32 (create/detail) | C | S |

## Singleton

Cubierto: `dioProvider`, `firebaseAuthProvider`, `googleSignInProvider` y un `*RepositoryProvider` por repositorio, bajo **un único** `ProviderScope` (`lib/main.dart`). Solo falta documentar bien el matiz en la Wiki:

- Es un **Singleton de ámbito**: una instancia por `ProviderScope` (toda la app), con un punto de entrada único (el provider). No es el patrón clásico con constructor privado.
- `FirebaseAuth.instance` y `GoogleSignIn.instance` sí son singletons reales de sus librerías.
- `dioProvider` crea un solo `Dio` con el `UserTokenInterceptor` (equivale al `AuthInterceptor` de Kotlin).
- Opcional (C): `ui/core/app/service_locator.dart` mezcla `setupDependencies()` (inicializa Firebase y dotenv) con providers; separar mejora la claridad.

## Orden sugerido

1. **S1 + S2 + S3** (juntos): dejan Strategy bien justificado con dos usos distintos.
2. **R1 + R2** (con el merge del PR #32): dejan Repository limpio por agregado.
3. **S6** (pruebas) y capturas de código para la columna *Example* de la Wiki.
4. **R3, R4, R5, R6** según prioridad del sprint.

## Wiki (pendiente aparte, sin editar todavía)

Las 4 secciones de **Flutter Architecture** en `Sprint2` están vacías: Overall Structure, Component Interaction, Design Patterns and Architectural Tactics (la tabla Flutter no tiene la columna *Example* que sí tiene la de Kotlin) y Architecture Implementation.
