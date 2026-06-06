import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:payremind/core/network/error_handler.dart';
import '../providers/invoice_provider.dart';
import '../../../clients/presentation/providers/client_provider.dart';
import '../../data/models/invoice_item_model.dart';

class InvoiceEmitScreen extends ConsumerStatefulWidget {
  const InvoiceEmitScreen({super.key});

  @override
  ConsumerState<InvoiceEmitScreen> createState() => _InvoiceEmitScreenState();
}

class _InvoiceEmitScreenState extends ConsumerState<InvoiceEmitScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClientId;
  final List<_ItemRow> _items = [];
  String _currency = 'COP';
  DateTime? _dueDate;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addItem();
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() => setState(() => _items.add(_ItemRow()));

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  double get _total => _items.fold(0.0, (sum, row) {
    final qty = double.tryParse(row.quantityController.text) ?? 0;
    final price = double.tryParse(row.priceController.text) ?? 0;
    return sum + (qty * price);
  });

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6366F1),
            onPrimary: Colors.white,
            surface: Color(0xFF1E293B),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un ítem'), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un cliente'), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha de vencimiento'), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final items = _items.map((row) => InvoiceItem(
        description: row.descriptionController.text.trim(),
        quantity: double.parse(row.quantityController.text.trim()),
        unitPrice: double.parse(row.priceController.text.trim()),
      )).toList();

      final result = await ref.read(invoiceRepositoryProvider).emitInvoice(
        clientId: _selectedClientId!,
        items: items,
        dueDate: DateFormat('yyyy-MM-dd').format(_dueDate!),
        currency: _currency,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      ref.invalidate(invoicesProvider(null));

      if (!mounted) return;

      final sent = result['sent'] as bool? ?? false;
      final invoiceNumber = result['invoice_number']?.toString() ?? '';
      final invoiceId = result['id']?.toString() ?? '';

      if (sent) {
        final clients = ref.read(clientsProvider).valueOrNull ?? [];
        final clientEmail = clients
            .where((c) => c.id == _selectedClientId)
            .map((c) => c.email)
            .firstOrNull ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Factura $invoiceNumber enviada a $clientEmail'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
      } else {
        await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Factura creada'),
            content: Text(
              'Factura $invoiceNumber creada correctamente, pero no se pudo enviar el email al cliente. '
              'Podés reenviarla manualmente desde el detalle de la factura.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }

      if (mounted) {
        if (invoiceId.isNotEmpty) {
          context.go('/invoices/$invoiceId');
        } else {
          context.pop();
        }
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data?['detail'] as String?;
      String msg;
      if (e.response?.statusCode == 403 && detail == 'free_plan_limit_reached') {
        msg = 'Alcanzaste el límite de facturas activas del plan gratuito.';
      } else if (e.response?.statusCode == 404 && detail == 'Client not found') {
        msg = 'El cliente seleccionado no existe.';
      } else {
        msg = ErrorHandler.getFriendlyMessage(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: const Color(0xFFEF4444)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.getFriendlyMessage(e)), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emitir Factura'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Client ──────────────────────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CLIENTE DESTINATARIO',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 12),
                        clientsAsync.when(
                          loading: () => const LinearProgressIndicator(color: Color(0xFF6366F1)),
                          error: (e, _) => Text('Error: $e', style: const TextStyle(color: Color(0xFFEF4444))),
                          data: (clients) {
                            if (clients.isEmpty) {
                              return const Text(
                                'No tienes clientes aún. Crea uno primero desde la sección Clientes.',
                                style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
                              );
                            }
                            return DropdownButtonFormField<String>(
                              value: _selectedClientId,
                              isExpanded: true,
                              isDense: true,
                              hint: const Text('Seleccionar cliente', style: TextStyle(fontSize: 14)),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: clients.map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text('${c.name} (${c.email})', style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (val) => setState(() => _selectedClientId = val),
                              validator: (val) => val == null ? 'Selecciona un cliente' : null,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Items ────────────────────────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ÍTEMS DE LA FACTURA',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            TextButton.icon(
                              onPressed: _addItem,
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                              label: const Text('Agregar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: const Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (_items.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('Agrega al menos un ítem', style: TextStyle(color: Color(0xFF94A3B8))),
                            ),
                          ),

                        ...List.generate(_items.length, (i) => _buildItemRow(i)),

                        const Divider(color: Color(0xFF334155), height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            Text(
                              '${fmt.format(_total)} $_currency',
                              style: const TextStyle(color: Color(0xFF22C55E), fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Config ───────────────────────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CONFIGURACIÓN',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _currency,
                          isDense: true,
                          decoration: const InputDecoration(
                            labelText: 'Moneda',
                            prefixIcon: Icon(Icons.attach_money_rounded, size: 20),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'COP', child: Text('COP')),
                            DropdownMenuItem(value: 'USD', child: Text('USD')),
                          ],
                          onChanged: (val) { if (val != null) setState(() => _currency = val); },
                        ),
                        const SizedBox(height: 16),

                        InkWell(
                          onTap: _selectDueDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, color: Color(0xFF6366F1)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Fecha de vencimiento', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text(
                                        _dueDate == null
                                            ? 'Seleccionar fecha'
                                            : DateFormat('dd MMMM, yyyy').format(_dueDate!),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF94A3B8)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Notas (opcional)',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Emitir y enviar factura', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6366F1)),
                    SizedBox(height: 16),
                    Text('Generando y enviando factura...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemRow(int index) {
    final row = _items[index];
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final qty = double.tryParse(row.quantityController.text) ?? 0;
    final price = double.tryParse(row.priceController.text) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Ítem ${index + 1}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              if (_items.length > 1)
                GestureDetector(
                  onTap: () => _removeItem(index),
                  child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFEF4444)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: row.descriptionController,
            decoration: const InputDecoration(
              labelText: 'Nombre del ítem',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
            validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: row.quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    final d = double.tryParse(v.trim());
                    if (d == null || d <= 0) return 'Inválido';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: row.priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Precio unitario',
                    prefixText: '\$ ',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    final d = double.tryParse(v.trim());
                    if (d == null || d < 0) return 'Inválido';
                    return null;
                  },
                ),
              ),
            ],
          ),
          if (qty > 0 && price > 0) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '= ${fmt.format(qty * price)}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemRow {
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final priceController = TextEditingController();

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }
}
