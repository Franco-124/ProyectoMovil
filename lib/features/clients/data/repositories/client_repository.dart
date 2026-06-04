import '../../../../core/network/api_client.dart';
import '../models/client_model.dart';

class ClientRepository {
  final _dio = ApiClient.instance;

  Future<List<ClientModel>> getClients() async {
    final res = await _dio.get('/clients/');
    return (res.data as List)
        .map((j) => ClientModel.fromJson(j))
        .toList();
  }

  Future<ClientModel> createClient({
    required String name,
    required String email,
    String? company,
    String? notes,
    String emailLanguage = 'es',
    String emailTone = 'semi-formal',
    String emailTreatment = 'nombre',
    String? senderName,
    String? emailInstructions,
  }) async {
    final res = await _dio.post('/clients/', data: {
      'name': name,
      'email': email,
      'company': company,
      'notes': notes,
      'email_language': emailLanguage,
      'email_tone': emailTone,
      'email_treatment': emailTreatment,
      'sender_name': senderName,
      'email_instructions': emailInstructions,
    });
    return ClientModel.fromJson(res.data);
  }

  Future<ClientModel> updateClient(String id, {
    String? name,
    String? email,
    String? company,
    String? notes,
    String? emailLanguage,
    String? emailTone,
    String? emailTreatment,
    String? senderName,
    String? emailInstructions,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (company != null) data['company'] = company;
    if (notes != null) data['notes'] = notes;
    if (emailLanguage != null) data['email_language'] = emailLanguage;
    if (emailTone != null) data['email_tone'] = emailTone;
    if (emailTreatment != null) data['email_treatment'] = emailTreatment;
    if (senderName != null) data['sender_name'] = senderName;
    if (emailInstructions != null) data['email_instructions'] = emailInstructions;

    final res = await _dio.put('/clients/$id', data: data);
    return ClientModel.fromJson(res.data);
  }

  Future<void> deleteClient(String id) async {
    await _dio.delete('/clients/$id');
  }
}
