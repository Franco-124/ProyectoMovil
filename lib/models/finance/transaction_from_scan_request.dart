import '../invoice_scan_result.dart';

class TransactionFromScanRequest {
  final InvoiceScanResult scanResult;
  final String type;
  final String categoryId;
  final String? date;
  final String? description;
  final double? amount;
  final String? currency;

  const TransactionFromScanRequest({
    required this.scanResult,
    required this.type,
    required this.categoryId,
    this.date,
    this.description,
    this.amount,
    this.currency,
  });

  Map<String, dynamic> toJson() => {
    'scan_result': scanResult.toJson(),
    'type': type,
    'category_id': categoryId,
    if (date != null) 'date': date,
    if (description != null) 'description': description,
    if (amount != null) 'amount': amount,
    if (currency != null) 'currency': currency,
  };
}
