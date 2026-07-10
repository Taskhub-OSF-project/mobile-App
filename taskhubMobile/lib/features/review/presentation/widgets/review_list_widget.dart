import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/review_models.dart';
import '../../../../shared/widgets/common_widgets.dart';
import 'package:go_router/go_router.dart';

class ReviewListWidget extends StatelessWidget {
  final List<ReviewResponse> reviews;

  const ReviewListWidget({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const EmptyState(
        icon: Icons.star_border,
        title: 'Chưa có đánh giá',
        subtitle: 'Người dùng này chưa nhận được đánh giá nào.',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      backgroundImage: review.reviewerAvatar != null
                          ? NetworkImage(review.reviewerAvatar!)
                          : null,
                      child: review.reviewerAvatar == null
                          ? Text(
                              review.reviewerName.isNotEmpty
                                  ? review.reviewerName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.reviewerName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _formatDate(review.createdAt),
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < review.rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(review.comment),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => context.push('/tasks/${review.taskId}'),
                  child: Text(
                    'Dự án: ${review.taskTitle}',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return '';
    }
  }
}
