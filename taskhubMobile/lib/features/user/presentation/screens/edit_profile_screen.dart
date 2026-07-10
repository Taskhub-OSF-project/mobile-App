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
  late TextEditingController _skillsController;
  late TextEditingController _languagesController;
  late TextEditingController _portfolioController;
  DateTime? _dateOfBirth;

  bool _isSaving = false;
  String? _error;

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
    _skillsController =
        TextEditingController(text: user?.skills?.join(', ') ?? '');
    _languagesController =
        TextEditingController(text: user?.languages?.join(', ') ?? '');
    _portfolioController =
        TextEditingController(text: user?.portfolioUrl ?? '');
    if (user?.dateOfBirth != null) {
      _dateOfBirth = DateTime.tryParse(user!.dateOfBirth!);
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

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final request = UserProfileUpdateRequest(
        fullName: _nameController.text.trim(),
        university: _universityController.text.trim().isNotEmpty ? _universityController.text.trim() : null,
        major: _majorController.text.trim().isNotEmpty ? _majorController.text.trim() : null,
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        skills: _skillsController.text.trim().isNotEmpty ? _parseCommaSeparated(_skillsController.text) : null,
        portfolioUrl: _portfolioController.text.trim().isNotEmpty ? _portfolioController.text.trim() : null,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null,
        languages: _languagesController.text.trim().isNotEmpty ? _parseCommaSeparated(_languagesController.text) : null,
        dateOfBirth: _dateOfBirth != null ? _formatDate(_dateOfBirth!) : null,
      );

      final repo = ref.read(userRepositoryProvider);
      final result = await repo.updateProfile(request);

      if (result.isSuccess) {
        await ref.read(authNotifierProvider.notifier).refreshProfile();
        if (mounted) {
          context.pop();
        }
      } else {
        setState(() {
          _error = result.error?.message ?? 'Lưu hồ sơ thất bại';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Đã xảy ra lỗi: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Lưu',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                ErrorDisplay(message: _error!),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Chức danh',
                  prefixIcon: Icon(Icons.work_outline),
                  hintText: 'VD: Sinh viên IT, Lập trình viên Flutter',
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDateOfBirth,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày sinh',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _dateOfBirth == null ? 'Chọn ngày sinh' : _formatDate(_dateOfBirth!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              const Text(
                'Học vấn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _universityController,
                decoration: const InputDecoration(
                  labelText: 'Trường đại học',
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _majorController,
                decoration: const InputDecoration(
                  labelText: 'Chuyên ngành',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thông tin thêm',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Giới thiệu bản thân',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Kỹ năng (phân cách bằng dấu phẩy)',
                  prefixIcon: Icon(Icons.psychology_outlined),
                  hintText: 'VD: Flutter, React, Tiếng Anh',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _languagesController,
                decoration: const InputDecoration(
                  labelText: 'Ngôn ngữ (phân cách bằng dấu phẩy)',
                  prefixIcon: Icon(Icons.language_outlined),
                  hintText: 'VD: Tiếng Anh, Tiếng Việt',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _portfolioController,
                decoration: const InputDecoration(
                  labelText: 'Đường dẫn Portfolio',
                  prefixIcon: Icon(Icons.link_outlined),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
