import '../../../clients/data/models/client_model.dart';

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final double amount;
  final String currency;
  final String dueDate;
  final String status;
  final String? description;
  final Map<String, dynamic> reminderConfig;
  final ClientModel client;
  final DateTime createdAt;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    required this.currency,
    required this.dueDate,
    required this.status,
    this.description,
    required this.reminderConfig,
    required this.client,
    required this.createdAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      dueDate: json['due_date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      description: json['description']?.toString(),
      reminderConfig: Map<String, dynamic>.from(json['reminder_config'] as Map? ?? {}),
      client: ClientModel.fromJson(json['client'] as Map<String, dynamic>),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'invoice_number': invoiceNumber,
    'amount': amount,
    'currency': currency,
    'due_date': dueDate,
    'status': status,
    'description': description,
    'reminder_config': reminderConfig,
    'client': client.toJson(),
    'created_at': createdAt.toIso8601String(),
  };

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    double? amount,
    String? currency,
    String? dueDate,
    String? status,
    String? description,
    Map<String, dynamic>? reminderConfig,
    ClientModel? client,
    DateTime? createdAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      description: description ?? this.description,
      reminderConfig: reminderConfig ?? this.reminderConfig,
      client: client ?? this.client,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
