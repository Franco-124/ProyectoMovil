import '../../../../core/network/api_client.dart';
import '../models/email_log_model.dart';

class EmailRepository {
  final _dio = ApiClient.instance;

  Future<List<EmailLogModel>> getEmailLogs() async {
    final res = await _dio.get('/email-logs/');
    return (res.data as List)
        .map((j) => EmailLogModel.fromJson(j))
        .toList();
  }
}
