import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/client_provider.dart';
import '../../data/models/client_model.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  bool _isActionLoading = false;

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteClient(ClientModel client) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: Text('¿Estás seguro de eliminar a ${client.name}? Esta acción eliminará en cascada todas sus facturas e historiales.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isActionLoading = true);
      try {
        await ref.read(clientRepositoryProvider).deleteClient(client.id);
        ref.invalidate(clientsProvider);
        _showSnackBar('Cliente eliminado con éxito.');
      } catch (e) {
        _showSnackBar('Error al eliminar cliente: $e', isError: true);
      } finally {
        if (mounted) setState(() => _isActionLoading = false);
      }
    }
  }

  Future<void> _showCreateClientBottomSheet() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final companyController = TextEditingController();
    final notesController = TextEditingController();
    final senderNameController = TextEditingController();
    final instructionsController = TextEditingController();
    
    String language = 'es';
    String tone = 'semi-formal';
    String treatment = 'nombre';

    final formKey = GlobalKey<FormState>();

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
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Agregar Cliente',
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
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Cliente',
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el nombre' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                    ),
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
                    decoration: const InputDecoration(
                      labelText: 'Empresa (Opcional)',
                      prefixIcon: Icon(Icons.business_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: senderNameController,
                    decoration: const InputDecoration(
                      labelText: 'Firma / Remitente (Opcional)',
                      prefixIcon: Icon(Icons.rate_review_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Configuration Overrides
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: language,
                          decoration: const InputDecoration(labelText: 'Idioma'),
                          items: const [
                            DropdownMenuItem(value: 'es', child: Text('Español')),
                            DropdownMenuItem(value: 'en', child: Text('Inglés')),
                          ],
                          onChanged: (val) => setModalState(() => language = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: tone,
                          decoration: const InputDecoration(labelText: 'Tono'),
                          items: const [
                            DropdownMenuItem(value: 'formal', child: Text('Formal')),
                            DropdownMenuItem(value: 'semi-formal', child: Text('S-Formal')),
                            DropdownMenuItem(value: 'informal', child: Text('Informal')),
                          ],
                          onChanged: (val) => setModalState(() => tone = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: treatment,
                          decoration: const InputDecoration(labelText: 'Trato'),
                          items: const [
                            DropdownMenuItem(value: 'nombre', child: Text('Nombre')),
                            DropdownMenuItem(value: 'usted', child: Text('Usted')),
                            DropdownMenuItem(value: 'tu', child: Text('Tú')),
                          ],
                          onChanged: (val) => setModalState(() => treatment = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Instrucciones IA (Opcional)',
                      prefixIcon: Icon(Icons.psychology_outlined, size: 20),
                      hintText: 'Ej. Ser muy cordial, recordar plan de cuotas',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas / Comentarios (Opcional)',
                      prefixIcon: Icon(Icons.description_outlined, size: 20),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isActionLoading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            
                            setModalState(() {
                              _isActionLoading = true;
                            });

                            try {
                              final repo = ref.read(clientRepositoryProvider);
                              await repo.createClient(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                company: companyController.text.trim().isEmpty ? null : companyController.text.trim(),
                                notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                                emailLanguage: language,
                                emailTone: tone,
                                emailTreatment: treatment,
                                senderName: senderNameController.text.trim().isEmpty ? null : senderNameController.text.trim(),
                                emailInstructions: instructionsController.text.trim().isEmpty ? null : instructionsController.text.trim(),
                              );
                              ref.invalidate(clientsProvider);
                              
                              if (ctx.mounted) {
                                _showSnackBar('Cliente guardado con éxito.');
                                Navigator.pop(ctx);
                              }
                            } catch (e) {
                              _showSnackBar('Error al crear cliente: $e', isError: true);
                            } finally {
                              setModalState(() {
                                _isActionLoading = false;
                              });
                            }
                          },
                    child: _isActionLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Guardar Cliente',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditClientBottomSheet(ClientModel client) async {
    final nameController = TextEditingController(text: client.name);
    final emailController = TextEditingController(text: client.email);
    final companyController = TextEditingController(text: client.company);
    final notesController = TextEditingController(text: client.notes);
    final senderNameController = TextEditingController(text: client.senderName);
    final instructionsController = TextEditingController(text: client.emailInstructions);
    
    String language = client.emailLanguage;
    String tone = client.emailTone;
    String treatment = client.emailTreatment;

    final formKey = GlobalKey<FormState>();

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
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Editar Cliente',
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
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Cliente',
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el nombre' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                    ),
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
                    decoration: const InputDecoration(
                      labelText: 'Empresa (Opcional)',
                      prefixIcon: Icon(Icons.business_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: senderNameController,
                    decoration: const InputDecoration(
                      labelText: 'Firma / Remitente (Opcional)',
                      prefixIcon: Icon(Icons.rate_review_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Configuration Overrides
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: language,
                          decoration: const InputDecoration(labelText: 'Idioma'),
                          items: const [
                            DropdownMenuItem(value: 'es', child: Text('Español')),
                            DropdownMenuItem(value: 'en', child: Text('Inglés')),
                          ],
                          onChanged: (val) => setModalState(() => language = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: tone,
                          decoration: const InputDecoration(labelText: 'Tono'),
                          items: const [
                            DropdownMenuItem(value: 'formal', child: Text('Formal')),
                            DropdownMenuItem(value: 'semi-formal', child: Text('S-Formal')),
                            DropdownMenuItem(value: 'informal', child: Text('Informal')),
                          ],
                          onChanged: (val) => setModalState(() => tone = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: treatment,
                          decoration: const InputDecoration(labelText: 'Trato'),
                          items: const [
                            DropdownMenuItem(value: 'nombre', child: Text('Nombre')),
                            DropdownMenuItem(value: 'usted', child: Text('Usted')),
                            DropdownMenuItem(value: 'tu', child: Text('Tú')),
                          ],
                          onChanged: (val) => setModalState(() => treatment = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Instrucciones IA (Opcional)',
                      prefixIcon: Icon(Icons.psychology_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas / Comentarios (Opcional)',
                      prefixIcon: Icon(Icons.description_outlined, size: 20),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isActionLoading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            
                            setModalState(() {
                              _isActionLoading = true;
                            });

                            try {
                              final repo = ref.read(clientRepositoryProvider);
                              await repo.updateClient(
                                client.id,
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                company: companyController.text.trim().isEmpty ? '' : companyController.text.trim(),
                                notes: notesController.text.trim().isEmpty ? '' : notesController.text.trim(),
                                emailLanguage: language,
                                emailTone: tone,
                                emailTreatment: treatment,
                                senderName: senderNameController.text.trim().isEmpty ? '' : senderNameController.text.trim(),
                                emailInstructions: instructionsController.text.trim().isEmpty ? '' : instructionsController.text.trim(),
                              );
                              ref.invalidate(clientsProvider);
                              
                              if (ctx.mounted) {
                                _showSnackBar('Cliente actualizado con éxito.');
                                Navigator.pop(ctx);
                              }
                            } catch (e) {
                              _showSnackBar('Error al actualizar cliente: $e', isError: true);
                            } finally {
                              setModalState(() {
                                _isActionLoading = false;
                              });
                            }
                          },
                    child: _isActionLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Actualizar Cliente',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateClientBottomSheet,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Agregar cliente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6366F1),
      ),
      body: Stack(
        children: [
          clientsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
                    const SizedBox(height: 16),
                    Text('Error al cargar clientes: $e', style: const TextStyle(color: Color(0xFFF87171))),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(clientsProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
            data: (clients) {
              if (clients.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline_rounded, color: Color(0xFF64748B), size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes clientes aún',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Agrega clientes para poder generar y enviarles recordatorios de pago automáticamente.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showCreateClientBottomSheet,
                        icon: const Icon(Icons.person_add_rounded),
                        label: const Text('Agregar mi primer cliente'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF6366F1),
                onRefresh: () => ref.refresh(clientsProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: clients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return _ClientListTileCard(
                      client: client,
                      onEdit: () => _showEditClientBottomSheet(client),
                      onDelete: () => _deleteClient(client),
                    );
                  },
                ),
              );
            },
          ),
          if (_isActionLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
            ),
        ],
      ),
    );
  }
}

class _ClientListTileCard extends StatelessWidget {
  final ClientModel client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClientListTileCard({
    required this.client,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                  radius: 20,
                  child: Text(
                    client.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Color(0xFF818CF8), fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        client.email,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
                  onSelected: (action) {
                    if (action == 'edit') {
                      onEdit();
                    } else if (action == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18, color: Color(0xFF6366F1)),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Configuration overrides display
            const Divider(color: Color(0xFF334155), height: 24),
            Row(
              children: [
                _buildSmallConfigBadge('Idioma: ${client.emailLanguage.toUpperCase()}'),
                const SizedBox(width: 6),
                _buildSmallConfigBadge('Tono: ${client.emailTone}'),
                const SizedBox(width: 6),
                _buildSmallConfigBadge('Trato: ${client.emailTreatment}'),
              ],
            ),

            if ((client.company != null && client.company!.isNotEmpty) || 
                (client.senderName != null && client.senderName!.isNotEmpty) ||
                (client.notes != null && client.notes!.isNotEmpty)) ...[
              const SizedBox(height: 10),
              if (client.company != null && client.company!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.business_rounded, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(
                        'Empresa: ${client.company!}',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              if (client.senderName != null && client.senderName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.rate_review_outlined, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(
                        'Remitente: ${client.senderName!}',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              if (client.notes != null && client.notes!.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.sticky_note_2_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        client.notes!,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSmallConfigBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF334155).withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }
}
