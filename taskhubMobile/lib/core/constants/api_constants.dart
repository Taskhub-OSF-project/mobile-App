class ApiConstants {
  ApiConstants._();

  // Update this to your backend's IP/domain
  static const String baseUrl = 'http://10.0.2.2:8080'; // Android emulator localhost
  static const String apiPrefix = '/api';

  // Auth
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String refresh = '$apiPrefix/auth/refresh';
  static const String logout = '$apiPrefix/auth/logout';
  static const String logoutAll = '$apiPrefix/auth/logout-all';
  static const String forgotPassword = '$apiPrefix/auth/forgot-password';
  static const String resetPassword = '$apiPrefix/auth/reset-password';
  static const String verifyEmail = '$apiPrefix/auth/verify-email';
  static const String loginPhone = '$apiPrefix/auth/login-phone';
  static const String requestPhoneOtp = '$apiPrefix/auth/request-phone-otp';
  static const String verifyPhoneOtp = '$apiPrefix/auth/verify-phone-otp';
  static const String forgotPasswordPhone = '$apiPrefix/auth/forgot-password-phone';
  static const String resetPasswordOtp = '$apiPrefix/auth/reset-password-otp';

  // Users
  static const String me = '$apiPrefix/users/me';
  static String userById(int id) => '$apiPrefix/users/$id';
  static const String changePassword = '$apiPrefix/users/change-password';
  static const String setAvailability = '$apiPrefix/users/me/availability';
  static const String switchRole = '$apiPrefix/users/switch-role';

  // Tasks
  static const String tasks = '$apiPrefix/tasks';
  static String taskById(int id) => '$apiPrefix/tasks/$id';
  static const String myTasks = '$apiPrefix/tasks/mine';
  static const String availableTasks = '$apiPrefix/tasks/available';
  static String lockTask(int id) => '$apiPrefix/tasks/$id/lock';
  static String publishTask(int id) => '$apiPrefix/tasks/$id/publish';
  static String completeTask(int id) => '$apiPrefix/tasks/$id/complete';
  static String patchTask(int id) => '$apiPrefix/tasks/$id';
  static String deleteTask(int id) => '$apiPrefix/tasks/$id';
  static String validateCriteria(int id) => '$apiPrefix/tasks/$id/validate';
  static const String validateCriteriaDraft = '$apiPrefix/tasks/validate-criteria';
  static String disputeTask(int id) => '$apiPrefix/tasks/$id/dispute';
  static String disputeReport(int id) => '$apiPrefix/tasks/$id/dispute/report';
  static String resolveDispute(int id) => '$apiPrefix/tasks/$id/dispute/resolve';
  static String revision(int id) => '$apiPrefix/tasks/$id/revision';
  static String taskMilestones(int taskId) => '$apiPrefix/tasks/$taskId/milestones';

  // Escrow
  static String fundEscrow(int taskId) => '$apiPrefix/escrow/fund/$taskId';
  static String releaseEscrow(int taskId) => '$apiPrefix/escrow/release/$taskId';
  static String refundEscrow(int taskId) => '$apiPrefix/escrow/refund/$taskId';

  // Applications
  static String applyToTask(int taskId) => '$apiPrefix/applications/task/$taskId';
  static String acceptApplication(int id) => '$apiPrefix/applications/$id/accept';
  static String taskApplications(int taskId) => '$apiPrefix/applications/task/$taskId';
  static const String myApplications = '$apiPrefix/applications/mine';
  static const String myAppliedTasks = '$apiPrefix/applications/my-applied-tasks';

  // Submissions
  static String submitTask(int taskId) => '$apiPrefix/submissions/task/$taskId';
  static String precheckTask(int taskId) => '$apiPrefix/submissions/task/$taskId/precheck';
  static String requestRevision(int taskId) => '$apiPrefix/submissions/task/$taskId/revision';
  static String revisions(int taskId) => '$apiPrefix/submissions/task/$taskId/revisions';
  static String approveSubmission(int taskId) => '$apiPrefix/submissions/task/$taskId/approve';
  static String taskSubmissions(int taskId) => '$apiPrefix/submissions/task/$taskId';
  static String latestSubmission(int taskId) => '$apiPrefix/submissions/task/$taskId/latest';

  // Wallet
  static const String walletBalance = '$apiPrefix/wallet/balance';
  static const String walletReadiness = '$apiPrefix/wallet/readiness/create-task';
  static const String walletDeposit = '$apiPrefix/wallet/deposit';
  static const String walletWithdraw = '$apiPrefix/wallet/withdraw';
  static const String walletTransactions = '$apiPrefix/wallet/transactions';
  static const String walletTransactionsPaged = '$apiPrefix/wallet/transactions/paged';

  // Notifications
  static const String notifications = '$apiPrefix/notifications';
  static const String unreadNotifications = '$apiPrefix/notifications/unread';
  static const String unreadCount = '$apiPrefix/notifications/unread/count';
  static String markRead(int id) => '$apiPrefix/notifications/$id/read';
  static const String markAllRead = '$apiPrefix/notifications/read-all';

  // Messaging
  static const String conversations = '$apiPrefix/messaging/conversations';
  static const String conversationsPaged = '$apiPrefix/messaging/conversations/paged';
  static String createConversation(int taskId) => '$apiPrefix/messaging/conversations/task/$taskId';
  static String sendMessage(int convId) => '$apiPrefix/messaging/conversations/$convId/messages';
  static String getMessages(int convId) => '$apiPrefix/messaging/conversations/$convId/messages';
  static String markConversationRead(int convId) => '$apiPrefix/messaging/conversations/$convId/read';
  static const String unreadMessageCount = '$apiPrefix/messaging/unread/count';

  // Portfolio
  static const String myPortfolio = '$apiPrefix/portfolio/me';
  static String userPortfolio(int userId) => '$apiPrefix/portfolio/user/$userId';
  static const String createPortfolioItem = '$apiPrefix/portfolio';
  static String updatePortfolioItem(int itemId) => '$apiPrefix/portfolio/$itemId';
  static String deletePortfolioItem(int itemId) => '$apiPrefix/portfolio/$itemId';
  static const String reorderPortfolio = '$apiPrefix/portfolio/reorder';

  // Reviews
  static String createReview(int taskId) => '$apiPrefix/reviews/task/$taskId';
  static String userReviews(int userId) => '$apiPrefix/reviews/user/$userId';
  static String userProfileReviews(int userId) => '$apiPrefix/reviews/profile/$userId';

  // Search
  static const String searchFreelancers = '$apiPrefix/search/freelancers';
  static const String searchTasks = '$apiPrefix/search/tasks';
  static const String categories = '$apiPrefix/search/categories';

  // Files
  static const String fileUpload = '$apiPrefix/files/upload';
  static const String extractCriteria = '$apiPrefix/tasks/criteria/extract';

  // Admin
  static const String adminDashboard = '$apiPrefix/admin/dashboard';
  static const String adminUsers = '$apiPrefix/admin/users';
  static String adminUser(int id) => '$apiPrefix/admin/users/$id';
  static String adminChangeRole(int id) => '$apiPrefix/admin/users/$id/role';
  static String banUser(int id) => '$apiPrefix/admin/users/$id/ban';
  static String unbanUser(int id) => '$apiPrefix/admin/users/$id/unban';
  static const String escalatedDisputes = '$apiPrefix/admin/disputes/escalated';

  // Health
  static const String health = '$apiPrefix/health';
}
