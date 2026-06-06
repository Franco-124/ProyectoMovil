class InvoiceScanResult {
  final String? invoiceNumber;
  final double? amount;
  final String? currency;
  final String? dueDate;
  final String? clientName;
  final String? clientEmail;
  final String? description;
  final double confidence;
  final String? rawText;
  final List<String> warnings;

  const InvoiceScanResult({
    this.invoiceNumber,
    this.amount,
    this.currency,
    this.dueDate,
    this.clientName,
    this.clientEmail,
    this.description,
    required this.confidence,
    this.rawText,
    required this.warnings,
  });

  factory InvoiceScanResult.fromJson(
    Map<String, dynamic> json,
  ) =>
      InvoiceScanResult(
        invoiceNumber: json['invoice_number'] as String?,
        amount: json['amount'] != null
            ? (json['amount'] as num).toDouble()
            : null,
        currency: json['currency'] as String?,
        dueDate: json['due_date'] as String?,
        clientName: json['client_name'] as String?,
        clientEmail: json['client_email'] as String?,
        description: json['description'] as String?,
        confidence: (json['confidence'] as num).toDouble(),
        rawText: json['raw_text'] as String?,
        warnings: List<String>.from(json['warnings'] ?? []),
      );

  bool get hasEnoughData =>
      amount != null && confidence >= 0.5;

  String get confidenceLabel =>
      '${(confidence * 100).round()}% de confianza';

  List<String> get foundFields => [
        if (invoiceNumber != null) 'Número',
        if (amount != null) 'Monto',
        if (currency != null) 'Moneda',
        if (dueDate != null) 'Fecha',
        if (clientName != null) 'Cliente',
        if (clientEmail != null) 'Email',
        if (description != null) 'Descripción',
      ];

  Map<String, dynamic> toJson() => {
    'invoice_number': invoiceNumber,
    'amount': amount,
    'currency': currency,
    'due_date': dueDate,
    'client_name': clientName,
    'client_email': clientEmail,
    'description': description,
    'confidence': confidence,
    'raw_text': rawText,
    'warnings': warnings,
  };
}
