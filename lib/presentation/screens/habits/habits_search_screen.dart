import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_log.dart';
import '../../providers/habits_provider.dart';
import '../../providers/habit_logs_provider.dart';
import '../../widgets/habit_card.dart';
import 'habit_detail_screen.dart';

class HabitsSearchScreen extends ConsumerStatefulWidget {
  const HabitsSearchScreen({super.key});

  @override
  ConsumerState<HabitsSearchScreen> createState() => _HabitsSearchScreenState();
}

class _HabitsSearchScreenState extends ConsumerState<HabitsSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSortBy = 'Name';
  bool _showArchived = false;

  final List<String> _categories = [
    'All',
    'Health & Fitness',
    'Learning & Education',
    'Work & Productivity',
    'Personal Care',
    'Social & Relationships',
    'Hobbies & Interests',
    'Spiritual & Mindfulness',
    'Other',
  ];

  final List<String> _sortOptions = [
    'Name',
    'Date Created',
    'Category',
    'Frequency',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Habit> _filterAndSortHabits(List<Habit> habits) {
    List<Habit> filtered = habits.where((habit) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!habit.name.toLowerCase().contains(query) &&
            !habit.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filter by category
      if (_selectedCategory != 'All' && habit.category != _selectedCategory) {
        return false;
      }

      // Filter by archived status
      if (!_showArchived && habit.isArchived) {
        return false;
      }
      if (_showArchived && !habit.isArchived) {
        return false;
      }

      return true;
    }).toList();

    // Sort habits
    switch (_selectedSortBy) {
      case 'Name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Date Created':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Category':
        filtered.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'Frequency':
        filtered.sort((a, b) => a.frequency.index.compareTo(b.frequency.index));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Habits'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search habits...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Filter Row
                Row(
                  children: [
                    // Category Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Sort Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSortBy,
                        decoration: InputDecoration(
                          labelText: 'Sort by',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                        ),
                        items: _sortOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSortBy = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Show Archived Toggle
                Row(
                  children: [
                    Checkbox(
                      value: _showArchived,
                      onChanged: (value) {
                        setState(() {
                          _showArchived = value ?? false;
                        });
                      },
                    ),
                    const Text('Show archived habits'),
                  ],
                ),
              ],
            ),
          ),

          // Results Section
          Expanded(
            child: habitsAsync.when(
              data: (habits) {
                final filteredHabits = _filterAndSortHabits(habits);

                if (filteredHabits.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty ? Icons.search_off : Icons.inbox,
                          size: 80,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _searchQuery.isNotEmpty 
                              ? 'No habits found for "$_searchQuery"'
                              : 'No habits found',
                          style: AppTextStyles.h5.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try adjusting your search or filters'
                              : 'Create your first habit to get started',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: filteredHabits.length,
                  itemBuilder: (context, index) {
                    final habit = filteredHabits[index];
                    return HabitCard(
                      habit: habit,
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HabitDetailScreen(habit: habit),
                          ),
                        );
                        
                        // Refresh habits list if habit was updated/deleted
                        if (result == true) {
                          ref.read(habitsProvider.notifier).refresh();
                        }
                      },
                      onCheck: () async {
                        try {
                          final repository = ref.read(habitLogRepositoryProvider);
                          final log = HabitLog(
                            id: repository.generateId(),
                            habitId: habit.id,
                            completedAt: DateTime.now(),
                            value: habit.goalType != HabitGoalType.simple ? habit.goalValue : null,
                            note: null,
                            isCompleted: true,
                            createdAt: DateTime.now(),
                            metadata: {},
                          );
                          
                          await ref.read(habitLogsProvider.notifier).addLog(log);
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Marked "${habit.name}" as completed!'),
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
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppColors.redPrimary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Error loading habits',
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.redPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      error.toString(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(habitsProvider.notifier).refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
