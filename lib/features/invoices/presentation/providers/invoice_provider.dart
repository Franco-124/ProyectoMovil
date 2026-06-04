import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/invoice_model.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../data/services/invoice_scan_service.dart';
import '../../../../models/invoice_scan_result.dart';

final invoiceRepositoryProvider = Provider((_) => InvoiceRepository());

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

final invoiceScanServiceProvider = Provider(
  (_) => InvoiceScanService(),
);

final invoiceScanProvider = StateNotifierProvider<
    InvoiceScanNotifier,
    AsyncValue<InvoiceScanResult?>>(
  (ref) => InvoiceScanNotifier(
    ref.read(invoiceScanServiceProvider),
  ),
);

class InvoiceScanNotifier
    extends StateNotifier<AsyncValue<InvoiceScanResult?>> {
  final InvoiceScanService _service;

  InvoiceScanNotifier(this._service)
      : super(const AsyncValue.data(null));

  Future<void> scanImage(XFile imageFile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.scanImage(imageFile),
    );
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
