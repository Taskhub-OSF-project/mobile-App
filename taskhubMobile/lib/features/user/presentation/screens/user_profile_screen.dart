import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../user/data/repositories/user_repository.dart';
import '../../../user/data/models/user_models.dart';
import '../../../../shared/widgets/common_widgets.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final int userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  UserProfileResponse? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result =
        await ref.read(userRepositoryProvider).getProfile(widget.userId);
    if (result.isSuccess && mounted) {
      setState(() {
        _user = result.data;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _error = result.error?.message ?? 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorDisplay(message: _error!, onRetry: _loadUser)
              : _user == null
                  ? const EmptyState(
                      icon: Icons.person_off_outlined,
                      title: 'User not found',
                    )
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final user = _user!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(user.fullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(user.role ?? '',
              style: TextStyle(color: Colors.grey[600])),
          if (user.university != null) ...[
            const SizedBox(height: 4),
            Text(user.university!,
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatColumn(
                    label: 'Rating',
                    value: user.averageRatingAsFreelancer
                            ?.toStringAsFixed(1) ??
                        '-',
                  ),
                  Container(width: 1, height: 40, color: AppTheme.border),
                  _StatColumn(
                    label: 'Completed',
                    value:
                        '${user.completedTasksAsFreelancer ?? user.completedTasksAsHirer ?? 0}',
                  ),
                  Container(width: 1, height: 40, color: AppTheme.border),
                  _StatColumn(
                    label: 'Reviews',
                    value:
                        '${user.totalReviewsAsFreelancer ?? user.totalReviewsAsHirer ?? 0}',
                  ),
                ],
              ),
            ),
          ),
          if (user.bio != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('About',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(user.bio!),
                  ],
                ),
              ),
            ),
          ],
          if (user.skills != null && user.skills!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Skills',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.skills!
                          .map((s) => Chip(
                                label: Text(s),
                                backgroundColor:
                                    AppTheme.primary.withValues(alpha: 0.1),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
