import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/search_models.dart';
import 'package:go_router/go_router.dart';

class FreelancerSearchCard extends StatelessWidget {
  final FreelancerSearchResponse freelancer;

  const FreelancerSearchCard({super.key, required this.freelancer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.push('/profile/${freelancer.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                backgroundImage: freelancer.avatarUrl != null
                    ? NetworkImage(freelancer.avatarUrl!)
                    : null,
                child: freelancer.avatarUrl == null
                    ? Text(
                        freelancer.fullName.isNotEmpty
                            ? freelancer.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      freelancer.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (freelancer.title != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        freelancer.title!,
                        style: TextStyle(
                            color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: freelancer.skills
                          .take(3)
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(s,
                                    style: const TextStyle(fontSize: 10)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        freelancer.averageRating?.toStringAsFixed(1) ?? 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${freelancer.completedTasks ?? 0} việc',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
