import 'package:flutter/material.dart';

import '../models/sport80_state.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    super.key,
    required this.state,
  });

  final Sport80State state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final recentDays = List<DateTime>.generate(
      7,
      (index) => DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: index)),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        Text(
          'Progress',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        Text(
          'A clean view of your streaks, your recent consistency, and how well you are backing up the plan.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              title: 'Current streak',
              value: '${state.currentStreak}',
              suffix: 'days',
              color: AppTheme.navy,
              icon: Icons.local_fire_department_rounded,
            ),
            _MetricCard(
              title: 'Best streak',
              value: '${state.bestStreak}',
              suffix: 'days',
              color: AppTheme.teal,
              icon: Icons.workspace_premium_rounded,
            ),
            _MetricCard(
              title: 'Workout days',
              value: '${state.completedWorkoutDays}',
              suffix: 'done',
              color: AppTheme.coral,
              icon: Icons.fitness_center_rounded,
            ),
            _MetricCard(
              title: 'Tasks completed',
              value: '${state.totalCompletedTasks}',
              suffix: 'checks',
              color: const Color(0xFFB57A1A),
              icon: Icons.task_alt_rounded,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last 7 days',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(state.weeklyConsistency * 100).round()}% consistency this week',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 18),
                ...recentDays.map((date) {
                  final progress = state.progressFor(date);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: progress.isComplete
                                ? AppTheme.teal.withValues(alpha: 0.14)
                                : AppTheme.navy.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            progress.isComplete
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: progress.isComplete
                                ? AppTheme.teal
                                : Colors.black38,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _dayLabel(date),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                progress.tasks.isEmpty
                                    ? 'No plan generated yet.'
                                    : '${(progress.completionRatio * 100).round()}% score, energy ${progress.energy}/5',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${progress.completedPoints}/${progress.totalPoints}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: progress.isComplete ? AppTheme.teal : AppTheme.navy,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What to watch',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  state.isStreakAtRisk
                      ? 'Your streak is alive, but today is still open. One focused session keeps the run going.'
                      : state.isTodayComplete
                          ? 'Today is locked in. Use the reflection note to leave tomorrow a better starting point.'
                          : 'Your next streak starts with today. Keep the first check-in simple and decisive.',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _dayLabel(DateTime date) {
    const dayNames = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dayNames[date.weekday - 1]} ${date.day} ${monthNames[date.month - 1]}';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.suffix,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String suffix;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.titleLarge,
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ' $suffix',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
