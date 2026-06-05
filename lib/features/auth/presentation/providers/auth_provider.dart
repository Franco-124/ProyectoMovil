import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

// Import all data providers to reset them on logout
import '../../../invoices/presentation/providers/invoice_provider.dart';
import '../../../clients/presentation/providers/client_provider.dart';
import '../../../emails/presentation/providers/email_provider.dart';
import '../../../finance/presentation/providers/finance_provider.dart';

final authRepositoryProvider = Provider((_) => AuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider), ref),
);

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repo;
  final Ref _ref;

  AuthNotifier(this._repo, this._ref) : super(const AsyncValue.loading()) {
    _init();
    AuthInterceptor.onUnauthorized = () {
      state = const AsyncValue.data(null);
      _resetAllProviders();
    };
  }

  Future<void> _init() async {
    try {
      final hasToken = await SecureStorage.hasToken();
      if (!hasToken) {
        state = const AsyncValue.data(null);
        return;
      }
      final user = await _repo.getMe();
      state = AsyncValue.data(user);
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.login(email, password),
    );
  }

  Future<void> register(String email, String password, String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.register(email: email, password: password, fullName: name),
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
    _resetAllProviders();
  }

  void _resetAllProviders() {
    _ref.invalidate(invoicesProvider);
    _ref.invalidate(invoiceDetailProvider);
    _ref.invalidate(clientsProvider);
    _ref.invalidate(emailLogsProvider);
    _ref.invalidate(categoriesProvider);
    _ref.invalidate(transactionsProvider);
    _ref.invalidate(budgetsProvider);
    _ref.invalidate(financialDashboardProvider);
  }
}
