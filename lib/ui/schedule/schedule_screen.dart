import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'schedule_notifier.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  static const _timeSlots  = ['9:00 AM','10:00 AM','10:10 AM','11:00 AM','12:30 PM','2:00 PM'];
  static const _durations  = ['30 minutes','2 hours','4 hours','Full Day'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bgNavy,
        selectedItemColor: AppColors.accentTeal,
        unselectedItemColor: AppColors.textGray,
        currentIndex: 1, // Schedule tab activo
        onTap: (i) { if (i == 0) context.pop(); },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar manual
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                    onPressed: () => context.pop(),
                  ),
                  const Text('Schedule Your Ride',
                      style: TextStyle(color: AppColors.textWhite,
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calendar
                    CalendarDatePicker(
                      initialDate: state.selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onDateChanged: (date) =>
                          ref.read(scheduleProvider.notifier).onDateSelected(date),
                    ),
                    const SizedBox(height: 24),

                    // Time Slots
                    const Text('Time Slots',
                        style: TextStyle(color: AppColors.textWhite,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_timeSlots.length, (i) => ChoiceChip(
                        label: Text(_timeSlots[i]),
                        selected: state.selectedTimeSlotIndex == i,
                        onSelected: (_) =>
                            ref.read(scheduleProvider.notifier).onTimeSlotSelected(i),
                        selectedColor: AppColors.accentTeal,
                        labelStyle: TextStyle(
                          color: state.selectedTimeSlotIndex == i
                              ? AppColors.bgDark : AppColors.textWhite,
                        ),
                      )),
                    ),
                    const SizedBox(height: 24),

                    // Rental Duration
                    const Text('Rental Duration',
                        style: TextStyle(color: AppColors.textWhite,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_durations.length, (i) => ChoiceChip(
                        label: Text(_durations[i]),
                        selected: state.selectedDurationIndex == i,
                        onSelected: (_) =>
                            ref.read(scheduleProvider.notifier).onDurationSelected(i),
                        selectedColor: AppColors.accentTeal,
                        labelStyle: TextStyle(
                          color: state.selectedDurationIndex == i
                              ? AppColors.bgDark : AppColors.textWhite,
                        ),
                      )),
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ride scheduled successfully!')),
                        );
                        context.pop();
                      },
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
