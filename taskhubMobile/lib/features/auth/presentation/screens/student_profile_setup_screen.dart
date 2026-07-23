import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../user/data/models/user_models.dart';

class StudentProfileSetupScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final int? age;

  const StudentProfileSetupScreen({
    super.key,
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    this.age,
  });

  @override
  ConsumerState<StudentProfileSetupScreen> createState() =>
      _StudentProfileSetupScreenState();
}

class _StudentProfileSetupScreenState
    extends ConsumerState<StudentProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _schoolController = TextEditingController();
  final _majorController = TextEditingController();
  final _titleController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _portfolioUrlController = TextEditingController();
  
  String _selectedYear = 'Năm 3';
  String _selectedAvailability = 'Dưới 20 giờ/tuần (bán thời gian)';
  String? _cvFileName;

  final List<String> _skills = [];
  final List<String> _languages = [];
  final _skillInputController = TextEditingController();
  final _languageInputController = TextEditingController();

  final List<String> _yearOptions = [
    'Năm 1', 'Năm 2', 'Năm 3', 'Năm 4', 'Năm 5', 'Đã tốt nghiệp'
  ];

  final List<String> _availabilityOptions = [
    'Dưới 20 giờ/tuần (bán thời gian)',
    'Trên 20 giờ/tuần',
    'Toàn thời gian',
    'Chỉ làm cuối tuần'
  ];

  @override
  void dispose() {
    _schoolController.dispose();
    _majorController.dispose();
    _titleController.dispose();
    _hourlyRateController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _certificationsController.dispose();
    _portfolioUrlController.dispose();
    _skillInputController.dispose();
    _languageInputController.dispose();
    super.dispose();
  }

  int get _progress {
    int filledFields = 0;
    int totalFields = 11;
    if (_schoolController.text.isNotEmpty) filledFields++;
    if (_majorController.text.isNotEmpty) filledFields++;
    if (_titleController.text.isNotEmpty) filledFields++;
    if (_hourlyRateController.text.isNotEmpty) filledFields++;
    if (_bioController.text.isNotEmpty) filledFields++;
    if (_experienceController.text.isNotEmpty) filledFields++;
    if (_skills.isNotEmpty) filledFields++;
    if (_languages.isNotEmpty) filledFields++;
    if (_certificationsController.text.isNotEmpty) filledFields++;
    if (_portfolioUrlController.text.isNotEmpty) filledFields++;
    if (_cvFileName != null) filledFields++;
    return (filledFields / totalFields * 100).round();
  }

  void _addSkill(String value) {
    if (value.trim().isNotEmpty && !_skills.contains(value.trim())) {
      setState(() {
        _skills.add(value.trim());
        _skillInputController.clear();
      });
    }
  }

  void _addLanguage(String value) {
    if (value.trim().isNotEmpty && !_languages.contains(value.trim())) {
      setState(() {
        _languages.add(value.trim());
        _languageInputController.clear();
      });
    }
  }

  Future<void> _pickCv() async {
    // Mock CV picker
    setState(() {
      _cvFileName = 'CV_${widget.fullName.replaceAll(' ', '_')}.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã chọn CV: $_cvFileName')),
    );
  }

  Future<void> _submit({bool skip = false}) async {
    // Register basic account first
    final success = await ref.read(authNotifierProvider.notifier).register(
          email: widget.email,
          password: widget.password,
          fullName: widget.fullName,
          role: 'STUDENT',
          phoneNumber: widget.phoneNumber.isEmpty ? null : widget.phoneNumber,
          age: widget.age,
        );

    if (success && mounted) {
      if (!skip) {
        // Prepare data for Update Profile
        final updateReq = UserProfileUpdateRequest(
          school: _schoolController.text.trim(),
          university: _schoolController.text.trim(), // API fallback
          major: _majorController.text.trim(),
          title: _titleController.text.trim(),
          hourlyRate: _hourlyRateController.text.trim(),
          availability: _selectedAvailability,
          bio: _bioController.text.trim(),
          experience: _experienceController.text.trim(),
          certifications: _certificationsController.text.trim().split('\n').where((e) => e.isNotEmpty).toList(),
          portfolioUrl: _portfolioUrlController.text.trim(),
          skills: _skills,
          languages: _languages,
        );
        
        final userRepo = ref.read(userRepositoryProvider);
        await userRepo.updateProfile(updateReq);
        // Refresh profile in AuthNotifier
        await ref.read(authNotifierProvider.notifier).refreshProfile();
      }
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Quay lại thông tin tài khoản', style: TextStyle(fontSize: 16)),
      ),
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hoàn thiện hồ sơ sinh viên',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hồ sơ càng rõ ràng, nhà tuyển dụng càng dễ chọn bạn cho công việc phù hợp.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                
                // Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mức độ hoàn thiện', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$_progress%'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _progress / 100,
                  backgroundColor: Colors.grey[200],
                  color: AppTheme.primary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 32),

                // Form fields
                TextFormField(
                  controller: _schoolController,
                  decoration: const InputDecoration(labelText: 'Trường học (VD: ĐH Bách Khoa)'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedYear,
                  decoration: const InputDecoration(labelText: 'Năm học'),
                  items: _yearOptions.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedYear = val);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _majorController,
                  decoration: const InputDecoration(labelText: 'Ngành học'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Tiêu đề chuyên môn (VD: Mobile App Developer)'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hourlyRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Thù lao mong muốn (đ/giờ)'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedAvailability,
                  decoration: const InputDecoration(labelText: 'Thời gian cam kết'),
                  items: _availabilityOptions.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAvailability = val);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Giới thiệu ngắn (Tóm tắt điểm mạnh...)'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Kinh nghiệm và dự án (Mỗi dòng 1 mục)'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                
                // Skills Input
                TextFormField(
                  controller: _skillInputController,
                  decoration: const InputDecoration(
                    labelText: 'Kỹ năng chính',
                    hintText: 'Nhập kỹ năng rồi bấm Enter',
                  ),
                  onFieldSubmitted: _addSkill,
                ),
                if (_skills.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 8,
                      children: _skills.map((s) => Chip(
                        label: Text(s),
                        onDeleted: () => setState(() => _skills.remove(s)),
                      )).toList(),
                    ),
                  ),
                const SizedBox(height: 16),

                // Languages Input
                TextFormField(
                  controller: _languageInputController,
                  decoration: const InputDecoration(
                    labelText: 'Ngoại ngữ',
                    hintText: 'Nhập ngoại ngữ rồi bấm Enter',
                  ),
                  onFieldSubmitted: _addLanguage,
                ),
                if (_languages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 8,
                      children: _languages.map((l) => Chip(
                        label: Text(l),
                        onDeleted: () => setState(() => _languages.remove(l)),
                      )).toList(),
                    ),
                  ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _certificationsController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Chứng chỉ và giải thưởng (Mỗi dòng 1 mục)'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _portfolioUrlController,
                  decoration: const InputDecoration(labelText: 'Portfolio / Behance / GitHub / LinkedIn'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // CV Upload Mockup
                InkWell(
                  onTap: _pickCv,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: _cvFileName != null ? Colors.green : Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: _cvFileName != null ? Colors.green.withOpacity(0.05) : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _cvFileName != null ? Icons.check_circle : Icons.upload_file,
                          color: _cvFileName != null ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _cvFileName ?? 'CV đính kèm (PDF, tối đa 5MB)',
                            style: TextStyle(
                              color: _cvFileName != null ? Colors.green : Colors.grey[700],
                              fontWeight: _cvFileName != null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: authState.isLoading ? null : () => _submit(skip: true),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Bỏ qua, cập nhật sau', textAlign: TextAlign.center),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : () => _submit(skip: false),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Hoàn tất đăng ký', textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
