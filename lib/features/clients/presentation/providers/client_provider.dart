import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/client_model.dart';
import '../../data/repositories/client_repository.dart';

final clientRepositoryProvider = Provider((_) => ClientRepository());

final clientsProvider = FutureProvider<List<ClientModel>>((ref) async {
  final repo = ref.read(clientRepositoryProvider);
  return repo.getClients();
});
