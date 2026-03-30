import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sport80_state.dart';
import '../providers/sport80_provider.dart';
import '../theme/app_theme.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(sport80ControllerProvider);

    return appState.when(
      data: (state) {
        final profile = state.profile;
        if (profile == null) {
          return const SizedBox.shrink();
        }

        final pages = [
          TodayTab(state: state),
          ProgressScreen(state: state),
          SettingsScreen(state: state),
        ];

        return Scaffold(
          body: SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.today_rounded),
                label: 'Today',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_rounded),
                label: 'Progress',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_rounded),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load Sport 80: $error'),
          ),
        ),
      ),
    );
  }
}

class TodayTab extends ConsumerStatefulWidget {
  const TodayTab({
    super.key,
    required this.state,
  });

  final Sport80State state;

  @override
  ConsumerState<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends ConsumerState<TodayTab> {
  late final TextEditingController _reflectionController;

  @override
  void initState() {
    super.initState();
    _reflectionController = TextEditingController(
      text: widget.state.progressFor(DateTime.now()).reflection,
    );
  }

  @override
  void didUpdateWidget(covariant TodayTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final reflection = widget.state.progressFor(DateTime.now()).reflection;
    if (_reflectionController.text != reflection) {
      _reflectionController.value = TextEditingValue(
        text: reflection,
        selection: TextSelection.collapsed(offset: reflection.length),
      );
    }
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final theme = Theme.of(context);
    final profile = state.profile!;
    final today = state.progressFor(DateTime.now());
    final completionPercent = (today.completionRatio * 100).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        _HeroCard(
          greeting: _greeting(),
          name: profile.name,
          completionPercent: completionPercent,
          streak: state.currentStreak,
          atRisk: state.isStreakAtRisk,
          reminderLabel: profile.reminderSettings.enabled
              ? 'Reminder ${profile.reminderSettings.formattedTime}'
              : 'Reminder off',
          message: _dailyMessage(state, profile.goal),
        ),
        if (state.isStreakAtRisk) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.coral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppTheme.coral),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your streak is alive, but today is still open. Finish the required blocks before the day slips away.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        Text(
          'Today\'s challenge',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Required tasks protect the streak. Optional tasks add extra momentum.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 14),
        ...today.tasks.map((task) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TaskCard(
              task: task,
              onChanged: (completed) {
                ref.read(sport80ControllerProvider.notifier).toggleTask(
                      taskId: task.id,
                      completed: completed,
                    );
              },
            ),
          );
        }),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Energy check-in',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Log how your body feels today so your next session stays honest.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List<Widget>.generate(5, (index) {
                    final energy = index + 1;
                    return ChoiceChip(
                      selected: today.energy == energy,
                      label: Text('$energy/5'),
                      onSelected: (_) {
                        ref.read(sport80ControllerProvider.notifier).updateEnergy(energy);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reflection',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'One sentence is enough. Keep tomorrow informed.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _reflectionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'What felt strong, what dragged, and what needs attention tomorrow?',
                  ),
                  onChanged: (value) {
                    ref
                        .read(sport80ControllerProvider.notifier)
                        .updateReflection(value);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consistency snapshot',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SnapshotTile(
                        label: 'This week',
                        value: '${(state.weeklyConsistency * 100).round()}%',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SnapshotTile(
                        label: 'Workout days',
                        value: '${state.completedWorkoutDays}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SnapshotTile(
                        label: 'Best streak',
                        value: '${state.bestStreak}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  String _dailyMessage(Sport80State state, Sport80Goal goal) {
    if (state.isTodayComplete) {
      return 'Today is locked in. Keep the recovery habits strong and let the streak breathe.';
    }

    switch (goal) {
      case Sport80Goal.consistency:
        return 'Today is about protecting the slot. Keep the promise, even if the session stays simple.';
      case Sport80Goal.endurance:
        return 'Stack controlled effort with smart recovery. Build the engine without forcing the pace.';
      case Sport80Goal.strength:
        return 'Show up for clean work and honest recovery. Quality reps win this phase.';
      case Sport80Goal.wellness:
        return 'Move enough to feel better, not punished. A calmer day still counts when you follow through.';
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.greeting,
    required this.name,
    required this.completionPercent,
    required this.streak,
    required this.atRisk,
    required this.reminderLabel,
    required this.message,
  });

  final String greeting;
  final String name;
  final int completionPercent;
  final int streak;
  final bool atRisk;
  final String reminderLabel;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressValue = completionPercent / 100;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.navy, AppTheme.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $name.',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progressValue,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Center(
                      child: Text(
                        '$completionPercent%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroChip(
                icon: Icons.local_fire_department_rounded,
                label: streak == 1 ? '1 day streak' : '$streak day streak',
                accent: atRisk ? AppTheme.coral : Colors.white,
              ),
              _HeroChip(
                icon: Icons.notifications_active_rounded,
                label: reminderLabel,
                accent: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onChanged,
  });

  final DailyTask task;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final complete = task.completed;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: complete ? AppTheme.teal.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onChanged(!complete),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: complete,
                  onChanged: (value) => onChanged(value ?? false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.navy.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              task.category,
                              style: const TextStyle(
                                color: AppTheme.navy,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${task.points} pts',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: task.isRequired ? AppTheme.teal : Colors.black54,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              decoration:
                                  complete ? TextDecoration.lineThrough : null,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        task.isRequired ? 'Required' : 'Optional momentum',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: task.isRequired ? AppTheme.coral : Colors.black45,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.navy,
                ),
          ),
        ],
      ),
    );
  }
}
