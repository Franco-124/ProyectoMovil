class ScheduleState {
  final DateTime? selectedDate;
  final int? selectedTimeSlotIndex;
  final int? selectedDurationIndex;

  const ScheduleState({
    this.selectedDate,
    this.selectedTimeSlotIndex,
    this.selectedDurationIndex,
  });

  ScheduleState copyWith({
    DateTime? selectedDate,
    int? selectedTimeSlotIndex,
    int? selectedDurationIndex,
  }) => ScheduleState(
    selectedDate: selectedDate ?? this.selectedDate,
    selectedTimeSlotIndex: selectedTimeSlotIndex ?? this.selectedTimeSlotIndex,
    selectedDurationIndex: selectedDurationIndex ?? this.selectedDurationIndex,
  );
}
