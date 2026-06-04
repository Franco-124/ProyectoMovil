class EmailLogInvoice {
  final String invoiceNumber;
  final double amount;
  final String currency;

  const EmailLogInvoice({
    required this.invoiceNumber,
    required this.amount,
    required this.currency,
  });

  factory EmailLogInvoice.fromJson(Map<String, dynamic> json) => EmailLogInvoice(
    invoiceNumber: json['invoice_number']?.toString() ?? '',
    amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
    currency: json['currency']?.toString() ?? 'USD',
  );
}

class EmailLogClient {
  final String name;
  final String email;

  const EmailLogClient({required this.name, required this.email});

  factory EmailLogClient.fromJson(Map<String, dynamic> json) => EmailLogClient(
    name: json['name']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
  );
}

class EmailLogModel {
  final String id;
  final String? subject;
  final String? body;
  final String tone;       // "friendly" | "firm" | "final"
  final String status;     // "sent" | "failed" | "opened"
  final DateTime sentAt;
  final int reminderDay;
  final String? errorMessage;
  final EmailLogInvoice invoice;
  final EmailLogClient client;

  bool get isSent => status == 'sent';
  bool get isFailed => status == 'failed';

  String get toneLabel {
    switch (tone.toLowerCase()) {
      case 'friendly': return 'Amigable';
      case 'firm':     return 'Firme';
      case 'final':    return 'Final';
      default:         return tone;
    }
  }

  const EmailLogModel({
    required this.id,
    this.subject,
    this.body,
    required this.tone,
    required this.status,
    required this.sentAt,
    required this.reminderDay,
    this.errorMessage,
    required this.invoice,
    required this.client,
  });

  factory EmailLogModel.fromJson(Map<String, dynamic> json) => EmailLogModel(
    id: json['id']?.toString() ?? '',
    subject: json['subject'],
    body: json['body'],
    tone: json['tone']?.toString() ?? 'firm',
    status: json['status']?.toString() ?? 'sent',
    sentAt: json['sent_at'] != null 
        ? DateTime.tryParse(json['sent_at'] as String) ?? DateTime.now()
        : DateTime.now(),
    reminderDay: json['reminder_day'] as int? ?? 0,
    errorMessage: json['error_message'],
    invoice: EmailLogInvoice.fromJson(json['invoice'] as Map<String, dynamic>? ?? {}),
    client: EmailLogClient.fromJson(json['client'] as Map<String, dynamic>? ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'body': body,
    'tone': tone,
    'status': status,
    'sent_at': sentAt.toIso8601String(),
    'reminder_day': reminderDay,
    'error_message': errorMessage,
    'invoice': {
      'invoice_number': invoice.invoiceNumber,
      'amount': invoice.amount,
      'currency': invoice.currency,
    },
    'client': {
      'name': client.name,
      'email': client.email,
    },
  };
}
