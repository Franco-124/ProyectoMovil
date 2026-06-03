import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/faq_model.dart';
import 'support_state.dart';

class SupportNotifier extends StateNotifier<SupportState> {
  SupportNotifier() : super(const SupportIdle()) { _load(); }

  Future<void> _load() async {
    state = const SupportLoading();
    await Future.delayed(const Duration(seconds: 1));
    state = const SupportSuccess(
      faqs: [
        FaqModel(id:'1', question:'¿Cómo recargo mi billetera?',
            answer:'Puedes recargar desde la sección Wallet usando tu tarjeta.'),
        FaqModel(id:'2', question:'¿Qué hago si mi viaje no finaliza?',
            answer:'Asegúrate de estar en una zona de parqueo permitida.'),
        FaqModel(id:'3', question:'¿Cómo reportar un problema mecánico?',
            answer:'Usa el botón de chat para contactar a soporte técnico.'),
      ],
      contactEmail: 'soporte@ebike.com',
      contactPhone: '+51 999 888 777',
    );
  }

  void onCallPressed() {}  // implementar con url_launcher
  void onChatPressed() {}
}

final supportProvider = StateNotifierProvider.autoDispose<SupportNotifier, SupportState>(
  (ref) => SupportNotifier(),
);
