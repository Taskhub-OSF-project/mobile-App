enum UserRole {
  ADMIN,
  HIRER,
  STUDENT;

  static UserRole fromString(String role) {
    final cleanRole = role.replaceFirst('ROLE_', '').toUpperCase();
    return UserRole.values.firstWhere(
      (e) => e.name == cleanRole,
      orElse: () => UserRole.STUDENT,
    );
  }
}

enum TaskStatus {
  DRAFT,
  LOCKED,
  ESCROW_FUNDED,
  ACTIVE,
  IN_PROGRESS,
  SUBMITTED,
  COMPLETED,
  DISPUTED;

  static TaskStatus fromString(String status) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == status.toUpperCase(),
      orElse: () => TaskStatus.DRAFT,
    );
  }
}

enum ApplicationStatus {
  PENDING,
  ACCEPTED,
  REJECTED,
}

enum NotificationType {
  TASK_ASSIGNED,
  TASK_APPLICATION_RECEIVED,
  TASK_APPLICATION_ACCEPTED,
  TASK_APPLICATION_REJECTED,
  TASK_SUBMITTED,
  TASK_REVISION_REQUESTED,
  TASK_APPROVED,
  TASK_COMPLETED,
  TASK_DISPUTE_OPENED,
  TASK_DISPUTE_RESOLVED,
  TASK_MESSAGE_RECEIVED,
  TASK_STATUS_CHANGED,
  ESCROW_FUNDED,
  ESCROW_RELEASED,
  ESCROW_REFUNDED,
  PAYMENT_RECEIVED,
  PAYMENT_SENT,
  SYSTEM_ANNOUNCEMENT,
  REVIEW_RECEIVED,
}

enum WalletTransactionType {
  DEPOSIT,
  WITHDRAWAL,
  ESCROW_FUNDED,
  ESCROW_RELEASED,
  ESCROW_REFUNDED,
  PAYMENT,
}

enum EscrowStatus {
  PENDING,
  FUNDED,
  RELEASED,
  REFUNDED,
  DISPUTED,
}

enum MilestoneStatus {
  PENDING,
  FUNDED,
  IN_PROGRESS,
  COMPLETED,
  APPROVED,
  REJECTED,
}

enum ReviewType {
  FREELANCER_REVIEW,
  HIRER_REVIEW,
}

enum CriteriaStatus {
  PENDING,
  MET,
  NOT_MET,
}
