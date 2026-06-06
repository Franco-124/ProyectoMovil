# PayRemind
 
Aplicación móvil para freelancers que automatiza el cobro de facturas mediante recordatorios por correo electrónico. Permite emitir facturas, hacer seguimiento de clientes, visualizar el estado financiero mensual y auditar todos los correos enviados.
 
---
 
## Tabla de contenidos
 
- [Características](#características)
- [Arquitectura](#arquitectura)
- [Stack tecnológico](#stack-tecnológico)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Configuración y variables de entorno](#configuración-y-variables-de-entorno)
- [Instalación y ejecución](#instalación-y-ejecución)
- [Navegación y rutas](#navegación-y-rutas)
- [Módulos principales](#módulos-principales)
 
---
 
## Características
 
| Módulo | Funcionalidad |
|---|---|
| **Autenticación** | Registro, login y logout con JWT almacenado de forma segura |
| **Dashboard** | Resumen de facturas pendientes/vencidas y actividad reciente |
| **Facturas** | Emisión con ítems, moneda, fecha de vencimiento y envío automático de email |
| **Clientes** | Gestión del directorio de clientes destinatarios |
| **Finanzas** | Dashboard mensual con ingresos, gastos, balance, presupuestos y categorías |
| **Transacciones** | Registro manual o mediante escaneo de recibos con IA |
| **Correos** | Historial de todos los recordatorios enviados, con estado y contenido completo |
| **Ajustes** | Configuración general de la cuenta |
 
### Highlights
 
- **Recordatorios automáticos**: al emitir una factura, el backend envía el email al cliente de forma inmediata.
- **Escaneo de recibos con IA**: sube una foto del recibo y el sistema extrae automáticamente el monto, descripción y categoría.
- **Dashboard financiero mensual**: navega mes a mes para ver ingresos vs. gastos, balance, progreso de presupuestos por categoría y últimas transacciones.
- **Plan gratuito con límite**: la app maneja el error `free_plan_limit_reached` del backend y muestra un mensaje claro al usuario.
- **Tema oscuro nativo**: interfaz diseñada exclusivamente en dark mode con paleta definida en `AppColors`.
 
---
 
## Arquitectura
 
La app sigue una arquitectura **feature-first** con separación por capas dentro de cada feature:
 
```
feature/
  data/
    models/       ← DTOs con freezed + json_serializable
    repositories/ ← acceso a la API vía Dio
    services/     ← lógica de negocio de datos (ej. scan de recibos)
  presentation/
    providers/    ← estado con Riverpod
    screens/      ← pantallas
    widgets/      ← widgets locales al feature
```
 
El estado global de autenticación (`authStateListenable`) actúa como `refreshListenable` del router, de modo que cualquier cambio de sesión (login/logout) redirige automáticamente sin intervención manual.
 
---
 
## Stack tecnológico
 
| Categoría | Librería | Versión |
|---|---|---|
| UI | Flutter | SDK ^3.11.5 |
| State management | flutter_riverpod | ^2.5.1 |
| Generación de providers | riverpod_generator | ^2.3.9 |
| HTTP | dio | ^5.4.3 |
| Navegación | go_router | ^14.2.0 |
| Almacenamiento seguro (JWT) | flutter_secure_storage | ^9.0.0 |
| Modelos inmutables | freezed | ^2.4.7 |
| Serialización JSON | json_serializable | ^6.7.1 |
| Fechas y monedas | intl | ^0.19.0 |
| Variables de entorno | flutter_dotenv | ^5.1.0 |
| Selector de imágenes | image_picker | ^1.1.2 |
| Apertura de archivos | open_file | ^3.3.2 |
 
---
 
## Estructura del proyecto
 
```
lib/
├── main.dart                        ← entry point, carga .env y monta ProviderScope
├── app.dart                         ← GoRouter + PayRemindApp (MaterialApp.router)
├── core/
│   ├── network/
│   │   ├── api_client.dart          ← singleton Dio con baseUrl desde .env
│   │   ├── auth_interceptor.dart    ← inyecta JWT en cada request
│   │   └── error_handler.dart      ← mapea errores de red a mensajes amigables
│   ├── storage/
│   │   └── secure_storage.dart     ← wrapper de flutter_secure_storage
│   └── theme/
│       ├── app_colors.dart         ← paleta de colores centralizada
│       └── app_theme.dart          ← ThemeData dark
├── shared/
│   ├── theme/app_theme.dart
│   └── widgets/
│       ├── bottom_nav.dart         ← shell con bottom navigation bar
│       ├── stat_card.dart
│       └── status_badge.dart       ← badge de estado de factura (pending/overdue/paid)
├── models/
│   └── finance/                    ← modelos compartidos del módulo finanzas
│       ├── budget_model.dart
│       ├── category_model.dart
│       ├── dashboard_model.dart
│       ├── transaction_model.dart
│       └── transaction_scan_result.dart
└── features/
    ├── auth/
    ├── clients/
    ├── dashboard/
    ├── emails/
    ├── finance/
    ├── invoices/
    └── settings/
```
 
---
 
## Configuración y variables de entorno
 
El proyecto usa `flutter_dotenv`. El archivo de entorno debe ubicarse en:
 
```
assets/env
```
 
Y declararse en `pubspec.yaml` (ya incluido):
 
```yaml
flutter:
  assets:
    - assets/env
```
 
Ejemplo de contenido del archivo `assets/env`:
 
```env
API_BASE_URL=https://api.tudominio.com
```
 
> **Importante**: no subas el archivo `assets/env` al repositorio. Agrégalo a `.gitignore`.
 
---
 
## Instalación y ejecución
 
**Requisitos previos**
- Flutter SDK >= 3.11.5
- Dart >= 3.x
- Android Studio o Xcode para correr en dispositivo/emulador
 
```bash
# 1. Instalar dependencias
flutter pub get
 
# 2. Generar código (freezed, json_serializable, riverpod)
dart run build_runner build --delete-conflicting-outputs
 
# 3. Crear el archivo de entorno
cp assets/env.example assets/env   # ajusta las variables
 
# 4. Correr la app
flutter run
```
 
Para regenerar código en modo watch durante el desarrollo:
 
```bash
dart run build_runner watch --delete-conflicting-outputs
```
 
---
 
## Navegación y rutas
 
El router está definido en `lib/app.dart` con GoRouter. Las rutas protegidas se manejan via `redirect` basado en `authStateListenable`.
 
```
/auth/login
/auth/register
 
(shell con BottomNav)
  /dashboard
  /invoices
  /invoices/emit
  /invoices/:id
  /clients
  /emails
  /finance
  /finance/transactions
  /finance/transactions/create
  /finance/budgets
  /settings
```
 
Si el usuario no está autenticado, cualquier ruta no-auth redirige a `/auth/login`. Si ya está autenticado e intenta entrar a una ruta de auth, redirige a `/dashboard`.
 
---
 
## Módulos principales
 
### Autenticación (`features/auth`)
 
- Login y registro con email/contraseña.
- El JWT recibido se persiste en `flutter_secure_storage`.
- `AuthInterceptor` lo inyecta automáticamente en el header `Authorization: Bearer ...` de cada request.
- El logout limpia el token y el router redirige sin intervención manual.
 
### Facturas (`features/invoices`)
 
- **Lista**: todas las facturas del usuario con estado (pending / overdue / paid).
- **Emisión** (`/invoices/emit`): formulario con selección de cliente, ítems (descripción, cantidad, precio unitario), moneda (COP/USD), fecha de vencimiento y notas opcionales. Al confirmar, el backend genera y envía el email al cliente.
- **Detalle** (`/invoices/:id`): vista completa de una factura individual.
 
### Módulo Finanzas (`features/finance`)
 
#### Dashboard financiero
Muestra para el mes seleccionado:
- Total de ingresos y gastos
- Balance del mes (verde si positivo, rojo si negativo)
- Progreso de presupuestos por categoría
- Gastos desglosados por categoría con barra de progreso porcentual
- Últimas transacciones
 
La navegación mes a mes se hace con flechas (← →) sin llamadas adicionales al backend hasta cambiar de período.
 
#### Transacciones
- Lista completa con filtro por período.
- Creación manual con monto, descripción, categoría, tipo (ingreso/gasto) y fecha.
- **Escaneo de recibos con IA**: sube una imagen desde la cámara o galería. El servicio `TransactionScanService` hace un POST multipart a `/finance/transactions/scan` con la imagen y la categoría. El backend devuelve el resultado pre-completado que el usuario puede confirmar o editar.
 
#### Presupuestos
Seguimiento visual del gasto vs. presupuesto por categoría. Las barras cambian de color según el porcentaje usado: verde (<80%), amarillo (80-99%), rojo (≥100% — excedido).
 
### Correos (`features/emails`)
 
Historial de todos los emails de recordatorio enviados. Cada registro muestra:
- Destinatario y factura asociada
- Días de retraso y tono del recordatorio
- Estado: `sent` / `opened` / `failed`
- Fecha y hora de envío
- Acceso al cuerpo completo del email mediante un diálogo
 
### Clientes (`features/clients`)
 
CRUD de clientes. Cada cliente tiene nombre y email. Son el destinatario de las facturas y los recordatorios.
