import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/invoice_provider.dart';
import '../../../clients/presentation/providers/client_provider.dart';
import '../../../clients/data/models/client_model.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedClientId;
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
  String _currency = 'USD';
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  bool _remindersActive = true;
  bool _isLoading = false;

  final List<String> _currencies = ['USD', 'EUR', 'COP', 'MXN', 'ARS'];

  @override
  void dispose() {
    _numberController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _showCreateClientBottomSheet() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final companyController = TextEditingController();
    final notesController = TextEditingController();
    final bottomSheetFormKey = GlobalKey<FormState>();
    bool bottomSheetLoading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: bottomSheetFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nuevo Cliente',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del Cliente'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el nombre' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Ingresa el correo';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: companyController,
                    decoration: const InputDecoration(labelText: 'Empresa (Opcional)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notas (Opcional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: bottomSheetLoading
                        ? null
                        : () async {
                            if (!bottomSheetFormKey.currentState!.validate()) return;
                            setModalState(() => bottomSheetLoading = true);
                            try {
                              final repo = ref.read(clientRepositoryProvider);
                              final ClientModel newClient = await repo.createClient(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                company: companyController.text.trim().isEmpty ? null : companyController.text.trim(),
                                notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                              );
                              ref.invalidate(clientsProvider);
                              if (ctx.mounted) {
                                setState(() {
                                  _selectedClientId = newClient.id;
                                });
                                Navigator.pop(ctx);
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text('Error al crear cliente: $e'),
                                  backgroundColor: const Color(0xFFEF4444),
                                ),
                              );
                            } finally {
                              setModalState(() => bottomSheetLoading = false);
                            }
                          },
                    child: bottomSheetLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Crear Cliente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un cliente o crea uno nuevo'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la fecha de vencimiento'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final formattedDueDate = DateFormat('yyyy-MM-dd').format(_dueDate!);
      await ref.read(invoiceRepositoryProvider).createInvoice(
            clientId: _selectedClientId!,
            invoiceNumber: _numberController.text.trim(),
            amount: double.parse(_amountController.text.trim()),
            currency: _currency,
            dueDate: formattedDueDate,
            description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
            reminderActive: _remindersActive,
          );

      ref.invalidate(invoicesProvider(null));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Factura creada exitosamente.'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear factura: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Factura'),
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
                // Client Selector Card
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
                              'CLIENTE DESTINATARIO',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _showCreateClientBottomSheet,
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                              label: const Text('Nuevo cliente', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                        clientsAsync.when(
                          loading: () => const LinearProgressIndicator(color: Color(0xFF6366F1)),
                          error: (e, _) => Text(
                            'Error al obtener clientes: $e',
                            style: const TextStyle(color: Color(0xFFEF4444)),
                          ),
                          data: (clients) {
                            if (clients.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
                                ),
                                child: const Text(
                                  'Aún no tienes clientes. Haz clic en "Nuevo cliente" arriba para crear uno antes de continuar.',
                                  style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
                                ),
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
                              items: clients.map((c) {
                                return DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    '${c.name} (${c.email})',
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedClientId = val;
                                });
                              },
                              validator: (val) => val == null ? 'Selecciona un cliente' : null,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Invoice details card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DATOS DE LA FACTURA',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Number
                        TextFormField(
                          controller: _numberController,
                          decoration: const InputDecoration(
                            labelText: 'Número de factura',
                            prefixIcon: Icon(Icons.tag_rounded, size: 20),
                            hintText: 'FAC-0001',
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el número' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Amount and Currency Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Monto',
                                  prefixIcon: Icon(Icons.attach_money_rounded, size: 20),
                                  hintText: '0.00',
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Ingresa el monto';
                                  if (double.tryParse(val.trim()) == null) return 'Monto no válido';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: _currency,
                                isExpanded: true,
                                isDense: true,
                                decoration: const InputDecoration(
                                  labelText: 'Moneda',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                ),
                                items: _currencies.map((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text(c, style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _currency = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Due date selector
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
                                      const Text(
                                        'Fecha de vencimiento',
                                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                      ),
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

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Descripción / Concepto (Opcional)',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Reminders config card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recordatorios Automáticos',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Enviar avisos a los 3, 7 y 14 días antes del vencimiento',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _remindersActive,
                          activeColor: const Color(0xFF6366F1),
                          onChanged: (val) {
                            setState(() {
                              _remindersActive = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Crear y Guardar Factura',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                child: CircularProgressIndicator(color: Color(0xFF6366F1)),
              ),
            ),
        ],
      ),
    );
  }
}
