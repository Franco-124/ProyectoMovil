import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:payremind/core/network/error_handler.dart';
import '../providers/finance_provider.dart';
import '../widgets/category_icon_widget.dart';
import '../../../../models/finance/category_model.dart';
import '../../../../models/finance/transaction_scan_result.dart';

const Map<String, String> _fieldLabels = {
  'vendor_name':      'Negocio / Local',
  'provider_name':    'Proveedor',
  'service_name':     'Servicio',
  'tool_name':        'Herramienta',
  'client_name':      'Cliente',
  'invoice_number':   'N° de factura',
  'project_name':     'Proyecto',
  'product_name':     'Producto',
  'instrument_name':  'Instrumento',
  'destination':      'Destino',
  'billing_period':   'Período de facturación',
  'institution_name': 'Institución',
  'course_name':      'Curso',
  'concept':          'Concepto',
  'venue_name':       'Lugar',
};

class CreateTransactionScreen extends ConsumerStatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  ConsumerState<CreateTransactionScreen> createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends ConsumerState<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  String _type = 'expense';
  CategoryModel? _selectedCategory;
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Scan state
  bool _isScanning = false;
  TransactionScanResult? _scanResult;
  Map<String, dynamic> _extraData = {};
  final Map<String, TextEditingController> _extraControllers = {};

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    for (final c in _extraControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _clearScanState() {
    for (final c in _extraControllers.values) {
      c.dispose();
    }
    _extraControllers.clear();
    _extraData = {};
    _scanResult = null;
  }

  void _buildExtraControllers(Map<String, dynamic> data) {
    for (final c in _extraControllers.values) {
      c.dispose();
    }
    _extraControllers.clear();
    for (final entry in data.entries) {
      _extraControllers[entry.key] = TextEditingController(
        text: entry.value?.toString() ?? '',
      );
    }
  }

  void _buildEmptyExtraControllers(List<String> fields) {
    for (final c in _extraControllers.values) {
      c.dispose();
    }
    _extraControllers.clear();
    for (final field in fields) {
      _extraControllers[field] = TextEditingController();
    }
  }

  Future<void> _handleScanTap() async {
    if (_selectedCategory == null) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Escanear comprobante',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF6366F1)),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF6366F1)),
              title: const Text('Elegir de galería'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1920);
    if (picked == null || !mounted) return;

    setState(() => _isScanning = true);

    try {
      final service = ref.read(transactionScanServiceProvider);
      final result = await service.scanReceipt(
        categoryId: _selectedCategory!.id,
        imageFile: picked,
      );

      if (!mounted) return;
      setState(() {
        _scanResult = result;

        if (result.amount != null) {
          _amountController.text = result.amount!.toStringAsFixed(0);
        }
        if (result.date != null) {
          final parsed = DateTime.tryParse(result.date!);
          if (parsed != null) {
            _selectedDate = parsed;
            _dateController.text = _formatDate(parsed);
          }
        }
        if (result.description != null) {
          _descriptionController.text = result.description!;
        }

        _buildExtraControllers(result.extraData);
        _extraData = Map<String, dynamic>.from(result.extraData);
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data?['detail'] as String?;
      final msg = _scanErrorMessage(e.response?.statusCode, detail);
      _showSnackBar(msg, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(ErrorHandler.getFriendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  String _scanErrorMessage(int? statusCode, String? detail) {
    if (statusCode == 400) {
      if (detail != null && detail.contains('Formato')) return 'Solo se aceptan imágenes JPG o PNG.';
      if (detail != null && detail.contains('vacío')) return 'La imagen no se pudo leer. Intentá de nuevo.';
      if (detail != null && detail.contains('grande')) return 'La imagen supera 10 MB. Usá una de menor tamaño.';
    }
    return detail ?? 'No se pudo analizar el comprobante.';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
      ),
    );
  }

  Map<String, dynamic> _collectExtraData() {
    final result = <String, dynamic>{};
    for (final entry in _extraControllers.entries) {
      final val = entry.value.text.trim();
      if (val.isNotEmpty) result[entry.key] = val;
    }
    return result;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      _showSnackBar('Por favor, selecciona una categoría', isError: true);
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showSnackBar('El monto debe ser un número válido mayor que 0', isError: true);
      return;
    }

    final extraData = _collectExtraData();

    final success = await ref.read(transactionNotifierProvider.notifier).createTransaction(
      categoryId: _selectedCategory!.id,
      type: _type,
      amount: amount,
      date: _selectedDate,
      currency: 'COP',
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      extraData: extraData.isNotEmpty ? extraData : null,
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar('Transacción guardada correctamente');
      Navigator.of(context).pop(true);
    } else {
      final errorObj = ref.read(transactionNotifierProvider).error;
      final errorMsg = errorObj != null ? ErrorHandler.getFriendlyMessage(errorObj) : 'Error desconocido';
      _showSnackBar(errorMsg, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider(_type));
    final transactionState = ref.watch(transactionNotifierProvider);
    final isLoading = transactionState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva transacción')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Toggle Ingreso / Gasto
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'expense',
                    label: Text('Gasto'),
                    icon: Icon(Icons.remove_circle_outline_rounded),
                  ),
                  ButtonSegment<String>(
                    value: 'income',
                    label: Text('Ingreso'),
                    icon: Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _type = newSelection.first;
                    _selectedCategory = null;
                    _clearScanState();
                  });
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: const Color(0xFF6366F1),
                  selectedForegroundColor: Colors.white,
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Category Picker
              const Text(
                'Categoría',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                child: categoriesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
                  error: (e, _) => Center(
                    child: Text(ErrorHandler.getFriendlyMessage(e), style: const TextStyle(color: Color(0xFFEF4444))),
                  ),
                  data: (categories) {
                    if (categories.isEmpty) {
                      return const Center(
                        child: Text('No hay categorías disponibles', style: TextStyle(color: Color(0xFF94A3B8))),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = _selectedCategory?.id == cat.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                              _clearScanState();
                              if (cat.scanFields != null && cat.scanFields!.isNotEmpty) {
                                _buildEmptyExtraControllers(cat.scanFields!);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF6366F1).withOpacity(0.15)
                                  : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF334155),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CategoryIconWidget(category: cat, size: 36, iconSize: 18),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 3. Scan button (visible only when category selected)
              if (_selectedCategory != null) ...[
                OutlinedButton.icon(
                  onPressed: _isScanning ? null : _handleScanTap,
                  icon: _isScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)),
                        )
                      : const Icon(Icons.document_scanner_outlined, size: 18),
                  label: Text(_isScanning ? 'Analizando comprobante...' : 'Escanear comprobante'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    foregroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 4. Confidence banner (if scan done)
              if (_scanResult != null && _scanResult!.confidence < 0.8) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _scanResult!.confidence < 0.5
                        ? Colors.orange.shade900.withOpacity(0.25)
                        : Colors.amber.shade900.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _scanResult!.confidence < 0.5
                          ? Colors.orange.shade700
                          : Colors.amber.shade600,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: _scanResult!.confidence < 0.5
                            ? Colors.orange.shade300
                            : Colors.amber.shade300,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _scanResult!.confidence < 0.5
                              ? 'No se encontraron todos los datos. Completá los campos manualmente.'
                              : 'Revisá los datos — confianza ${_scanResult!.confidenceLabel.toLowerCase()}.',
                          style: TextStyle(
                            fontSize: 13,
                            color: _scanResult!.confidence < 0.5
                                ? Colors.orange.shade200
                                : Colors.amber.shade200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 5. Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  hintText: '0.00',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Ingresa el monto';
                  final amount = double.tryParse(val.trim());
                  if (amount == null || amount <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 6. Date Picker
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  suffixIcon: Icon(Icons.calendar_today_rounded, color: Color(0xFF94A3B8)),
                ),
              ),
              const SizedBox(height: 16),

              // 7. Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  hintText: 'Escribe detalles de la transacción...',
                ),
              ),

              // 8. Extra fields (dynamic)
              if (_extraControllers.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'DATOS ADICIONALES',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                ..._extraControllers.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: _fieldLabels[entry.key] ?? entry.key,
                        hintText: _scanResult != null ? null : 'Opcional',
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          _extraData[entry.key] = val;
                        } else {
                          _extraData.remove(entry.key);
                        }
                      },
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // 9. Save button
              ElevatedButton(
                onPressed: isLoading ? null : _save,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Guardar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
