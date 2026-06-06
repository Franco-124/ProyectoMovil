# Implementation Plan: Transaction Scan

## Tasks

- [x] **Task 1**: Eliminar `invoice_scan_result.dart` — `lib/models/invoice_scan_result.dart`
- [x] **Task 2**: Eliminar `transaction_from_scan_request.dart` — `lib/models/finance/transaction_from_scan_request.dart`
- [x] **Task 3**: Eliminar `invoice_scan_service.dart` — `lib/features/invoices/data/services/invoice_scan_service.dart`
- [x] **Task 4**: Agregar `scanFields` a `CategoryModel` — `lib/models/finance/category_model.dart`
- [x] **Task 5**: Agregar `extraData` a `TransactionModel` — `lib/models/finance/transaction_model.dart`
- [x] **Task 6**: Crear `TransactionScanResult` — `lib/models/finance/transaction_scan_result.dart`
- [x] **Task 7**: Crear `TransactionScanService` — `lib/features/finance/data/services/transaction_scan_service.dart`
- [x] **Task 8**: Actualizar `FinanceRepository` — `lib/features/finance/data/repositories/finance_repository.dart`
- [x] **Task 9**: Actualizar `finance_provider.dart` — `lib/features/finance/presentation/providers/finance_provider.dart`
- [x] **Task 10**: Limpiar `invoice_provider.dart` — `lib/features/invoices/presentation/providers/invoice_provider.dart`
- [x] **Task 11**: Limpiar `create_invoice_screen.dart` — `lib/features/invoices/presentation/screens/create_invoice_screen.dart`
- [x] **Task 12**: Integrar scan en `create_transaction_screen.dart` — `lib/features/finance/presentation/screens/create_transaction_screen.dart`
- [x] **Task 13**: Actualizar `transaction_tile.dart` — `lib/features/finance/presentation/widgets/transaction_tile.dart`

## Execution Log

### Task 1-3 — Eliminar archivos obsoletos
Status: ✅ Done
Notes: Eliminados los 3 archivos cuyos endpoints fueron removidos del backend.

### Task 4 — CategoryModel: scanFields
Status: ✅ Done
Notes: Campo `List<String>? scanFields` agregado con `fromJson` y `copyWith`.

### Task 5 — TransactionModel: extraData
Status: ✅ Done
Notes: Campo `Map<String, dynamic>? extraData` agregado con `fromJson` y `copyWith`.

### Task 6 — Crear TransactionScanResult
Status: ✅ Done
Notes: Modelo con `hasUsableData` y `confidenceLabel`. Sin dependencia de `dart:io`.

### Task 7 — Crear TransactionScanService
Status: ✅ Done
Notes: Usa `XFile.readAsBytes()` para compatibilidad web/móvil. POST multipart con timeout 60s.

### Task 8 — Actualizar FinanceRepository
Status: ✅ Done
Notes: Eliminado `createTransactionFromScan`. Agregado `extraData` opcional a `createTransaction`.

### Task 9 — Actualizar finance_provider.dart
Status: ✅ Done
Notes: Agregado `transactionScanServiceProvider`. Propagado `extraData` en `TransactionNotifier.createTransaction`.

### Task 10 — Limpiar invoice_provider.dart
Status: ✅ Done
Notes: Eliminados `invoiceScanServiceProvider`, `invoiceScanProvider`, `InvoiceScanNotifier`.

### Task 11 — Limpiar create_invoice_screen.dart
Status: ✅ Done
Notes: Reescrito sin nada de scan. Eliminados ~300 líneas de código muerto.

### Task 12 — Integrar scan en create_transaction_screen.dart
Status: ✅ Done
Notes: Botón scan aparece solo si hay categoría seleccionada. Pre-llena campos del formulario. Banner de confianza según nivel. Campos extras dinámicos por categoría. Moneda fija en COP.

### Task 13 — Actualizar transaction_tile.dart
Status: ✅ Done
Notes: `_subtitleText()` muestra primer valor de extraData → description → fecha. Eliminada variable `formattedDate` no usada.
