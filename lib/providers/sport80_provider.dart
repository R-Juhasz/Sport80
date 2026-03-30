import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sport80_state.dart';
import '../services/local_storage_service.dart';
import '../services/reminder_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService();
});

final sport80ControllerProvider =
    AsyncNotifierProvider<Sport80Controller, Sport80State>(
  Sport80Controller.new,
);

class Sport80Controller extends AsyncNotifier<Sport80State> {
  late final LocalStorageService _storage;
  late final ReminderService _reminderService;

  @override
  Future<Sport80State> build() async {
    _storage = ref.read(localStorageServiceProvider);
    _reminderService = ref.read(reminderServiceProvider);

    final loadedState = await _storage.loadState();
    if (!loadedState.hasProfile) {
      return loadedState;
    }

    final reminderStatus =
        await _reminderService.syncReminder(loadedState.profile!.reminderSettings);
    if (reminderStatus == loadedState.reminderStatus) {
      return loadedState;
    }

    final syncedState = loadedState.copyWith(reminderStatus: reminderStatus);
    await _storage.saveState(syncedState);
    return syncedState;
  }

  Future<void> completeOnboarding({
    required String name,
    required Sport80Goal goal,
    required int targetSessionsPerWeek,
    required ReminderSettings reminderSettings,
  }) async {
    final profile = Sport80Profile(
      name: name.trim(),
      goal: goal,
      targetSessionsPerWeek: targetSessionsPerWeek,
      reminderSettings: reminderSettings,
      createdAt: DateTime.now(),
    );

    final current = await _currentState();
    final nextState = current.copyWith(
      profile: profile,
      reminderStatus: '',
    );

    await _persistState(nextState, reminderSettings: reminderSettings);
  }

  Future<void> toggleTask({
    required String taskId,
    required bool completed,
    DateTime? date,
  }) async {
    final current = await _currentState();
    final profile = current.profile;
    if (profile == null) {
      return;
    }

    final targetDate = date ?? DateTime.now();
    final progress = current.progressFor(targetDate);
    final updatedTasks = progress.tasks
        .map(
          (task) => task.id == taskId
              ? task.copyWith(completed: completed)
              : task,
        )
        .toList();

    final updatedProgress = progress.copyWith(
      tasks: updatedTasks,
      updatedAt: DateTime.now(),
    );

    final nextProgress = Map<String, DailyProgress>.from(current.progressByDay)
      ..[updatedProgress.dayKey] = updatedProgress;

    await _persistState(
      current.copyWith(progressByDay: nextProgress),
      reminderSettings: profile.reminderSettings,
    );
  }

  Future<void> updateReflection(
    String reflection, {
    DateTime? date,
  }) async {
    final current = await _currentState();
    final profile = current.profile;
    if (profile == null) {
      return;
    }

    final targetDate = date ?? DateTime.now();
    final progress = current.progressFor(targetDate);
    final updatedProgress = progress.copyWith(
      reflection: reflection,
      updatedAt: DateTime.now(),
    );

    final nextProgress = Map<String, DailyProgress>.from(current.progressByDay)
      ..[updatedProgress.dayKey] = updatedProgress;

    await _persistState(
      current.copyWith(progressByDay: nextProgress),
      reminderSettings: profile.reminderSettings,
    );
  }

  Future<void> updateEnergy(
    int energy, {
    DateTime? date,
  }) async {
    final current = await _currentState();
    final profile = current.profile;
    if (profile == null) {
      return;
    }

    final targetDate = date ?? DateTime.now();
    final progress = current.progressFor(targetDate);
    final updatedProgress = progress.copyWith(
      energy: energy.clamp(1, 5).toInt(),
      updatedAt: DateTime.now(),
    );

    final nextProgress = Map<String, DailyProgress>.from(current.progressByDay)
      ..[updatedProgress.dayKey] = updatedProgress;

    await _persistState(
      current.copyWith(progressByDay: nextProgress),
      reminderSettings: profile.reminderSettings,
    );
  }

  Future<void> updateProfile({
    required String name,
    required Sport80Goal goal,
    required int targetSessionsPerWeek,
    required ReminderSettings reminderSettings,
  }) async {
    final current = await _currentState();
    final existingProfile = current.profile;
    if (existingProfile == null) {
      return;
    }

    final updatedProfile = existingProfile.copyWith(
      name: name.trim(),
      goal: goal,
      targetSessionsPerWeek: targetSessionsPerWeek,
      reminderSettings: reminderSettings,
    );

    final refreshedProgress = Map<String, DailyProgress>.from(current.progressByDay);
    final todayKey = dayKeyFor(DateTime.now());
    if (!refreshedProgress.containsKey(todayKey)) {
      refreshedProgress[todayKey] = DailyProgress(
        dayKey: todayKey,
        tasks: buildTasksForGoal(goal: goal, date: DateTime.now()),
        reflection: '',
        energy: 3,
        updatedAt: DateTime.now(),
      );
    }

    await _persistState(
      current.copyWith(
        profile: updatedProfile,
        progressByDay: refreshedProgress,
      ),
      reminderSettings: reminderSettings,
    );
  }

  Future<void> resetProgress({bool resetProfile = false}) async {
    final current = await _currentState();
    final profile = resetProfile ? null : current.profile;

    if (resetProfile) {
      await _reminderService.cancelReminder();
    }

    final nextState = Sport80State(
      profile: profile,
      progressByDay: const {},
      reminderStatus: resetProfile ? '' : current.reminderStatus,
    );

    await _storage.saveState(nextState);
    state = AsyncData(nextState);
  }

  Future<void> _persistState(
    Sport80State nextState, {
    ReminderSettings? reminderSettings,
  }) async {
    final settings = reminderSettings ?? nextState.profile?.reminderSettings;
    var persistedState = nextState;

    if (settings != null) {
      final reminderStatus = await _reminderService.syncReminder(settings);
      persistedState = nextState.copyWith(reminderStatus: reminderStatus);
    }

    await _storage.saveState(persistedState);
    state = AsyncData(persistedState);
  }

  Future<Sport80State> _currentState() async {
    return state.asData?.value ?? await future;
  }
}
