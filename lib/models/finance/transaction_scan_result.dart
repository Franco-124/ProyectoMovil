class TransactionScanResult {
  final double? amount;
  final String? currency;
  final String? date;
  final String? description;
  final Map<String, dynamic> extraData;
  final double confidence;
  final List<String> warnings;

  const TransactionScanResult({
    this.amount,
    this.currency,
    this.date,
    this.description,
    this.extraData = const {},
    this.confidence = 0.0,
    this.warnings = const [],
  });

  factory TransactionScanResult.fromJson(Map<String, dynamic> json) =>
      TransactionScanResult(
        amount: json['amount'] != null
            ? (json['amount'] as num).toDouble()
            : null,
        currency: json['currency']?.toString(),
        date: json['date']?.toString(),
        description: json['description']?.toString(),
        extraData: json['extra_data'] != null
            ? Map<String, dynamic>.from(json['extra_data'] as Map)
            : {},
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        warnings: (json['warnings'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  bool get hasUsableData => amount != null || date != null;

  String get confidenceLabel {
    if (confidence >= 0.8) return 'Alta';
    if (confidence >= 0.5) return 'Media';
    return 'Baja';
  }
}
