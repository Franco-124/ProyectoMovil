# Clarifications: Transaction Scan

## Questions & Answers

**Q1: ¿Reescribir o integrar CreateTransactionScreen?**
A: Integrar sin reescribir. El formulario manual existente se mantiene intacto; el scan
se agrega encima como opción opcional.

**Q2: ¿Dónde va el botón de escanear en la UI?**
A: Inline en el formulario, donde se vea más bonito. No en AppBar.

**Q3: ¿Mostrar extraData en TransactionTile ya en esta iteración?**
A: Sí aplica.

**Q4: ¿Navegación al guardar?**
A: Mantener comportamiento actual: `context.pop(true)`.

**Q5: ¿Selector de moneda?**
A: Solo COP. Sin selector de moneda visible.

## Open Decisions
- Ninguna. Todas las ambigüedades están resueltas.
