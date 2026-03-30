import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sport80_state.dart';
import '../providers/sport80_provider.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();

  Sport80Goal _selectedGoal = Sport80Goal.consistency;
  int _targetSessionsPerWeek = 4;
  bool _remindersEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 30);
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickReminderTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (selected != null) {
      setState(() {
        _reminderTime = selected;
      });
    }
  }

  Future<void> _submit() async {
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add your name so we can personalize the plan.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(sport80ControllerProvider.notifier).completeOnboarding(
            name: trimmedName,
            goal: _selectedGoal,
            targetSessionsPerWeek: _targetSessionsPerWeek,
            reminderSettings: ReminderSettings(
              enabled: _remindersEnabled,
              hour: _reminderTime.hour,
              minute: _reminderTime.minute,
            ),
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed('/home');
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not finish setup: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF10243C), Color(0xFFF6F1E8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.36],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Image.asset(
                  'assets/images/sport80_logo_new.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 18),
                Text(
                  'Finish setting up Sport 80.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'We\'ll build a realistic daily challenge around your training focus, your weekly target, and the time you want your reminder.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your profile',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'Ryan',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Primary focus',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: Sport80Goal.values.map((goal) {
                            final selected = goal == _selectedGoal;
                            return ChoiceChip(
                              selected: selected,
                              label: Text(goal.label),
                              avatar: Icon(
                                _goalIcon(goal),
                                size: 18,
                                color: selected ? AppTheme.navy : AppTheme.teal,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _selectedGoal = goal;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedGoal.summary,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly target',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'How many strong training days do you want to protect each week?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List<Widget>.generate(5, (index) {
                            final value = index + 3;
                            return ChoiceChip(
                              selected: value == _targetSessionsPerWeek,
                              label: Text('$value days'),
                              onSelected: (_) {
                                setState(() {
                                  _targetSessionsPerWeek = value;
                                });
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reminder rhythm',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          value: _remindersEnabled,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Daily reminder'),
                          subtitle: Text(
                            _remindersEnabled
                                ? 'A reminder will nudge you at ${_formatTime(_reminderTime)}.'
                                : 'No daily reminder for now.',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _remindersEnabled = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _remindersEnabled ? _pickReminderTime : null,
                          icon: const Icon(Icons.schedule),
                          label: Text(
                            _remindersEnabled
                                ? 'Change time'
                                : 'Turn reminders on to pick a time',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.coral.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.flag_circle, color: AppTheme.coral),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Your first version of Sport 80 will focus on reliable daily completion, progress tracking, streaks, and reminder readiness. We\'ll keep the setup lean so you can start today.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Start Sport 80'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  IconData _goalIcon(Sport80Goal goal) {
    switch (goal) {
      case Sport80Goal.consistency:
        return Icons.track_changes_rounded;
      case Sport80Goal.endurance:
        return Icons.directions_run_rounded;
      case Sport80Goal.strength:
        return Icons.fitness_center_rounded;
      case Sport80Goal.wellness:
        return Icons.spa_rounded;
    }
  }
}
