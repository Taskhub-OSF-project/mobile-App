import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/common_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authNotifierProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar & basic info
            CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              backgroundImage:
                  user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: user.isVerified == true
                    ? AppTheme.success.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user.isVerified == true)
                    const Icon(Icons.verified,
                        size: 16, color: AppTheme.success),
                  const SizedBox(width: 4),
                  Text(
                    user.role ?? '',
                    style: TextStyle(
                      color: user.isVerified == true
                          ? AppTheme.success
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatColumn(
                      label: 'Tasks Done',
                      value:
                          '${user.completedTasksAsFreelancer ?? user.completedTasksAsHirer ?? 0}',
                    ),
                    Container(
                        width: 1, height: 40, color: AppTheme.border),
                    _StatColumn(
                      label: 'Rating',
                      value: user.averageRatingAsFreelancer
                              ?.toStringAsFixed(1) ??
                          '-',
                    ),
                    Container(
                        width: 1, height: 40, color: AppTheme.border),
                    _StatColumn(
                      label: 'Reviews',
                      value:
                          '${user.totalReviewsAsFreelancer ?? user.totalReviewsAsHirer ?? 0}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Info section
            Card(
              child: Column(
                children: [
                  if (user.university != null)
                    _ProfileTile(
                      icon: Icons.account_balance_outlined,
                      label: 'University',
                      value: user.university!,
                    ),
                  if (user.major != null)
                    _ProfileTile(
                      icon: Icons.menu_book_outlined,
                      label: 'Major',
                      value: user.major!,
                    ),
                  if (user.age != null)
                    _ProfileTile(
                      icon: Icons.cake_outlined,
                      label: 'Age',
                      value: '${user.age} years old',
                    ),
                  if (user.dateOfBirth != null)
                    _ProfileTile(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date of Birth',
                      value: user.dateOfBirth!,
                    ),
                  if (user.title != null)
                    _ProfileTile(
                      icon: Icons.work_outline,
                      label: 'Title',
                      value: user.title!,
                    ),
                  if (user.bio != null)
                    _ProfileTile(
                      icon: Icons.info_outline,
                      label: 'Bio',
                      value: user.bio!,
                    ),
                  if (user.skills != null && user.skills!.isNotEmpty)
                    _ProfileTile(
                      icon: Icons.psychology_outlined,
                      label: 'Skills',
                      value: user.skills!.join(', '),
                    ),
                  if (user.languages != null && user.languages!.isNotEmpty)
                    _ProfileTile(
                      icon: Icons.language_outlined,
                      label: 'Languages',
                      value: user.languages!.join(', '),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.wallet_outlined),
                    title: const Text('Wallet'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/wallet'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.chat_outlined),
                    title: const Text('Messages'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/messages'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outlined),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Change password
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppTheme.error),
                    title: const Text('Logout',
                        style: TextStyle(color: AppTheme.error)),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.error,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref.read(authNotifierProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      subtitle: Text(value),
    );
  }
}
