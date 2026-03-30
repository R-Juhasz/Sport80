import 'dart:convert';

enum Sport80Goal {
  consistency,
  endurance,
  strength,
  wellness,
}

extension Sport80GoalDetails on Sport80Goal {
  String get label {
    switch (this) {
      case Sport80Goal.consistency:
        return 'Consistency';
      case Sport80Goal.endurance:
        return 'Endurance';
      case Sport80Goal.strength:
        return 'Strength';
      case Sport80Goal.wellness:
        return 'Wellness';
    }
  }

  String get summary {
    switch (this) {
      case Sport80Goal.consistency:
        return 'Build a daily rhythm you can actually keep.';
      case Sport80Goal.endurance:
        return 'Increase aerobic capacity and recover well.';
      case Sport80Goal.strength:
        return 'Show up for strong sessions and solid recovery.';
      case Sport80Goal.wellness:
        return 'Stay active, feel better, and keep stress down.';
    }
  }
}

class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  factory ReminderSettings.defaults() {
    return const ReminderSettings(enabled: true, hour: 7, minute: 30);
  }

  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    return ReminderSettings(
      enabled: json['enabled'] as bool? ?? true,
      hour: json['hour'] as int? ?? 7,
      minute: json['minute'] as int? ?? 30,
    );
  }

  final bool enabled;
  final int hour;
  final int minute;

  ReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'hour': hour,
      'minute': minute,
    };
  }

  String get formattedTime {
    final hourLabel = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    final minuteLabel = minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    return '$hourLabel:$minuteLabel $suffix';
  }
}

class Sport80Profile {
  const Sport80Profile({
    required this.name,
    required this.goal,
    required this.targetSessionsPerWeek,
    required this.reminderSettings,
    required this.createdAt,
  });

  factory Sport80Profile.fromJson(Map<String, dynamic> json) {
    return Sport80Profile(
      name: json['name'] as String? ?? '',
      goal: Sport80Goal.values.firstWhere(
        (goal) => goal.name == json['goal'],
        orElse: () => Sport80Goal.consistency,
      ),
      targetSessionsPerWeek: json['targetSessionsPerWeek'] as int? ?? 4,
      reminderSettings: ReminderSettings.fromJson(
        json['reminderSettings'] as Map<String, dynamic>? ?? const {},
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final String name;
  final Sport80Goal goal;
  final int targetSessionsPerWeek;
  final ReminderSettings reminderSettings;
  final DateTime createdAt;

  Sport80Profile copyWith({
    String? name,
    Sport80Goal? goal,
    int? targetSessionsPerWeek,
    ReminderSettings? reminderSettings,
    DateTime? createdAt,
  }) {
    return Sport80Profile(
      name: name ?? this.name,
      goal: goal ?? this.goal,
      targetSessionsPerWeek:
          targetSessionsPerWeek ?? this.targetSessionsPerWeek,
      reminderSettings: reminderSettings ?? this.reminderSettings,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'goal': goal.name,
      'targetSessionsPerWeek': targetSessionsPerWeek,
      'reminderSettings': reminderSettings.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class DailyTask {
  const DailyTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.isRequired,
    required this.completed,
    required this.category,
  });

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      isRequired: json['isRequired'] as bool? ?? true,
      completed: json['completed'] as bool? ?? false,
      category: json['category'] as String? ?? '',
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final int points;
  final bool isRequired;
  final bool completed;
  final String category;

  DailyTask copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? points,
    bool? isRequired,
    bool? completed,
    String? category,
  }) {
    return DailyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      points: points ?? this.points,
      isRequired: isRequired ?? this.isRequired,
      completed: completed ?? this.completed,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'points': points,
      'isRequired': isRequired,
      'completed': completed,
      'category': category,
    };
  }
}

class DailyProgress {
  const DailyProgress({
    required this.dayKey,
    required this.tasks,
    required this.reflection,
    required this.energy,
    required this.updatedAt,
  });

  factory DailyProgress.empty(String dayKey) {
    return DailyProgress(
      dayKey: dayKey,
      tasks: const [],
      reflection: '',
      energy: 3,
      updatedAt: DateTime.now(),
    );
  }

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      dayKey: json['dayKey'] as String? ?? dayKeyFor(DateTime.now()),
      tasks: (json['tasks'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((task) => DailyTask.fromJson(Map<String, dynamic>.from(task)))
          .toList(),
      reflection: json['reflection'] as String? ?? '',
      energy: json['energy'] as int? ?? 3,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final String dayKey;
  final List<DailyTask> tasks;
  final String reflection;
  final int energy;
  final DateTime updatedAt;

  DailyProgress copyWith({
    String? dayKey,
    List<DailyTask>? tasks,
    String? reflection,
    int? energy,
    DateTime? updatedAt,
  }) {
    return DailyProgress(
      dayKey: dayKey ?? this.dayKey,
      tasks: tasks ?? this.tasks,
      reflection: reflection ?? this.reflection,
      energy: energy ?? this.energy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get totalPoints =>
      tasks.fold(0, (sum, task) => sum + task.points);

  int get completedPoints => tasks
      .where((task) => task.completed)
      .fold(0, (sum, task) => sum + task.points);

  double get completionRatio {
    if (tasks.isEmpty) {
      return 0;
    }
    return completedPoints / totalPoints;
  }

  bool get isComplete => tasks
      .where((task) => task.isRequired)
      .every((task) => task.completed);

  Map<String, dynamic> toJson() {
    return {
      'dayKey': dayKey,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'reflection': reflection,
      'energy': energy,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Sport80State {
  const Sport80State({
    required this.profile,
    required this.progressByDay,
    required this.reminderStatus,
  });

  factory Sport80State.empty() {
    return const Sport80State(
      profile: null,
      progressByDay: {},
      reminderStatus: '',
    );
  }

  factory Sport80State.fromJson(Map<String, dynamic> json) {
    final progressMap = <String, DailyProgress>{};
    final rawProgress = json['progressByDay'] as Map<String, dynamic>? ?? {};
    for (final entry in rawProgress.entries) {
      if (entry.value is Map) {
        progressMap[entry.key] = DailyProgress.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }
    }

    return Sport80State(
      profile: json['profile'] is Map
          ? Sport80Profile.fromJson(
              Map<String, dynamic>.from(json['profile'] as Map),
            )
          : null,
      progressByDay: progressMap,
      reminderStatus: json['reminderStatus'] as String? ?? '',
    );
  }

  final Sport80Profile? profile;
  final Map<String, DailyProgress> progressByDay;
  final String reminderStatus;

  Sport80State copyWith({
    Sport80Profile? profile,
    bool clearProfile = false,
    Map<String, DailyProgress>? progressByDay,
    String? reminderStatus,
  }) {
    return Sport80State(
      profile: clearProfile ? null : profile ?? this.profile,
      progressByDay: progressByDay ?? this.progressByDay,
      reminderStatus: reminderStatus ?? this.reminderStatus,
    );
  }

  DailyProgress progressFor(DateTime date) {
    final key = dayKeyFor(date);
    final existing = progressByDay[key];
    if (existing != null) {
      return existing;
    }

    if (profile == null) {
      return DailyProgress.empty(key);
    }

    return DailyProgress(
      dayKey: key,
      tasks: buildTasksForGoal(goal: profile!.goal, date: date),
      reflection: '',
      energy: 3,
      updatedAt: DateTime.now(),
    );
  }

  bool get hasProfile => profile != null;

  bool get isTodayComplete => progressFor(DateTime.now()).isComplete;

  int get currentStreak {
    if (progressByDay.isEmpty) {
      return 0;
    }

    var cursor = _startOfDay(DateTime.now());
    final todayProgress = progressByDay[dayKeyFor(cursor)];
    if (todayProgress == null || !todayProgress.isComplete) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (true) {
      final progress = progressByDay[dayKeyFor(cursor)];
      if (progress != null && progress.isComplete) {
        streak += 1;
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      break;
    }
    return streak;
  }

  int get bestStreak {
    final completedDays = progressByDay.values
        .where((progress) => progress.isComplete)
        .map((progress) => dateFromDayKey(progress.dayKey))
        .toList()
      ..sort();

    if (completedDays.isEmpty) {
      return 0;
    }

    var best = 1;
    var running = 1;
    for (var index = 1; index < completedDays.length; index += 1) {
      final previous = completedDays[index - 1];
      final current = completedDays[index];
      if (_startOfDay(current)
              .difference(_startOfDay(previous))
              .inDays ==
          1) {
        running += 1;
        if (running > best) {
          best = running;
        }
      } else {
        running = 1;
      }
    }
    return best;
  }

  bool get isStreakAtRisk => currentStreak > 0 && !isTodayComplete;

  int get totalCompletedTasks => progressByDay.values
      .expand((progress) => progress.tasks)
      .where((task) => task.completed)
      .length;

  int get completedWorkoutDays => progressByDay.values
      .where((progress) => progress.tasks.any(
            (task) => task.id == 'primary' && task.completed,
          ))
      .length;

  int get completedDaysLast7 {
    final today = _startOfDay(DateTime.now());
    var count = 0;
    for (var offset = 0; offset < 7; offset += 1) {
      final date = today.subtract(Duration(days: offset));
      if (progressByDay[dayKeyFor(date)]?.isComplete ?? false) {
        count += 1;
      }
    }
    return count;
  }

  double get weeklyConsistency => completedDaysLast7 / 7;

  Map<String, dynamic> toJson() {
    return {
      'profile': profile?.toJson(),
      'progressByDay': progressByDay.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'reminderStatus': reminderStatus,
    };
  }

  String encode() => jsonEncode(toJson());
}

List<DailyTask> buildTasksForGoal({
  required Sport80Goal goal,
  required DateTime date,
}) {
  final weekend = date.weekday == DateTime.saturday ||
      date.weekday == DateTime.sunday;

  switch (goal) {
    case Sport80Goal.consistency:
      return [
        DailyTask(
          id: 'primary',
          title: weekend ? 'Hit your anchor session' : 'Complete your main session',
          subtitle: weekend
              ? 'Get at least 30 focused minutes in today.'
              : 'Protect your training slot before the day drifts away.',
          points: 40,
          isRequired: true,
          completed: false,
          category: 'Train',
        ),
        DailyTask(
          id: 'mobility',
          title: 'Reset with 10 minutes of mobility',
          subtitle: 'Keep your body feeling ready for tomorrow.',
          points: 25,
          isRequired: true,
          completed: false,
          category: 'Recover',
        ),
        DailyTask(
          id: 'recovery',
          title: 'Hydrate and fuel well',
          subtitle: 'Drink water and back the work up with recovery.',
          points: 20,
          isRequired: true,
          completed: false,
          category: 'Recover',
        ),
        DailyTask(
          id: 'mindset',
          title: 'Log one quick win',
          subtitle: 'Capture what felt strong today.',
          points: 15,
          isRequired: false,
          completed: false,
          category: 'Reflect',
        ),
      ];
    case Sport80Goal.endurance:
      return [
        DailyTask(
          id: 'primary',
          title: weekend ? 'Long effort or tempo block' : 'Cardio focus session',
          subtitle: weekend
              ? 'Build your engine with a longer controlled effort.'
              : 'Run, cycle, row, or condition for your target block.',
          points: 40,
          isRequired: true,
          completed: false,
          category: 'Train',
        ),
        DailyTask(
          id: 'mobility',
          title: 'Mobility and stride mechanics',
          subtitle: 'Spend 10 minutes on movement quality.',
          points: 25,
          isRequired: true,
          completed: false,
          category: 'Prime',
        ),
        DailyTask(
          id: 'recovery',
          title: 'Easy walk or cooldown',
          subtitle: 'Keep recovery active and your legs loose.',
          points: 20,
          isRequired: true,
          completed: false,
          category: 'Recover',
        ),
        DailyTask(
          id: 'mindset',
          title: 'Check breathing and effort notes',
          subtitle: 'Record how the pace and breathing felt.',
          points: 15,
          isRequired: false,
          completed: false,
          category: 'Reflect',
        ),
      ];
    case Sport80Goal.strength:
      return [
        DailyTask(
          id: 'primary',
          title: weekend ? 'Heavy or technical lift session' : 'Strength session',
          subtitle: weekend
              ? 'Use the extra space to push a quality lift or full-body block.'
              : 'Show up for your main resistance session today.',
          points: 40,
          isRequired: true,
          completed: false,
          category: 'Train',
        ),
        DailyTask(
          id: 'mobility',
          title: 'Prep and mobility work',
          subtitle: 'Open up shoulders, hips, and ankles for cleaner reps.',
          points: 25,
          isRequired: true,
          completed: false,
          category: 'Prime',
        ),
        DailyTask(
          id: 'recovery',
          title: 'Protein and recovery habit',
          subtitle: 'Pair the session with a smart recovery choice.',
          points: 20,
          isRequired: true,
          completed: false,
          category: 'Recover',
        ),
        DailyTask(
          id: 'mindset',
          title: 'Note one lift that moved well',
          subtitle: 'Track momentum, not just effort.',
          points: 15,
          isRequired: false,
          completed: false,
          category: 'Reflect',
        ),
      ];
    case Sport80Goal.wellness:
      return [
        DailyTask(
          id: 'primary',
          title: weekend ? 'Long walk or recovery movement' : 'Move for 30 minutes',
          subtitle: weekend
              ? 'Choose movement that leaves you feeling better than before.'
              : 'Walk, train, stretch, or flow. Just keep the promise.',
          points: 40,
          isRequired: true,
          completed: false,
          category: 'Move',
        ),
        DailyTask(
          id: 'mobility',
          title: 'Mobility or breathwork reset',
          subtitle: 'Create 10 calm minutes for body and mind.',
          points: 25,
          isRequired: true,
          completed: false,
          category: 'Reset',
        ),
        DailyTask(
          id: 'recovery',
          title: 'Hydration and recovery check',
          subtitle: 'Stay topped up and keep your energy steady.',
          points: 20,
          isRequired: true,
          completed: false,
          category: 'Recover',
        ),
        DailyTask(
          id: 'mindset',
          title: 'Record your mood shift',
          subtitle: 'Notice what improved after you moved.',
          points: 15,
          isRequired: false,
          completed: false,
          category: 'Reflect',
        ),
      ];
  }
}

String dayKeyFor(DateTime date) {
  final normalized = _startOfDay(date);
  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}

DateTime dateFromDayKey(String dayKey) {
  final parts = dayKey.split('-');
  if (parts.length != 3) {
    return _startOfDay(DateTime.now());
  }

  return DateTime(
    int.tryParse(parts[0]) ?? DateTime.now().year,
    int.tryParse(parts[1]) ?? DateTime.now().month,
    int.tryParse(parts[2]) ?? DateTime.now().day,
  );
}

DateTime _startOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
