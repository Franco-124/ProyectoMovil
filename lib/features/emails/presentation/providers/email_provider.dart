import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/email_log_model.dart';
import '../../data/repositories/email_repository.dart';

final emailRepositoryProvider = Provider((_) => EmailRepository());

final emailLogsProvider = FutureProvider<List<EmailLogModel>>((ref) async {
  final repo = ref.read(emailRepositoryProvider);
  return repo.getEmailLogs();
});
