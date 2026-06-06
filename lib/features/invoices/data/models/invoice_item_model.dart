class InvoiceItem {
  final String description;
  final double quantity;
  final double unitPrice;
  final double? total;

  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.total,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'quantity': quantity,
    'unit_price': unitPrice,
  };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
    description: json['description'] as String,
    quantity: (json['quantity'] as num).toDouble(),
    unitPrice: (json['unit_price'] as num).toDouble(),
    total: json['total'] != null ? (json['total'] as num).toDouble() : null,
  );
}
