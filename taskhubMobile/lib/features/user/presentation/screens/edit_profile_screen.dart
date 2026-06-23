import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../user/data/models/user_models.dart';
import '../../../../shared/widgets/common_widgets.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _universityController;
  late TextEditingController _majorController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _titleController;
  late TextEditingController _availabilityController;
  late TextEditingController _skillsController;
  late TextEditingController _languagesController;
  late TextEditingController _portfolioController;
  DateTime? _dateOfBirth;

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _universityController = TextEditingController(text: user?.university ?? '');
    _majorController = TextEditingController(text: user?.major ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _titleController = TextEditingController(text: user?.title ?? '');
    _availabilityController =
        TextEditingController(text: user?.availability ?? '');
    _skillsController =
        TextEditingController(text: user?.skills?.join(', ') ?? '');
    _languagesController =
        TextEditingController(text: user?.languages?.join(', ') ?? '');
    _portfolioController =
        TextEditingController(text: user?.portfolioUrl ?? '');
    if (user?.dateOfBirth != null) {
      _dateOfBirth = DateTime.tryParse(user!.dateOfBirth!);
    }
    _isLoading = true;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await ref.read(authNotifierProvider.notifier).refreshProfile();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _titleController.dispose();
    _availabilityController.dispose();
    _skillsController.dispose();
    _languagesController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 10),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  List<String> _parseCommaSeparated(String text) {
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final request = UserProfileUpdateRequest(
      fullName: _nameController.text.trim(),
      university: _universityController.text.trim().isEmpty
          ? null
          : _universityController.text.trim(),
      major:
          _majorController.text.trim().isEmpty ? null : _majorController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      availability: _availabilityController.text.trim().isEmpty
          ? null
          : _availabilityController.text.trim(),
      skills: _parseCommaSeparated(_skillsController.text),
      languages: _parseCommaSeparated(_languagesController.text),
      portfolioUrl: _portfolioController.text.trim().isEmpty
          ? null
          : _portfolioController.text.trim(),
      dateOfBirth: _dateOfBirth != null ? _formatDate(_dateOfBirth!) : null,
    );

    final repo = ref.read(userRepositoryProvider);
    final result = await repo.updateProfile(request);

    if (result.isSuccess && mounted) {
      await ref.read(authNotifierProvider.notifier).refreshProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      context.pop();
    } else if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result.error?.message ?? 'Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _universityController,
                      decoration:
                          const InputDecoration(labelText: 'University'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _majorController,
                      decoration: const InputDecoration(labelText: 'Major'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration:
                          const InputDecoration(labelText: 'Professional Title'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'Bio', alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _selectDateOfBirth,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            prefixIcon: const Icon(Icons.cake_outlined),
                            suffixIcon: const Icon(Icons.calendar_today_outlined),
                          ),
                          controller: TextEditingController(
                            text: _dateOfBirth != null
                                ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                : '',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _availabilityController,
                      decoration:
                          const InputDecoration(labelText: 'Availability'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(
                          labelText: 'Skills (comma-separated)'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _languagesController,
                      decoration: const InputDecoration(
                          labelText: 'Languages (comma-separated)'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _portfolioController,
                      decoration:
                          const InputDecoration(labelText: 'Portfolio URL'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
