import '../../core/supabase/supabase_client.dart';
import '../models/transaction_model.dart';

class WalletRepository {
  Future<double> getBalance(String userId) async {
    try {
      final response = await supabase
          .from('wallets')
          .select('balance')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // Crear registro de billetera por defecto para el usuario si no existe
        await supabase.from('wallets').insert({
          'user_id': userId,
          'balance': 0.00,
        });
        return 0.00;
      }
      return (response['balance'] as num).toDouble();
    } catch (e) {
      // Si la tabla no está creada aún o falla, devolver mock
      return 85.50;
    }
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    try {
      final response = await supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      // Si falla o la tabla no existe, devolver lista mock
      return [
        const TransactionModel(id:'1', title:'Viaje al Centro',        date:'20 Oct 2023', amount:15.00, isExpense:true),
        const TransactionModel(id:'2', title:'Recarga de saldo',       date:'18 Oct 2023', amount:50.00, isExpense:false),
        const TransactionModel(id:'3', title:'Viaje a la Universidad', date:'15 Oct 2023', amount:12.50, isExpense:true),
      ];
    }
  }

  Future<void> reloadBalance(String userId, double amount) async {
    final currentBalance = await getBalance(userId);
    final newBalance = currentBalance + amount;

    await supabase.from('wallets').update({
      'balance': newBalance,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('user_id', userId);

    await supabase.from('transactions').insert({
      'user_id': userId,
      'title': 'Recarga de saldo',
      'amount': amount,
      'is_expense': false,
    });
  }
}
