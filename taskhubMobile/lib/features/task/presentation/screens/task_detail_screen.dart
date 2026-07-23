import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../task/data/repositories/task_repository.dart';
import '../../../task/data/models/task_models.dart';
import '../../../review/data/repositories/review_repository.dart';
import '../../../review/data/models/review_models.dart';
import '../../../../shared/widgets/common_widgets.dart';
import 'package:file_picker/file_picker.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final int taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  TaskResponse? _task;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await ref.read(taskRepositoryProvider).getTask(widget.taskId);
    if (result.isSuccess && mounted) {
      setState(() {
        _task = result.data;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _error = result.error?.message ?? 'Failed to load task';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        actions: [
          if (_task != null) ...[
            IconButton(
              icon: const Icon(Icons.chat_outlined),
              onPressed: () async {
                final repo = ref.read(messagingRepositoryProvider);
                final result =
                    await repo.getOrCreateConversation(widget.taskId);
                if (result.isSuccess && mounted) {
                  context.push('/messages/${result.data!.id}');
                }
              },
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorDisplay(message: _error!, onRetry: _loadTask)
              : _task == null
                  ? const EmptyState(
                      icon: Icons.error_outline,
                      title: 'Không tìm thấy công việc',
                    )
                  : _buildContent(context, currentUser),
      bottomNavigationBar: _task != null ? _buildBottomBar(context) : null,
    );
  }

  Widget _buildContent(BuildContext context, dynamic currentUser) {
    final task = _task!;
    final isHirer = currentUser?.id == task.hirerId;
    final isAssignee = currentUser?.id == task.assignedToId;

    return RefreshIndicator(
      onRefresh: _loadTask,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusBadge(status: task.status ?? 'DRAFT'),
              ],
            ),
            const SizedBox(height: 16),

            // Budget & Deadline
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.attach_money,
                        label: 'Ngân sách',
                        value: '${task.budget.toStringAsFixed(0)} VND',
                        valueColor: AppTheme.accent,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.border,
                    ),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.calendar_today,
                        label: 'Hạn chót',
                        value: task.deadline?.split('T').first ?? '-',
                        valueColor: AppTheme.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Hirer info
            GestureDetector(
              onTap: () => context.push('/user/${task.hirerId}'),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    child: Text(
                      task.hirerName.isNotEmpty
                          ? task.hirerName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(task.hirerName),
                  subtitle: const Text('Người thuê'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Mô tả chi tiết',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(task.description, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 24),

            // Acceptance Criteria
            if (task.acceptanceCriteria != null &&
                task.acceptanceCriteria!.isNotEmpty) ...[
              Text(
                'Tiêu chí nghiệm thu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...task.acceptanceCriteria!.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 20, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value.description,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Applicants (for hirers)
            if (isHirer &&
                task.applicants != null &&
                task.applicants!.isNotEmpty) ...[
              Text(
                'Ứng viên (${task.applicants!.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...task.applicants!.map((app) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  child: Text(app.studentName.isNotEmpty ? app.studentName[0].toUpperCase() : '?'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        app.studentName.isNotEmpty ? app.studentName : 'Ẩn danh',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      if (app.studentUniversity != null && app.studentUniversity!.isNotEmpty)
                                        Text(
                                          app.studentUniversity!,
                                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                app.status == 'PENDING'
                                    ? ElevatedButton(
                                        onPressed: () async {
                                          final repo = ref.read(taskRepositoryProvider);
                                          await repo.acceptApplication(app.id);
                                          _loadTask();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          minimumSize: Size.zero, // Override global double.infinity
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          child: Text('Chấp nhận'),
                                        ),
                                      )
                                    : StatusBadge(status: app.status ?? 'PENDING'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.person_outline, size: 16),
                                  label: const Text('Hồ sơ'),
                                  style: OutlinedButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                  onPressed: () {
                                    context.push('/user/${app.studentId}');
                                  },
                                ),
                                if (app.coverLetter != null && app.coverLetter!.isNotEmpty)
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.description_outlined, size: 16),
                                    label: const Text('CV / Lời ngỏ'),
                                    style: OutlinedButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('CV / Lời ngỏ'),
                                          content: SingleChildScrollView(
                                            child: Text(app.coverLetter!),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => context.pop(),
                                              child: const Text('Đóng'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                  label: const Text('Nhắn tin'),
                                  style: OutlinedButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                  onPressed: () async {
                                    final repo = ref.read(messagingRepositoryProvider);
                                    final result = await repo.getOrCreateConversationWithUser(widget.taskId, app.studentId);
                                    if (!context.mounted) return;
                                    if (result.isSuccess) {
                                      context.push('/messages/${result.data!.id}');
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(result.error?.message ?? 'Lỗi tạo trò chuyện')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  )),
            ],

            // Safe Escrow Commitment
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: AppTheme.surfaceElevated,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cam kết an toàn', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.lock_outline, size: 20, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Tiền được giữ trong quỹ ký quỹ.', style: TextStyle(color: Colors.grey[700], fontSize: 13))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Tiêu chí được khóa trước khi bắt đầu.', style: TextStyle(color: Colors.grey[700], fontSize: 13))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            if (task.status == 'SUBMITTED')
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Bài đã được gửi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          SizedBox(height: 4),
                          Text('Người thuê đang xem xét kết quả và tiêu chí nghiệm thu.', style: TextStyle(color: Colors.blue, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (task.status == 'DISPUTED')
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Công việc đang tranh chấp', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          SizedBox(height: 4),
                          Text('Hãy tiếp tục trao đổi trong không gian làm việc; quản trị viên sẽ xử lý.', style: TextStyle(color: Colors.red, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _showSubmitDialog() async {
    final notesController = TextEditingController();
    String? pickedFilePath;
    String? pickedFileName;
    String? uploadedFileUrl;
    bool isUploading = false;
    bool isCheckingAi = false;
    SubmissionAIResult? aiResult;
    String? errorText;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nộp sản phẩm'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Ghi chú (Tùy chọn)'),
                      maxLines: 3,
                      enabled: !isUploading && !isCheckingAi,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pickedFileName ?? 'Chưa chọn file nào (Tùy chọn)',
                            style: TextStyle(
                              color: pickedFileName != null ? AppTheme.textPrimary : AppTheme.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          icon: const Icon(Icons.attach_file, size: 16),
                          label: const Text('Chọn File'),
                          onPressed: (isUploading || isCheckingAi)
                              ? null
                              : () async {
                                  final result = await FilePicker.pickFiles();
                                  if (result != null && result.files.single.path != null) {
                                    setState(() {
                                      pickedFilePath = result.files.single.path;
                                      pickedFileName = result.files.single.name;
                                      uploadedFileUrl = null;
                                      aiResult = null;
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 16),
                      Text(errorText!, style: const TextStyle(color: Colors.red)),
                    ],
                    if (aiResult != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: aiResult!.canSubmit ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          border: Border.all(color: aiResult!.canSubmit ? Colors.green : Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.auto_awesome, color: aiResult!.canSubmit ? Colors.green : Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    aiResult!.canSubmit ? 'Kết quả AI: Đạt yêu cầu' : 'Kết quả AI: Cần bổ sung',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: aiResult!.canSubmit ? Colors.green : Colors.orange),
                                  ),
                                ),
                              ],
                            ),
                            if (aiResult!.summary != null && aiResult!.summary!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(aiResult!.summary!, style: const TextStyle(fontSize: 13)),
                            ],
                            if (aiResult!.criteriaResults != null && aiResult!.criteriaResults!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...aiResult!.criteriaResults!.map((c) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      c.status == 'met' ? Icons.check_circle : (c.status == 'partial' ? Icons.info : Icons.cancel),
                                      size: 16,
                                      color: c.status == 'met' ? Colors.green : (c.status == 'partial' ? Colors.orange : Colors.red),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        c.evidence ?? c.criteria ?? '',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (isUploading || isCheckingAi) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                          const SizedBox(width: 12),
                          Text(isUploading ? 'Đang tải file lên...' : 'AI đang kiểm tra...'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: (isUploading || isCheckingAi) ? null : () => Navigator.pop(ctx, null),
                child: const Text('Hủy')
              ),
              OutlinedButton(
                onPressed: (isUploading || isCheckingAi)
                    ? null
                    : () async {
                        setState(() {
                          isCheckingAi = true;
                          errorText = null;
                        });
                        
                        try {
                          final repo = ref.read(taskRepositoryProvider);
                          String? fileUrlToUse = uploadedFileUrl;
                          
                          if (pickedFilePath != null && uploadedFileUrl == null) {
                            setState(() { isUploading = true; isCheckingAi = false; });
                            final uploadRes = await repo.uploadFile(widget.taskId, pickedFilePath!);
                            if (uploadRes.isSuccess) {
                              fileUrlToUse = uploadRes.dataOrNull;
                              uploadedFileUrl = fileUrlToUse;
                            } else {
                              setState(() {
                                isUploading = false;
                                errorText = 'Upload thất bại: ${uploadRes.errorOrNull?.message ?? 'Lỗi không xác định'}';
                              });
                              return;
                            }
                            setState(() { isUploading = false; isCheckingAi = true; });
                          }
                          
                          final precheckRes = await repo.precheckSubmission(
                            widget.taskId, 
                            SubmissionRequest(
                              fileUrl: fileUrlToUse,
                              notes: notesController.text.trim(),
                            )
                          );
                          
                          if (precheckRes.isSuccess) {
                            setState(() {
                              aiResult = precheckRes.data;
                            });
                          } else {
                            setState(() {
                              errorText = 'Kiểm tra AI thất bại: ${precheckRes.errorOrNull?.message ?? 'Lỗi không xác định'}';
                            });
                          }
                        } catch (e) {
                          setState(() {
                            errorText = 'Lỗi kiểm tra AI: $e';
                          });
                        } finally {
                          setState(() {
                            isCheckingAi = false;
                            isUploading = false;
                          });
                        }
                      },
                child: const Text('Kiểm tra AI'),
              ),
              ElevatedButton(
                onPressed: (isUploading || isCheckingAi || aiResult == null || !aiResult!.canSubmit)
                    ? null
                    : () {
                        Navigator.pop(ctx, {
                          'notes': notesController.text.trim(),
                          'fileUrl': uploadedFileUrl,
                        });
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Nộp'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null && mounted) {
      final repo = ref.read(taskRepositoryProvider);
      final notes = result['notes'] as String;
      final fileUrl = result['fileUrl'] as String?;
      
      final res = await repo.submitWork(
        widget.taskId, 
        notes.isNotEmpty ? notes : null, 
        fileUrl != null ? [fileUrl] : null
      );
      
      if (res.isSuccess) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nộp sản phẩm thành công')));
        _loadTask();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorOrNull?.message ?? 'Lỗi không xác định')));
      }
    }
  }

  Future<void> _showRevisionDialog() async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yêu cầu chỉnh sửa'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Nêu rõ phần cần chỉnh sửa...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, reasonController.text.trim()),
            child: const Text('Gửi'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      final repo = ref.read(taskRepositoryProvider);
      final res = await repo.requestRevision(widget.taskId, result);
      if (res.isSuccess) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi yêu cầu chỉnh sửa')));
        _loadTask();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorOrNull?.message ?? 'Lỗi không xác định')));
      }
    }
  }

  Future<void> _showDisputeDialog() async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mở khiếu nại'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Lý do khiếu nại...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, reasonController.text.trim()),
            child: const Text('Khiếu nại'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      final repo = ref.read(taskRepositoryProvider);
      final res = await repo.disputeTask(widget.taskId, result);
      if (res.isSuccess) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi khiếu nại')));
        _loadTask();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorOrNull?.message ?? 'Lỗi không xác định')));
      }
    }
  }

  Future<void> _showApplyDialog() async {
    final coverLetterController = TextEditingController();
    bool isSubmitting = false;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Ứng tuyển công việc'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Giới thiệu kinh nghiệm liên quan và cách bạn sẽ hoàn thành yêu cầu.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: coverLetterController,
                    decoration: const InputDecoration(labelText: 'Lời ngỏ (CV/Kinh nghiệm)...'),
                    maxLines: 4,
                    enabled: !isSubmitting,
                  ),
                  if (isSubmitting) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx, null),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        if (coverLetterController.text.trim().length < 20) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập ít nhất 20 ký tự')));
                          return;
                        }
                        Navigator.pop(ctx, coverLetterController.text.trim());
                      },
                child: const Text('Gửi hồ sơ'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      final repo = ref.read(taskRepositoryProvider);
      final res = await repo.applyToTask(widget.taskId, result);
      if (res.isSuccess) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ứng tuyển thành công!')));
        _loadTask();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorOrNull?.message ?? 'Lỗi ứng tuyển')));
      }
    }
  }

  Future<void> _showReviewDialog() async {
    final commentController = TextEditingController();
    int rating = 5;
    bool isSubmitting = false;

    final result = await showDialog<CreateReviewRequest>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Đánh giá người thuê'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: isSubmitting ? null : () => setState(() => rating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(labelText: 'Chia sẻ trải nghiệm hợp tác...'),
                    maxLines: 3,
                    enabled: !isSubmitting,
                  ),
                  if (isSubmitting) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx, null),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        Navigator.pop(ctx, CreateReviewRequest(
                          taskId: widget.taskId,
                          targetUserId: _task!.hirerId,
                          reviewType: 'HIRER',
                          rating: rating.toDouble(),
                          comment: commentController.text.trim(),
                        ));
                      },
                child: const Text('Gửi đánh giá'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null && mounted) {
      final repo = ref.read(reviewRepositoryProvider);
      final res = await repo.createReview(result);
      if (res.isSuccess) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi đánh giá')));
        _loadTask();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorOrNull?.message ?? 'Lỗi gửi đánh giá')));
      }
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    final task = _task!;
    final currentUser = ref.watch(currentUserProvider);
    final isHirer = currentUser?.id == task.hirerId;
    final isAssignee = currentUser?.id == task.assignedToId;
    final isStudent = currentUser?.isStudent ?? false;
    final status = task.status ?? 'DRAFT';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Hirer actions
            if (isHirer) ...[
              if (status == 'DRAFT') ...[
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                    onPressed: () async {
                      final repo = ref.read(taskRepositoryProvider);
                      await repo.lockTask(task.id);
                      _loadTask();
                    },
                    child: const Text('Khóa & Tự động duyệt'),
                  ),
                ),
              ],
              if (status == 'LOCKED') ...[
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                    onPressed: () async {
                      final repo = ref.read(taskRepositoryProvider);
                      await repo.fundEscrow(task.id);
                      _loadTask();
                    },
                    child: const Text('Nạp Escrow'),
                  ),
                ),
              ],
              if (status == 'ESCROW_FUNDED')
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                    onPressed: () async {
                      final repo = ref.read(taskRepositoryProvider);
                      await repo.publishTask(task.id);
                      _loadTask();
                    },
                    child: const Text('Đăng cho SV ứng tuyển'),
                  ),
                ),
              if (status == 'SUBMITTED') ...[
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52), backgroundColor: Colors.green),
                    onPressed: () async {
                      final repo = ref.read(taskRepositoryProvider);
                      await repo.approveSubmission(task.id);
                      _loadTask();
                    },
                    child: const Text('Chấp nhận & Giải ngân'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52), padding: EdgeInsets.zero),
                    onPressed: _showRevisionDialog,
                    child: const Text('Sửa'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: _showDisputeDialog,
                    child: const Text('Khiếu nại'),
                  ),
                ),
              ],
              if (status == 'DISPUTED') ...[
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52), backgroundColor: Colors.green),
                    onPressed: () async {
                      final repo = ref.read(taskRepositoryProvider);
                      await repo.releaseEscrow(task.id);
                      _loadTask();
                    },
                    child: const Text('Giải ngân'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                    onPressed: () async {
                      final repo = ref.read(taskRepositoryProvider);
                      await repo.refundEscrow(task.id);
                      _loadTask();
                    },
                    child: const Text('Hoàn tiền Escrow'),
                  ),
                ),
              ],
            ],
            // Student actions
            if (isAssignee) ...[
              if (status == 'IN_PROGRESS' || status == 'SUBMITTED' || status == 'DISPUTED')
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                    onPressed: _showSubmitDialog,
                    child: const Text('Nộp / Sửa sản phẩm'),
                  ),
                ),
              if (status == 'COMPLETED')
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                    onPressed: _showReviewDialog,
                    child: const Text('Gửi đánh giá'),
                  ),
                ),
            ],
            // Student can apply
            if (isStudent && !isAssignee && !isHirer) ...[
              if (status == 'ACTIVE' && !(task.applicants?.any((app) => app.studentId == currentUser?.id) ?? false))
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                    onPressed: _showApplyDialog,
                    child: const Text('Ứng tuyển'),
                  ),
                ),
              if (task.applicants?.any((app) => app.studentId == currentUser?.id) ?? false)
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Hồ sơ đã gửi và đang chờ phản hồi', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.primary),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
