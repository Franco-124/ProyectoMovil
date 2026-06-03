import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'schedule_state.dart';

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier() : super(const ScheduleState());

  void onDateSelected(DateTime date)    => state = state.copyWith(selectedDate: date);
  void onTimeSlotSelected(int index)    => state = state.copyWith(selectedTimeSlotIndex: index);
  void onDurationSelected(int index)    => state = state.copyWith(selectedDurationIndex: index);
}

final scheduleProvider = StateNotifierProvider.autoDispose<ScheduleNotifier, ScheduleState>(
  (ref) => ScheduleNotifier(),
);
