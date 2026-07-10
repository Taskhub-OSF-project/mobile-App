import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../task/data/repositories/task_repository.dart';
import '../../../task/data/models/task_models.dart';
import '../../../../shared/widgets/common_widgets.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();
  final _criteriaController = <TextEditingController>[];
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  String? _selectedCategory;
  bool _isLoading = false;

  final _categories = [
    'Lập trình',
    'Thiết kế',
    'Viết lách',
    'Marketing',
    'Nhập liệu',
    'Nghiên cứu',
    'Dịch thuật',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _addCriterion();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    for (final c in _criteriaController) {
      c.dispose();
    }
    super.dispose();
  }

  void _addCriterion() {
    setState(() {
      _criteriaController.add(TextEditingController());
    });
  }

  void _removeCriterion(int index) {
    if (_criteriaController.length > 1) {
      setState(() {
        _criteriaController[index].dispose();
        _criteriaController.removeAt(index);
      });
    }
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _deadline = date);
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    final criteria = _criteriaController
        .map((c) => c.text.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    if (criteria.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất một tiêu chí nghiệm thu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final request = CreateTaskRequest(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      budget: double.parse(_budgetController.text.trim()),
      deadline: _deadline.toIso8601String(),
      acceptanceCriteria: criteria,
    );

    final result =
        await ref.read(taskRepositoryProvider).createTask(request);

    if (result.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng công việc thành công!')),
      );
      context.pop();
    } else if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error?.message ?? 'Đăng công việc thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng công việc'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề công việc *',
                    hintText: 'VD: Tạo trang đăng nhập Flutter',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả chi tiết *',
                    hintText: 'Mô tả chi tiết công việc...',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Vui lòng nhập mô tả' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ngân sách (VND) *',
                    hintText: 'VD: 500000',
                    prefixText: '',
                    suffixText: 'VND',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập ngân sách';
                    if (double.tryParse(v.trim()) == null) return 'Vui lòng nhập số hợp lệ';
                    if (double.parse(v.trim()) < 1) return 'Ngân sách phải lớn hơn 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDeadline,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Hạn chót',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                        ),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiêu chí nghiệm thu',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton.icon(
                      onPressed: _addCriterion,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Thêm'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._criteriaController.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              hintText: 'Tiêu chí ${entry.key + 1}',
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        if (_criteriaController.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppTheme.error),
                            onPressed: () => _removeCriterion(entry.key),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createTask,
                    child: const Text('Đăng công việc', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
