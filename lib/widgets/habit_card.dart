import 'package:flutter/material.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.name,
    required this.category,
    required this.categoryColor,
    required this.startDate,
    required this.habitIcon,
    required this.streak,
    required this.completedToday,
    required this.onChanged,
    this.onTap,
    this.onLongPress,
  });

  final String name;
  final String category;
  final Color categoryColor;
  final String startDate;
  final IconData habitIcon;
  final int streak;
  final bool completedToday;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: completedToday ? 4 : 1,
      shadowColor: Colors.black12,
      color: completedToday
          ? Colors.blue.withValues(alpha: 0.15)
          : Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: completedToday
                      ? Colors.blue.withValues(alpha: 0.2)
                      : categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  habitIcon,
                  color: completedToday ? Colors.blue : categoryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bắt đầu: $startDate',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutBack,
                              ),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            Icons.local_fire_department_rounded,
                            key: ValueKey<bool>(completedToday),
                            size: 18,
                            color: completedToday
                                ? Colors.orange
                                : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$streak ngày',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: completedToday,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onChanged: (value) => onChanged(value ?? false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
