import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_log.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/calendar_heatmap.dart';
import '../../providers/habits_provider.dart' as habits;
import '../../providers/habit_logs_provider.dart' as logs;
import '../../providers/progress_provider.dart';
import '../../providers/habit_completion_provider.dart';
import '../../widgets/habit_check_in_button.dart';
import 'add_habit_screen.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final Habit habit;

  const HabitDetailScreen({
    super.key,
    required this.habit,
  });

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with habit icon
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: widget.habit.color,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editHabit,
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'duplicate':
                      _duplicateHabit();
                      break;
                    case 'archive':
                      _archiveHabit();
                      break;
                    case 'delete':
                      _deleteHabit();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: AppSpacing.sm),
                        Text('Duplicate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(Icons.archive),
                        SizedBox(width: AppSpacing.sm),
                        Text('Archive'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: AppSpacing.sm),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.habit.name,
                style: AppTextStyles.h5.copyWith(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.habit.color,
                      widget.habit.color.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'habit_icon_${widget.habit.id}',
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                      child: Icon(
                        _getIconData(widget.habit.icon),
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (widget.habit.description.isNotEmpty) ...[
                    Text(
                      widget.habit.description,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Quick Stats Row
                  _buildQuickStats(),
                  const SizedBox(height: AppSpacing.lg),

                  // Today's Action
                  _buildTodayAction(),
                  const SizedBox(height: AppSpacing.lg),

                  // Progress Stats
                  _buildProgressSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Calendar Heatmap
                  _buildCalendarSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Habit Details
                  _buildDetailsSection(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = ref.watch(logs.habitStatsProvider(widget.habit.id));
    
    return stats.when(
      data: (habitStats) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickStatItem(
                  icon: Icons.local_fire_department,
                  value: '${habitStats.currentStreak}',
                  label: 'Current Streak',
                  color: AppColors.orangePrimary,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.grey200,
              ),
              Expanded(
                child: _buildQuickStatItem(
                  icon: Icons.check_circle,
                  value: '${habitStats.completionCount}',
                  label: 'Total',
                  color: AppColors.greenPrimary,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.grey200,
              ),
              Expanded(
                child: _buildQuickStatItem(
                  icon: Icons.trending_up,
                  value: '${(habitStats.completionRate * 100).toInt()}%',
                  label: 'Success Rate',
                  color: AppColors.bluePrimary,
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Loading stats...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Error loading stats',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.h6.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayAction() {
    final completionCount = ref.watch(habitCompletionCountProvider(widget.habit.id));
    final progressText = ref.watch(habitProgressTextProvider(widget.habit.id));
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Header with period info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: widget.habit.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.today,
                    color: widget.habit.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Today\'s Action',
                  style: AppTextStyles.h6.copyWith(
                    color: widget.habit.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _buildPeriodProgress(completionCount, progressText),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Adaptive check-in button
            HabitCheckInButton(
              habit: widget.habit,
              onCheckIn: _markAsCompleted,
              isDetailScreen: true,
            ),
            
            // Show today's completions list if multiple
            if (completionCount > 1) ...[
              const SizedBox(height: AppSpacing.md),
              _buildTodaysCompletionsList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodProgress(int count, String progressText) {
    if (widget.habit.frequency == HabitFrequency.timesPerWeek) {
      return Row(
        children: [
          Text(
            progressText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.habit.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Progress dots
          ...List.generate(widget.habit.timesPerWeek, (index) {
            return Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Icon(
                index < count ? Icons.circle : Icons.circle_outlined,
                size: 8,
                color: index < count ? widget.habit.color : Colors.grey[400],
              ),
            );
          }),
        ],
      );
    }
    return Text(
      count > 0 ? 'Completed!' : 'Not completed',
      style: AppTextStyles.bodyMedium.copyWith(
        color: count > 0 ? AppColors.greenPrimary : AppColors.grey500,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTodaysCompletionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          'Today\'s Completions:',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // TODO: Implement list of today's completions
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: widget.habit.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(
            'Multiple completions today',
            style: AppTextStyles.bodySmall.copyWith(
              color: widget.habit.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    final stats = ref.watch(logs.habitStatsProvider(widget.habit.id));
    
    return stats.when(
      data: (habitStats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ProgressCard(
                  icon: Icons.local_fire_department,
                  value: '${habitStats.currentStreak}',
                  label: 'Current Streak',
                  subtitle: 'days',
                  color: AppColors.orangePrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ProgressCard(
                  icon: Icons.emoji_events,
                  value: '${habitStats.bestStreak}',
                  label: 'Best Streak',
                  subtitle: 'days',
                  color: AppColors.goldPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ProgressCard(
                  icon: Icons.check_circle,
                  value: '${habitStats.completionCount}',
                  label: 'Total Completions',
                  subtitle: 'times',
                  color: AppColors.greenPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ProgressCard(
                  icon: Icons.trending_up,
                  value: '${(habitStats.completionRate * 100).toInt()}%',
                  label: 'Success Rate',
                  subtitle: 'overall',
                  color: AppColors.bluePrimary,
                ),
              ),
            ],
          ),
        ],
      ),
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: AppSpacing.md),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Error loading stats: $error'),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity History',
          style: AppTextStyles.h6,
        ),
        const SizedBox(height: AppSpacing.md),
        CalendarHeatmap(
          habit: widget.habit,
          onDateTap: (date) {
            // TODO: Show date details
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Activity for ${date.toString().split(' ')[0]}'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Details',
          style: AppTextStyles.h6,
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.repeat,
                  'Frequency',
                  widget.habit.frequencyDescription,
                ),
                const Divider(),
                _buildDetailRow(
                  Icons.flag,
                  'Goal',
                  widget.habit.goalDescription,
                ),
                const Divider(),
                _buildDetailRow(
                  Icons.category,
                  'Category',
                  widget.habit.category,
                ),
                const Divider(),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Created',
                  _formatDate(widget.habit.createdAt),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            color: widget.habit.color,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconString) {
    // Same mapping as in other files
    switch (iconString.toLowerCase()) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'water_drop':
        return Icons.water_drop;
      case 'book':
        return Icons.book;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'bedtime':
        return Icons.bedtime;
      case 'wake':
        return Icons.wb_sunny;
      case 'restaurant':
        return Icons.restaurant;
      case 'coffee':
        return Icons.coffee;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'directions_run':
        return Icons.directions_run;
      case 'pool':
        return Icons.pool;
      case 'bike_scooter':
        return Icons.bike_scooter;
      case 'psychology':
        return Icons.psychology;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'music_note':
        return Icons.music_note;
      case 'palette':
        return Icons.palette;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'games':
        return Icons.games;
      case 'movie':
        return Icons.movie;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'pets':
        return Icons.pets;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'favorite':
        return Icons.favorite;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'eco':
        return Icons.eco;
      case 'star':
        return Icons.star;
      case 'celebration':
        return Icons.celebration;
      case 'travel_explore':
        return Icons.travel_explore;
      case 'language':
        return Icons.language;
      case 'code':
        return Icons.code;
      case 'brush':
        return Icons.brush;
      default:
        return Icons.check_circle_outline;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _markAsCompleted() async {
    try {
      final repository = ref.read(logs.habitLogRepositoryProvider);
      final log = HabitLog(
        id: repository.generateId(),
        habitId: widget.habit.id,
        completedAt: DateTime.now(),
        value: widget.habit.goalType != HabitGoalType.simple ? widget.habit.goalValue : null,
        note: null,
        isCompleted: true,
        createdAt: DateTime.now(),
        metadata: {},
      );
      
      await ref.read(logs.habitLogsProvider.notifier).addLog(log);
      
      // Refresh progress to update home screen
      await ref.read(progressProvider.notifier).refresh();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Great! "${widget.habit.name}" marked as completed!'),
            backgroundColor: AppColors.greenPrimary,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking habit as completed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editHabit() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddHabitScreen(habit: widget.habit),
      ),
    );
    
    if (result == true && mounted) {
      // Return to previous screen to refresh the habit list
      Navigator.of(context).pop(true);
    }
  }

  void _duplicateHabit() async {
    try {
      final repository = ref.read(habits.habitRepositoryProvider);
      final duplicated = widget.habit.copyWith(
        id: repository.generateId(),
        name: '${widget.habit.name} (Copy)',
        createdAt: DateTime.now(),
      );
      
      await ref.read(habits.habitsProvider.notifier).addHabit(duplicated);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${duplicated.name}" has been created!'),
            backgroundColor: AppColors.greenPrimary,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error duplicating habit: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _archiveHabit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Habit'),
        content: Text('Are you sure you want to archive "${widget.habit.name}"? You can unarchive it later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref.read(habits.habitsProvider.notifier).archiveHabit(widget.habit.id);
        if (mounted) {
          Navigator.of(context).pop(true); // Return to list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${widget.habit.name}" has been archived'),
              backgroundColor: AppColors.orangePrimary,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error archiving habit: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _deleteHabit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${widget.habit.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref.read(habits.habitsProvider.notifier).deleteHabit(widget.habit.id);
        if (mounted) {
          Navigator.of(context).pop(true); // Return to list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${widget.habit.name}" has been deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting habit: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
