import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sport80_state.dart';
import '../providers/sport80_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
    required this.state,
  });

  final Sport80State state;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _nameController;

  late Sport80Goal _goal;
  late int _targetSessionsPerWeek;
  late bool _remindersEnabled;
  late TimeOfDay _reminderTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _syncFromState();
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.profile != widget.state.profile ||
        oldWidget.state.reminderStatus != widget.state.reminderStatus) {
      _syncFromState();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _syncFromState() {
    final profile = widget.state.profile;
    if (profile == null) {
      return;
    }

    _nameController.text = profile.name;
    _goal = profile.goal;
    _targetSessionsPerWeek = profile.targetSessionsPerWeek;
    _remindersEnabled = profile.reminderSettings.enabled;
    _reminderTime = TimeOfDay(
      hour: profile.reminderSettings.hour,
      minute: profile.reminderSettings.minute,
    );
  }

  Future<void> _pickTime() async {
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

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a profile name before saving.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(sport80ControllerProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            goal: _goal,
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings updated.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update settings: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _confirmReset({
    required bool resetProfile,
    required String title,
    required String body,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref
        .read(sport80ControllerProvider.notifier)
        .resetProgress(resetProfile: resetProfile);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.state.profile;
    final theme = Theme.of(context);
    if (profile == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        Text(
          'Settings',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        Text(
          'Fine-tune your training focus, reminder rhythm, and reset options without losing control of the product.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.black54,
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
                  'Profile',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Focus',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: Sport80Goal.values.map((goal) {
                    return ChoiceChip(
                      selected: _goal == goal,
                      label: Text(goal.label),
                      onSelected: (_) {
                        setState(() {
                          _goal = goal;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Text(
                  'Weekly target',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List<Widget>.generate(5, (index) {
                    final value = index + 3;
                    return ChoiceChip(
                      selected: _targetSessionsPerWeek == value,
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
                  'Reminders',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  value: _remindersEnabled,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Daily training reminder'),
                  subtitle: Text(
                    _remindersEnabled
                        ? 'Current time: ${_formatTime(_reminderTime)}'
                        : 'Reminders are currently off.',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _remindersEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _remindersEnabled ? _pickTime : null,
                  icon: const Icon(Icons.alarm_rounded),
                  label: const Text('Choose reminder time'),
                ),
                if (widget.state.reminderStatus.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.teal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.notifications_active_rounded, color: AppTheme.teal),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(widget.state.reminderStatus),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  'Reset and restart',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Use a light reset if you want a clean progress slate. Use the full restart if you want to run onboarding again.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    _confirmReset(
                      resetProfile: false,
                      title: 'Reset progress?',
                      body: 'This clears streaks, daily history, and task completion, but keeps your profile and reminder choices.',
                    );
                  },
                  child: const Text('Reset progress only'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    _confirmReset(
                      resetProfile: true,
                      title: 'Start onboarding again?',
                      body: 'This clears all Sport 80 setup, reminders, and progress so you can rebuild from scratch.',
                    );
                  },
                  child: const Text('Restart from onboarding'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text('Save settings'),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }
}
