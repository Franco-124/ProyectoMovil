import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/invoice_model.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../data/services/invoice_emit_service.dart';

final invoiceRepositoryProvider = Provider((_) => InvoiceRepository());

final invoiceEmitServiceProvider = Provider((_) => InvoiceEmitService());

final invoicesProvider = FutureProvider.family<List<InvoiceModel>, String?>(
  (ref, status) async {
    final repo = ref.read(invoiceRepositoryProvider);
    return repo.getInvoices(status: status);
  },
);

final invoiceDetailProvider = FutureProvider.family<InvoiceModel, String>(
  (ref, id) async {
    final repo = ref.read(invoiceRepositoryProvider);
    return repo.getInvoice(id);
  },
);
