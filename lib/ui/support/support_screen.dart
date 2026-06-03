import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/faq_model.dart';
import 'support_notifier.dart';
import 'support_state.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(supportProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
        title: const Text('Support', style: TextStyle(color: AppColors.textWhite)),
      ),
      body: switch (state) {
        SupportLoading() => const Center(child: CircularProgressIndicator(color: AppColors.accentTeal)),
        SupportSuccess(:final faqs, :final contactEmail, :final contactPhone) =>
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Contact buttons
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                      onPressed: () => ref.read(supportProvider.notifier).onCallPressed(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bgNavy,
                          foregroundColor: AppColors.textWhite),
                      onPressed: () => ref.read(supportProvider.notifier).onChatPressed(),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                Text(contactEmail,
                    style: const TextStyle(color: AppColors.textGray),
                    textAlign: TextAlign.center),
                Text(contactPhone,
                    style: const TextStyle(color: AppColors.textGray),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),

                const Text('Preguntas Frecuentes',
                    style: TextStyle(color: AppColors.textWhite,
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...faqs.map((f) => _FaqTile(f)),
              ],
            ),
          ),
        SupportError(:final message) => Center(child: Text(message,
            style: const TextStyle(color: AppColors.statusCancelled))),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _FaqTile extends StatelessWidget {
  final FaqModel faq;
  const _FaqTile(this.faq);

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: Text(faq.question,
        style: const TextStyle(color: AppColors.textWhite, fontSize: 14)),
    iconColor: AppColors.accentTeal,
    collapsedIconColor: AppColors.textGray,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Text(faq.answer,
            style: const TextStyle(color: AppColors.textGray)),
      ),
    ],
  );
}
