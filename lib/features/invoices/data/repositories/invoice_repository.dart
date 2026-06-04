import '../../../../core/network/api_client.dart';
import '../models/invoice_model.dart';

class InvoiceRepository {
  final _dio = ApiClient.instance;

  Future<List<InvoiceModel>> getInvoices({String? status}) async {
    final params = status != null ? {'invoice_status': status} : null;
    final res = await _dio.get('/invoices/', queryParameters: params);
    return (res.data as List)
        .map((j) => InvoiceModel.fromJson(j))
        .toList();
  }

  Future<InvoiceModel> getInvoice(String id) async {
    final res = await _dio.get('/invoices/$id');
    return InvoiceModel.fromJson(res.data);
  }

  Future<InvoiceModel> createInvoice({
    required String clientId,
    required String invoiceNumber,
    required double amount,
    required String currency,
    required String dueDate,
    String? description,
    bool reminderActive = true,
  }) async {
    final res = await _dio.post('/invoices/', data: {
      'client_id': clientId,
      'invoice_number': invoiceNumber,
      'amount': amount,
      'currency': currency,
      'due_date': dueDate,
      'description': description,
      'reminder_config': {
        'intervals': [3, 7, 14],
        'active': reminderActive,
      },
    });
    return InvoiceModel.fromJson(res.data);
  }

  Future<InvoiceModel> updateInvoice(String id, {
    String? invoiceNumber,
    double? amount,
    String? currency,
    String? dueDate,
    String? description,
    bool? reminderActive,
  }) async {
    final Map<String, dynamic> data = {};
    if (invoiceNumber != null) data['invoice_number'] = invoiceNumber;
    if (amount != null) data['amount'] = amount;
    if (currency != null) data['currency'] = currency;
    if (dueDate != null) data['due_date'] = dueDate;
    if (description != null) data['description'] = description;
    if (reminderActive != null) {
      data['reminder_config'] = {
        'intervals': [3, 7, 14],
        'active': reminderActive,
      };
    }

    final res = await _dio.put('/invoices/$id', data: data);
    return InvoiceModel.fromJson(res.data);
  }

  Future<InvoiceModel> updateStatus(String id, String status) async {
    final res = await _dio.patch(
      '/invoices/$id/status',
      data: {'status': status},
    );
    return InvoiceModel.fromJson(res.data);
  }

  Future<ReminderResult> sendReminder(String id) async {
    final res = await _dio.post('/invoices/$id/send-reminder');
    return ReminderResult.fromJson(res.data);
  }

  Future<InvoiceModel> toggleReminders(String id) async {
    final res = await _dio.patch('/invoices/$id/reminders/toggle');
    return InvoiceModel.fromJson(res.data);
  }

  Future<void> deleteInvoice(String id) async {
    await _dio.delete('/invoices/$id');
  }
}

class ReminderResult {
  final String detail;
  final String to;
  final String tone;

  const ReminderResult({
    required this.detail,
    required this.to,
    required this.tone,
  });

  factory ReminderResult.fromJson(Map<String, dynamic> json) => ReminderResult(
    detail: json['detail']?.toString() ?? '',
    to: json['to']?.toString() ?? '',
    tone: json['tone']?.toString() ?? 'firm',
  );
}
