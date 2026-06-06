# Design: Transaction Scan

## Overview
Eliminamos el flujo de scan del módulo de facturas (modelos, servicio, providers y código
de UI en `CreateInvoiceScreen`). Creamos un `TransactionScanService` y un modelo
`TransactionScanResult` dentro del feature de finanzas. Integramos el scan como opción
opcional en la pantalla `CreateTransactionScreen` existente, sin reescribirla. Actualizamos
los modelos `CategoryModel` y `TransactionModel` con campos nuevos del backend.

---

## Components

### Archivos a eliminar

| Archivo | Razón |
|---|---|
| `lib/models/invoice_scan_result.dart` | Modelo de endpoint eliminado |
| `lib/models/finance/transaction_from_scan_request.dart` | Endpoint eliminado |
| `lib/features/invoices/data/services/invoice_scan_service.dart` | Servicio de endpoint eliminado |

### Archivos a modificar

| Archivo | Cambio |
|---|---|
| `lib/features/invoices/presentation/providers/invoice_provider.dart` | Eliminar `invoiceScanServiceProvider`, `invoiceScanProvider`, `InvoiceScanNotifier` e imports relacionados |
| `lib/features/invoices/presentation/screens/create_invoice_screen.dart` | Eliminar todo el código de scan: botón AppBar, `_scanResult`, `_scannedFields`, `_handleScanTap`, `_selectImageSource`, `_scanImage`, `_applyScannedData`, `_parseDioError`, `_wasScanned`, banners de scan, botón "Registrar como transacción", clase `_ScanToTransactionSheet`, imports de scan/finanzas |
| `lib/features/finance/data/repositories/finance_repository.dart` | Eliminar `createTransactionFromScan`, agregar `extraData` a `createTransaction` |
| `lib/features/finance/presentation/providers/finance_provider.dart` | Agregar `extraData` a `TransactionNotifier.createTransaction`, agregar `transactionScanServiceProvider` |
| `lib/models/finance/category_model.dart` | Agregar campo `scanFields` |
| `lib/models/finance/transaction_model.dart` | Agregar campo `extraData` |
| `lib/features/finance/presentation/screens/create_transaction_screen.dart` | Agregar modo scan, campos extra dinámicos, ocultar selector de moneda |
| `lib/features/finance/presentation/widgets/transaction_tile.dart` | Mostrar primer campo de `extraData` como subtítulo |

### Archivos nuevos

| Archivo | Rol |
|---|---|
| `lib/models/finance/transaction_scan_result.dart` | Modelo de respuesta del nuevo endpoint |
| `lib/features/finance/data/services/transaction_scan_service.dart` | Llamada a `POST /finance/transactions/scan` |

---

## Key Abstractions

### `TransactionScanResult` (nuevo modelo)
- **Campos:** `amount?`, `currency?`, `date?`, `description?`, `extraData`, `confidence`, `warnings`
- **Getters:** `hasUsableData` (amount != null || date != null), `confidenceLabel`
- Compatible con web: no depende de `dart:io`

### `TransactionScanService` (nuevo servicio)
- **Dependencia:** `Dio` inyectado
- **Método:** `scanReceipt({required String categoryId, required XFile imageFile}) → Future<TransactionScanResult>`
- Usa `readAsBytes()` para compatibilidad web/móvil
- Timeout: 60s, `multipart/form-data`

### `CategoryModel` — campo nuevo
```dart
final List<String>? scanFields;
// fromJson: (json['scan_fields'] as List?)?.map((e) => e.toString()).toList()
```

### `TransactionModel` — campo nuevo
```dart
final Map<String, dynamic>? extraData;
// fromJson: json['extra_data'] != null ? Map<String, dynamic>.from(json['extra_data']) : null
```

### `FinanceRepository.createTransaction` — parámetro nuevo
```dart
Map<String, dynamic>? extraData,
// En body: if (extraData != null && extraData.isNotEmpty) 'extra_data': extraData,
```

### `TransactionNotifier.createTransaction` — parámetro nuevo
```dart
Map<String, dynamic>? extraData,
```

---

## Data Flow — Flujo Scan

1. Usuario selecciona tipo (Ingreso/Egreso) → se filtra la grilla de categorías.
2. Usuario selecciona categoría → aparece botón "Escanear comprobante".
3. Usuario toca el botón → `showModalBottomSheet` con opciones Cámara / Galería.
4. Se selecciona imagen → `TransactionScanService.scanReceipt(categoryId, xfile)`.
5. Loading overlay "Analizando comprobante..."
6. Respuesta `TransactionScanResult`:
   - Pre-llena `_amountController` si `result.amount != null`
   - Pre-llena `_selectedDate` si `result.date != null`
   - Pre-llena `_descriptionController` si `result.description != null`
   - Almacena `result.extraData` en `_extraData` (Map mutable para edición)
   - Si `confidence < 0.8` → muestra banner de confianza
7. Campos extras renderizados dinámicamente desde `_extraData`.
8. Usuario edita/confirma → `_save()` → `createTransaction(..., extraData: _extraData)`.
9. `context.pop(true)` al éxito.

## Data Flow — Flujo Manual con `scanFields`

1. Usuario selecciona categoría con `scanFields` (ej: Alimentación → `["vendor_name"]`).
2. Se renderizan los campos extras vacíos como opcionales.
3. Usuario llena manualmente los que quiera.
4. Al guardar, solo se envían los que tienen valor.

---

## API / Interface Contracts

### `POST /finance/transactions/scan`
- **Body:** `multipart/form-data` — `file` (imagen) + `category_id` (string)
- **Response:** `TransactionScanResult`
- **Timeout:** 60s

### `POST /finance/transactions` (actualizado)
```json
{
  "category_id": "...",
  "type": "expense",
  "amount": 45000,
  "currency": "COP",
  "date": "2026-06-05",
  "description": "...",
  "extra_data": { "vendor_name": "McDonald's" }
}
```

---

## Edge Cases & Error Handling

| Caso | Manejo |
|---|---|
| `400 "Formato no soportado..."` | SnackBar: "Solo se aceptan imágenes JPG o PNG" |
| `400 "El archivo está vacío."` | SnackBar: "La imagen no se pudo leer. Intentá de nuevo." |
| `400 "La imagen es demasiado grande."` | SnackBar: "La imagen supera 10 MB. Usá una de menor tamaño." |
| `confidence == 0.0` | Banner naranja + campos vacíos (usuario llena a mano) |
| `confidence >= 0.5 && < 0.8` | Banner amarillo: "Revisá los datos — confianza media" |
| `confidence >= 0.8` | Sin banner |
| Usuario cancela el picker | No hacer nada |
| Scan en curso + usuario navega atrás | Timeout del Dio limpia; no hay estado global |

## UI — Campos extra dinámicos

```dart
const Map<String, String> _fieldLabels = {
  'vendor_name': 'Negocio / Local',
  'provider_name': 'Proveedor',
  'service_name': 'Servicio',
  'tool_name': 'Herramienta',
  'client_name': 'Cliente',
  'invoice_number': 'N° de factura',
  'project_name': 'Proyecto',
  'product_name': 'Producto',
  'instrument_name': 'Instrumento',
  'destination': 'Destino',
  'billing_period': 'Período de facturación',
  'institution_name': 'Institución',
  'course_name': 'Curso',
  'concept': 'Concepto',
  'venue_name': 'Lugar',
};
```

- Post-scan: renderiza campos de `_extraData` (pre-llenados, editables)
- Sin scan: renderiza campos de `_selectedCategory!.scanFields` (vacíos, opcionales)
- Al cambiar categoría: limpiar `_extraData` y `_scanResult`

## UI — `TransactionTile` con `extraData`

Si `transaction.extraData` tiene entradas, el subtítulo muestra el valor del primer campo:
```
subtitle: extraData disponible →  "McDonald's" (primer valor)
          sin extraData        →  description ?? formattedDate (comportamiento actual)
```

---

## Open Questions for Implementation
- Ninguna.
