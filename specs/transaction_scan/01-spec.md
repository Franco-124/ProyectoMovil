# Spec: Transaction Scan

## Problem
El flujo de "escanear factura para registrarla" en el módulo de facturas ya no tiene
soporte en el backend (`POST /invoices/scan` y `POST /finance/transactions/from-scan`
fueron eliminados). Además, el concepto era confuso: el usuario escaneaba una factura
externa para luego registrarla como transacción financiera — dos pasos en el lugar
equivocado.

Lo que sí tiene valor real es poder fotografiar un **comprobante físico** (ticket de
restaurant, recibo de suscripción, transferencia) y que los campos del formulario de
nueva transacción se pre-llenen automáticamente. Ese flujo vive en Finanzas.

## Goals
- Eliminar completamente el flujo de scan del módulo de facturas (pantalla, servicio,
  modelos y llamadas a endpoints ya eliminados del backend).
- Construir el flujo de scan de comprobantes **dentro de la pantalla de nueva
  transacción** en Finanzas, como modo opcional junto al modo manual.
- Actualizar los modelos `Category` y `Transaction` con los nuevos campos del backend
  (`scan_fields` y `extra_data`).
- Renderizar campos extras dinámicos por categoría (vendor_name, provider_name, etc.)
  tanto en modo scan como en modo manual.

## Non-Goals
- No crear una pantalla separada para el scan — debe integrarse en la pantalla de
  nueva transacción existente.
- No cambiar el flujo de emisión de facturas (`/invoices/emit`) — eso no se toca.
- No mostrar historial de campos extra en pantallas de detalle de transacción (fuera
  del scope de esta iteración).

## Expected Behavior

**Flujo scan:**
1. Usuario abre "Nueva Transacción" desde Finanzas.
2. Elige tipo (Ingreso / Egreso) y selecciona una categoría.
3. Aparece botón "Escanear comprobante" (solo si hay categoría seleccionada).
4. Usuario fotografía o sube imagen del comprobante.
5. Loading: "Analizando comprobante..."
6. Campos del formulario se pre-llenan con los datos extraídos.
7. Si confidence < 0.8 → banner de advertencia con nivel de confianza.
8. Usuario revisa/edita y guarda.

**Flujo manual:**
1. Usuario abre "Nueva Transacción".
2. Elige tipo y categoría.
3. Llena campos manualmente.
4. Si la categoría tiene `scan_fields`, esos campos aparecen vacíos como opcionales.
5. Guarda.

**Al guardar:** se envía `extra_data` con los campos extras al endpoint
`POST /finance/transactions`.

## Constraints
- Los endpoints eliminados (`/invoices/scan`, `/finance/transactions/from-scan`)
  deben dejar de llamarse — devolverán 404.
- El nuevo endpoint es `POST /finance/transactions/scan` con `multipart/form-data`
  (`file` + `category_id`). Timeout: 60s.
- Arquitectura: Clean Architecture feature-first, Riverpod v2, Dio.
- Compatible con Web y Mobile (la lectura de imagen debe funcionar en ambos).
- La pantalla de nueva transacción existente (`CreateTransactionScreen`) se modifica,
  no se reemplaza.

## Priority
Alto — los endpoints eliminados causan errores 404 en producción si el usuario
intenta usar el scan actual.
