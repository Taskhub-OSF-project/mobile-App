# TaskHub Mobile Architecture Plan

> **Generated**: 2026-07-10 | **Source**: Backend (Spring Boot) + Web Frontend (Vite/React/TanStack)
> **Target Platform**: Flutter (Dart) | **Existing Scaffold**: `mobile-App/taskhubMobile/`

---

## Table of Contents

1. [Tech Stack Definition](#1-tech-stack-definition)
2. [Backend-to-Mobile Mapping Matrix](#2-backend-to-mobile-mapping-matrix)
3. [Mobile Directory Structure](#3-mobile-directory-structure)
4. [Edge Cases & Error Handling Protocol](#4-edge-cases--error-handling-protocol)
5. [Step-by-Step Execution Checklist](#5-step-by-step-execution-checklist)

---

## 1. Tech Stack Definition

### 1.1 Core Framework

| Component             | Technology              | Version / Notes                                      |
|-----------------------|-------------------------|------------------------------------------------------|
| UI Framework          | **Flutter**             | SDK `^3.11.5` (already in `pubspec.yaml`)            |
| Language              | **Dart**                | Matches Flutter SDK                                  |
| State Management      | **flutter_riverpod**    | `^2.6.1` — `StateNotifierProvider` + `FutureProvider`|
| Routing / Navigation  | **go_router**           | `^14.6.2` — Declarative, redirect-based auth guard   |
| HTTP Client           | **Dio**                 | `^5.7.0` — Interceptors for JWT, refresh, 401 handling|
| Secure Storage        | **flutter_secure_storage** | `^9.2.2` — AES-encrypted token persistence        |
| JSON Serialization    | **json_annotation** + **json_serializable** | `^4.9.0` / `^6.8.0` — Code-gen models |
| Date/Time             | **intl**                | `^0.19.0` — Localized date formatting               |
| Image Caching         | **cached_network_image**| `^3.4.1` — Avatar/portfolio images                   |
| Equality              | **equatable**           | `^2.0.7` — Value-based state comparison              |
| Build Runner          | **build_runner**        | `^2.4.13` — `*.g.dart` code generation               |

### 1.2 Architecture Pattern

```
Feature-First Clean Architecture (Layered)
├── Presentation  →  Screens + Widgets (Flutter Widgets)
├── Domain        →  Entities + Use Cases (Pure Dart)
└── Data          →  Repositories + DTOs + Data Sources (Dio + json_serializable)
```

**State Flow**: `Screen` → `Riverpod Provider/Notifier` → `Repository` → `ApiService (Dio)` → `Spring Boot REST`

### 1.3 Navigation Architecture

**Pattern**: `go_router` with `ShellRoute` for bottom navigation scaffold.

| Route                    | Screen                        | Auth Required | Role Guard        |
|--------------------------|-------------------------------|:-------------:|:-----------------:|
| `/`                      | `SplashScreen`                | No            | —                 |
| `/login`                 | `LoginScreen`                 | No            | —                 |
| `/register`              | `RegisterScreen`              | No            | —                 |
| `/forgot-password`       | `ForgotPasswordScreen`        | No            | —                 |
| `/otp-verify`            | `OtpVerificationScreen`       | No            | —                 |
| `/reset-password`        | `ResetPasswordScreen`         | No            | —                 |
| `/home`                  | `HomeScreen`                  | Yes           | —                 |
| `/tasks`                 | `TaskListScreen`              | Yes           | —                 |
| `/tasks/available`       | `TaskListScreen(available)`   | Yes           | STUDENT           |
| `/tasks/create`          | `CreateTaskScreen`            | Yes           | HIRER             |
| `/tasks/:id`             | `TaskDetailScreen`            | Yes           | —                 |
| `/profile`               | `ProfileScreen`               | Yes           | —                 |
| `/profile/edit`          | `EditProfileScreen`           | Yes           | —                 |
| `/user/:id`              | `UserProfileScreen`           | Yes           | —                 |
| `/wallet`                | `WalletScreen`                | Yes           | —                 |
| `/notifications`         | `NotificationScreen`          | Yes           | —                 |
| `/messages`              | `ConversationListScreen`      | Yes           | —                 |
| `/messages/:id`          | `ChatScreen`                  | Yes           | —                 |

### 1.4 HTTP Client Architecture

**Base**: `Dio` instance with interceptors mirroring the web `apiFetch` pattern.

```dart
// Interceptor chain (mirrors web client.ts):
DioClient
  ├── AuthInterceptor        → Attaches `Authorization: Bearer <token>` header
  ├── RefreshInterceptor     → On 401 → POST /api/auth/refresh → retry original request
  ├── ErrorInterceptor       → Maps DioException to typed ApiError
  └── LoggingInterceptor     → Debug-mode request/response logging
```

**API Response Wrapper** (mirrors `ApiResponse<T>` from BE):
```dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final String? errorCode;
  final T? data;
}
```

---

## 2. Backend-to-Mobile Mapping Matrix

### 2.1 Authentication Module

| # | BE Endpoint                              | Method | Request DTO                    | Response DTO            | Mobile Screen / Action               |
|---|------------------------------------------|--------|--------------------------------|-------------------------|--------------------------------------|
| 1 | `/api/auth/register`                     | POST   | `RegisterRequest`              | `AuthResponse`          | `RegisterScreen` → register form     |
| 2 | `/api/auth/login`                        | POST   | `LoginRequest`                 | `AuthResponse`          | `LoginScreen` → email/password login |
| 3 | `/api/auth/refresh`                      | POST   | `RefreshTokenRequest`          | `AuthResponse`          | `DioClient` → auto token refresh     |
| 4 | `/api/auth/logout`                       | POST   | `LogoutRequest`                | `Void`                  | Settings/Profile → logout action     |
| 5 | `/api/auth/forgot-password`              | POST   | `ForgotPasswordRequest`        | `Void`                  | `ForgotPasswordScreen`               |
| 6 | `/api/auth/recover-account`              | POST   | `RecoverAccountRequest`        | `Object`                | `ForgotPasswordScreen` → step 1      |
| 7 | `/api/auth/recover-password/request`     | POST   | `PasswordResetRequest`         | `Object`                | `ForgotPasswordScreen` → request OTP |
| 8 | `/api/auth/recover-password/confirm`     | POST   | `PasswordResetConfirmRequest`  | `Object`                | `OtpVerificationScreen`              |
| 9 | `/api/auth/reset-password`               | POST   | `ResetPasswordRequest`         | `Void`                  | `ResetPasswordScreen`                |
|10 | `/api/auth/verify-email`                 | POST   | `VerifyEmailRequest`           | `Void`                  | Post-register email verify prompt    |

**AuthResponse DTO Fields** (stored in `flutter_secure_storage`):
```
token: String, refreshToken: String, tokenType: "Bearer",
expiresIn: long, userId: Long, email: String, fullName: String,
role: enum(ADMIN, HIRER, STUDENT), expiresAt: Long
```

---

### 2.2 User / Profile Module

| # | BE Endpoint                   | Method | Request DTO              | Response DTO            | Mobile Screen / Action                 |
|---|-------------------------------|--------|--------------------------|-------------------------|----------------------------------------|
| 1 | `/api/users/me`               | GET    | —                        | `UserProfileResponse`   | `ProfileScreen` → own profile display  |
| 2 | `/api/users/{id}`             | GET    | —                        | `UserProfileResponse`   | `UserProfileScreen` → public profile   |
| 3 | `/api/users/me`               | PATCH  | `UpdateProfileRequest`   | `UserProfileResponse`   | `EditProfileScreen` → save profile     |
| 4 | `/api/users/me`               | PUT    | `UpdateProfileRequest`   | `UserProfileResponse`   | `EditProfileScreen` → full replace     |
| 5 | `/api/users/me/availability`  | POST   | query `available`        | `UserProfileResponse`   | `ProfileScreen` → availability toggle  |
| 6 | `/api/users/switch-role`      | POST   | —                        | `AuthResponse`          | `ProfileScreen` → role switch button   |
| 7 | `/api/users/change-password`  | PATCH  | `ChangePasswordRequest`  | `Void`                  | Settings → change password dialog      |

**UserProfileResponse DTO Fields**:
```
id, email, fullName, university, major, bio, skills[], experience,
portfolioUrl, phone, title, hourlyRate, availability, languages[],
certifications[], avatarUrl, role, walletBalance, isVerified, isAvailable,
isBanned, dateOfBirth, age, averageRatingAsFreelancer/Hirer,
totalReviewsAsFreelancer/Hirer, totalEarnings, completedTasksAsFreelancer/Hirer,
memberSince, roleEnum, emailVerified, createdAt
```

---

### 2.3 Task Module

| # | BE Endpoint                              | Method | Request DTO               | Response DTO                  | Mobile Screen / Action                         |
|---|------------------------------------------|--------|---------------------------|-------------------------------|------------------------------------------------|
| 1 | `/api/tasks`                             | POST   | `CreateTaskRequest`       | `TaskResponse`                | `CreateTaskScreen` → hirer creates task        |
| 2 | `/api/tasks/{id}`                        | GET    | —                         | `TaskResponse`                | `TaskDetailScreen` → full task view            |
| 3 | `/api/tasks/mine`                        | GET    | query page/size/sort      | `PageResponse<TaskResponse>`  | `TaskListScreen` → my tasks tab                |
| 4 | `/api/tasks/available`                   | GET    | query page/size/sort      | `PageResponse<TaskResponse>`  | `TaskListScreen(available)` → student browse   |
| 5 | `/api/tasks/validate-criteria`           | POST   | `ValidateCriteriaRequest` | `ValidationResult`            | `CreateTaskScreen` → AI criteria validation    |
| 6 | `/api/tasks/{id}/validate`               | POST   | —                         | `ValidationResult`            | `TaskDetailScreen` → validate before lock      |
| 7 | `/api/tasks/criteria/extract`            | POST   | multipart `file`          | `CriteriaExtractResponse`    | `CreateTaskScreen` → upload doc → extract      |
| 8 | `/api/tasks/{id}/lock`                   | POST   | —                         | `ValidationPhaseResponse`     | `TaskDetailScreen` → lock task                 |
| 9 | `/api/tasks/{id}/complete`               | POST   | —                         | `TaskResponse`                | `TaskDetailScreen` → mark complete             |
|10 | `/api/tasks/{id}/publish`                | POST   | —                         | `TaskResponse`                | `TaskDetailScreen` → publish to marketplace    |
|11 | `/api/tasks/{id}/revision`               | POST   | `RevisionRequest`         | `RevisionRequestResponse`     | `TaskDetailScreen` → hirer request revision    |
|12 | `/api/tasks/{id}/dispute`                | POST   | `DisputeRequest`          | `DisputeAIReport`             | `TaskDetailScreen` → open dispute              |
|13 | `/api/tasks/{id}/dispute/report`         | GET    | —                         | `DisputeAIReport`             | `TaskDetailScreen` → view dispute report       |
|14 | `/api/tasks/{id}/dispute/resolve`        | POST   | `DisputeResolveRequest`   | `DisputeResolveResponse`      | `TaskDetailScreen` → resolve dispute           |
|15 | `/api/tasks/{id}`                        | PATCH  | `PatchTaskRequest`        | `TaskResponse`                | `TaskDetailScreen` → edit draft task           |
|16 | `/api/tasks/{id}`                        | DELETE | —                         | `Void`                        | `TaskDetailScreen` → delete draft              |

**TaskResponse DTO Fields**:
```
id, title, description, category, budget(BigDecimal), deadline(LocalDateTime),
status(enum), hirerId, hirerName, assignedToId, assignedToName,
revisionCount, acceptanceCriteria[], applicants[], createdAt
```

**TaskStatus State Machine**:
```
DRAFT → LOCKED → ESCROW_FUNDED → ACTIVE → IN_PROGRESS → SUBMITTED → COMPLETED
                                                                    → DISPUTED → IN_PROGRESS | LOCKED | COMPLETED
```

---

### 2.4 Application (Student ↔ Task) Module

| # | BE Endpoint                              | Method | Request DTO            | Response DTO                      | Mobile Screen / Action                        |
|---|------------------------------------------|--------|------------------------|-----------------------------------|-----------------------------------------------|
| 1 | `/api/applications/task/{taskId}`        | POST   | `ApplicationRequest`   | `ApplicationResponse`             | `TaskDetailScreen` → student applies          |
| 2 | `/api/applications/{id}/accept`          | POST   | —                      | `Void`                            | `TaskDetailScreen` → hirer accepts applicant  |
| 3 | `/api/applications/task/{taskId}`        | GET    | query page/size        | `PageResponse<ApplicationResponse>`| `TaskDetailScreen` → hirer views applicants  |
| 4 | `/api/applications/mine`                 | GET    | query page/size        | `PageResponse<ApplicationResponse>`| `TaskListScreen` → student "My Applications" |
| 5 | `/api/applications/my-applied-tasks`     | GET    | —                      | `List<TaskResponse>`              | `TaskListScreen` → student applied tasks list |

**ApplicationResponse DTO Fields**:
```
id, taskId, studentId, studentName, studentUniversity, studentMajor,
coverLetter, status(PENDING|ACCEPTED|REJECTED), appliedAt
```

---

### 2.5 Submission Module

| # | BE Endpoint                              | Method | Request DTO            | Response DTO                      | Mobile Screen / Action                    |
|---|------------------------------------------|--------|------------------------|-----------------------------------|-------------------------------------------|
| 1 | `/api/submissions/task/{taskId}`         | POST   | `SubmissionRequest`    | `SubmissionResponse`              | `TaskDetailScreen` → student submits work |
| 2 | `/api/submissions/task/{taskId}/precheck`| POST   | `SubmissionRequest`    | `SubmissionAIResult`              | `TaskDetailScreen` → AI pre-check         |
| 3 | `/api/submissions/task/{taskId}/revision`| POST   | `RevisionRequest`      | `RevisionRequestResponse`         | `TaskDetailScreen` → hirer requests fix   |
| 4 | `/api/submissions/task/{taskId}/revisions`| GET   | —                      | `List<RevisionRequestResponse>`   | `TaskDetailScreen` → revision history     |
| 5 | `/api/submissions/task/{taskId}/approve` | POST   | —                      | `Void`                            | `TaskDetailScreen` → hirer approves       |
| 6 | `/api/submissions/task/{taskId}`         | GET    | —                      | `List<SubmissionResponse>`        | `TaskDetailScreen` → submission list      |
| 7 | `/api/submissions/task/{taskId}/latest`  | GET    | —                      | `LatestSubmissionResultResponse`  | `TaskDetailScreen` → latest result        |

---

### 2.6 Milestone Module

| # | BE Endpoint                                      | Method | Request DTO              | Response DTO           | Mobile Screen / Action                    |
|---|--------------------------------------------------|--------|--------------------------|------------------------|-------------------------------------------|
| 1 | `/api/tasks/{taskId}/milestones`                  | GET    | —                        | `List<MilestoneResponse>`| `TaskDetailScreen` → milestones tab      |
| 2 | `/api/tasks/{taskId}/milestones`                  | POST   | `CreateMilestoneRequest` | `MilestoneResponse`    | `TaskDetailScreen` → add milestone        |
| 3 | `/api/tasks/{taskId}/milestones/{id}`             | PUT    | `CreateMilestoneRequest` | `MilestoneResponse`    | `TaskDetailScreen` → edit milestone       |
| 4 | `/api/tasks/{taskId}/milestones/{id}`             | DELETE | —                        | `Void`                 | `TaskDetailScreen` → delete milestone     |
| 5 | `/api/tasks/{taskId}/milestones/{id}/fund`        | POST   | —                        | `MilestoneResponse`    | `TaskDetailScreen` → fund milestone       |
| 6 | `/api/tasks/{taskId}/milestones/{id}/approve`     | POST   | —                        | `MilestoneResponse`    | `TaskDetailScreen` → approve & pay        |
| 7 | `/api/tasks/{taskId}/milestones/{id}/reject`      | POST   | —                        | `MilestoneResponse`    | `TaskDetailScreen` → reject & refund      |

---

### 2.7 Wallet Module

| # | BE Endpoint                        | Method | Request DTO   | Response DTO                     | Mobile Screen / Action                   |
|---|------------------------------------|--------|---------------|----------------------------------|------------------------------------------|
| 1 | `/api/wallet/balance`              | GET    | —             | `WalletResponse`                 | `WalletScreen` → balance display         |
| 2 | `/api/wallet/readiness/create-task`| GET    | query `budget`| `WalletReadinessResponse`        | `CreateTaskScreen` → pre-create check    |
| 3 | `/api/wallet/deposit`              | POST   | query `amount`| `WalletResponse`                 | `WalletScreen` → deposit action          |
| 4 | `/api/wallet/withdraw`             | POST   | query `amount`| `WalletResponse`                 | `WalletScreen` → withdraw action         |
| 5 | `/api/wallet/transactions`         | GET    | —             | `List<WalletTransactionResponse>`| `WalletScreen` → transaction history     |
| 6 | `/api/wallet/transactions/paged`   | GET    | query page/size| `PageResponse<WalletTxResponse>`| `WalletScreen` → paged tx history        |

---

### 2.8 Escrow Module

| # | BE Endpoint                  | Method | Request DTO | Response DTO | Mobile Screen / Action                  |
|---|------------------------------|--------|-------------|--------------|------------------------------------------|
| 1 | `/api/escrow/fund/{taskId}`  | POST   | —           | `Void`       | `TaskDetailScreen` → fund escrow         |
| 2 | `/api/escrow/release/{taskId}`| POST  | —           | `Void`       | `TaskDetailScreen` → release payment     |
| 3 | `/api/escrow/refund/{taskId}`| POST   | —           | `Void`       | `TaskDetailScreen` → refund escrow       |

---

### 2.9 Messaging Module

| # | BE Endpoint                                                    | Method | Request DTO           | Response DTO                         | Mobile Screen / Action                      |
|---|----------------------------------------------------------------|--------|-----------------------|--------------------------------------|---------------------------------------------|
| 1 | `/api/messaging/conversations`                                 | GET    | —                     | `List<ConversationResponse>`         | `ConversationListScreen` → conversation list|
| 2 | `/api/messaging/conversations/paged`                           | GET    | query page/size       | `PageResponse<ConversationResponse>` | `ConversationListScreen` → paged            |
| 3 | `/api/messaging/conversations/task/{taskId}`                   | POST   | —                     | `ConversationResponse`               | `TaskDetailScreen` → "Message" button       |
| 4 | `/api/messaging/conversations/task/{taskId}/user/{userId}`     | POST   | —                     | `ConversationResponse`               | `UserProfileScreen` → "Message" button      |
| 5 | `/api/messaging/conversations/{id}/messages`                   | POST   | `SendMessageRequest`  | `MessageResponse`                    | `ChatScreen` → send message                 |
| 6 | `/api/messaging/conversations/{id}/messages`                   | GET    | query page/size       | `PageResponse<MessageResponse>`      | `ChatScreen` → message history              |
| 7 | `/api/messaging/conversations/{id}/read`                       | POST   | —                     | `Void`                               | `ChatScreen` → auto mark on open            |
| 8 | `/api/messaging/unread/count`                                  | GET    | —                     | `{count: Long}`                      | Bottom nav badge counter                    |

---

### 2.10 Notification Module

| # | BE Endpoint                       | Method | Request DTO | Response DTO                          | Mobile Screen / Action                   |
|---|-----------------------------------|--------|-------------|---------------------------------------|------------------------------------------|
| 1 | `/api/notifications`              | GET    | query p/s   | `PageResponse<NotificationResponse>`  | `NotificationScreen` → list              |
| 2 | `/api/notifications/unread-count` | GET    | —           | `{count: Long}`                       | Bottom nav / AppBar badge                |
| 3 | `/api/notifications/unread`       | GET    | —           | `List<NotificationResponse>`          | `NotificationScreen` → unread filter     |
| 4 | `/api/notifications/{id}/read`    | PATCH  | —           | `Void`                                | `NotificationScreen` → tap to read       |
| 5 | `/api/notifications/read-all`     | POST   | —           | `{updated: Int}`                      | `NotificationScreen` → "Mark all read"   |

**NotificationType enum** (for icon/color mapping):
```
TASK_ASSIGNED, TASK_APPLICATION_RECEIVED, TASK_APPLICATION_ACCEPTED,
TASK_APPLICATION_REJECTED, TASK_SUBMITTED, TASK_REVISION_REQUESTED,
TASK_APPROVED, TASK_COMPLETED, TASK_DISPUTE_OPENED, TASK_DISPUTE_RESOLVED,
TASK_MESSAGE_RECEIVED, TASK_STATUS_CHANGED, ESCROW_FUNDED, ESCROW_RELEASED,
ESCROW_REFUNDED, PAYMENT_RECEIVED, PAYMENT_SENT, SYSTEM_ANNOUNCEMENT,
REVIEW_RECEIVED
```

---

### 2.11 Review Module

| # | BE Endpoint                    | Method | Request DTO           | Response DTO                     | Mobile Screen / Action               |
|---|--------------------------------|--------|-----------------------|----------------------------------|--------------------------------------|
| 1 | `/api/reviews/task/{taskId}`   | POST   | `CreateReviewRequest` | `ReviewResponse`                 | `TaskDetailScreen` → post-complete   |
| 2 | `/api/reviews/user/{userId}`   | GET    | query page/size       | `PageResponse<ReviewResponse>`   | `UserProfileScreen` → reviews tab    |
| 3 | `/api/reviews/profile/{userId}`| GET    | —                     | `UserProfileResponse`            | `UserProfileScreen` → profile+stats  |

---

### 2.12 Search Module

| # | BE Endpoint                 | Method | Request DTO                   | Response DTO                              | Mobile Screen / Action                |
|---|-----------------------------|--------|-------------------------------|-------------------------------------------|---------------------------------------|
| 1 | `/api/search/freelancers`   | GET    | query keyword/page/size       | `PageResponse<FreelancerSearchResponse>`  | `HomeScreen` → search freelancers     |
| 2 | `/api/search/tasks`         | GET    | query keyword/category/p/s    | `PageResponse<PublicTaskResponse>`        | `HomeScreen` → search tasks           |
| 3 | `/api/search/categories`    | GET    | —                             | `List<String>`                            | `CreateTaskScreen` → category picker  |

---

### 2.13 Portfolio Module

| # | BE Endpoint                  | Method | Request DTO           | Response DTO              | Mobile Screen / Action                     |
|---|------------------------------|--------|-----------------------|---------------------------|--------------------------------------------|
| 1 | `/api/portfolio/me`          | GET    | —                     | `List<PortfolioItemResponse>`| `ProfileScreen` → my portfolio tab        |
| 2 | `/api/portfolio/user/{id}`   | GET    | —                     | `List<PortfolioItemResponse>`| `UserProfileScreen` → portfolio tab       |
| 3 | `/api/portfolio`             | POST   | `PortfolioItemRequest`| `PortfolioItemResponse`   | `ProfileScreen` → add portfolio item       |
| 4 | `/api/portfolio/{itemId}`    | PUT    | `PortfolioItemRequest`| `PortfolioItemResponse`   | `ProfileScreen` → edit portfolio item      |
| 5 | `/api/portfolio/{itemId}`    | DELETE | —                     | `Void`                    | `ProfileScreen` → delete portfolio item    |
| 6 | `/api/portfolio/reorder`     | PUT    | `List<Long>`          | `Void`                    | `ProfileScreen` → drag-reorder             |

---

### 2.14 AI Module

| # | BE Endpoint                      | Method | Request DTO            | Response DTO            | Mobile Screen / Action                   |
|---|----------------------------------|--------|------------------------|-------------------------|------------------------------------------|
| 1 | `/api/ai/progress`               | POST   | `AiProgressRequest`    | `AiProgressResponse`    | `TaskDetailScreen` → progress analysis   |
| 2 | `/api/ai/criteria/suggest`       | POST   | `AiCriteriaRequest`    | `AiCriteriaResponse`    | `CreateTaskScreen` → AI suggest criteria |
| 3 | `/api/ai/evaluate`               | POST   | `AiEvaluationRequest`  | `AiEvaluationResponse`  | `TaskDetailScreen` → evaluate submission |
| 4 | `/api/ai/dispute`                | POST   | `AiDisputeRequest`     | `AiDisputeResponse`     | `TaskDetailScreen` → AI dispute assist   |
| 5 | `/api/ai/chat`                   | POST   | `AiChatRequest`        | `AiChatResponse`        | AI Chat overlay / bottom sheet           |
| 6 | `/api/ai/chat/history/{session}` | GET    | —                      | `List<Map>`             | AI Chat → load session history           |
| 7 | `/api/ai/chat/sessions`          | GET    | —                      | `List<Map>`             | AI Chat → session list                   |

---

### 2.15 File Upload Module

| # | BE Endpoint             | Method | Request DTO               | Response DTO          | Mobile Screen / Action                |
|---|-------------------------|--------|---------------------------|-----------------------|---------------------------------------|
| 1 | `/api/files/upload`     | POST   | multipart `file` + `taskId`| `FileUploadResponse` | `TaskDetailScreen` → attach files     |

---

## 3. Mobile Directory Structure

```
taskhubMobile/
├── lib/
│   ├── main.dart                              # App entry point
│   ├── router.dart                            # GoRouter configuration
│   ├── providers.dart                         # Global Riverpod providers
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart             # Base URL, endpoint paths
│   │   │   ├── app_constants.dart             # App-wide magic values
│   │   │   └── enums.dart                     # Role, TaskStatus, ApplicationStatus, etc.
│   │   │
│   │   ├── models/
│   │   │   ├── api_response.dart              # ApiResponse<T> wrapper
│   │   │   ├── page_response.dart             # PageResponse<T> pagination wrapper
│   │   │   ├── api_error.dart                 # Typed error model
│   │   │   └── result.dart                    # Result<T> sealed class (Success/Failure)
│   │   │
│   │   ├── network/
│   │   │   ├── dio_client.dart                # Dio factory + base configuration
│   │   │   ├── api_service.dart               # Typed HTTP methods (get, post, patch, etc.)
│   │   │   ├── auth_interceptor.dart          # Bearer token injection
│   │   │   ├── refresh_interceptor.dart       # 401 → refresh → retry logic
│   │   │   ├── error_interceptor.dart         # DioException → ApiError mapping
│   │   │   └── logging_interceptor.dart       # Debug request/response logging
│   │   │
│   │   ├── storage/
│   │   │   └── secure_storage_service.dart    # Token & session CRUD
│   │   │
│   │   └── theme/
│   │       ├── app_theme.dart                 # Material 3 ThemeData
│   │       ├── app_colors.dart                # Color palette constants
│   │       └── app_text_styles.dart           # Typography scale
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── auth_models.dart       # LoginRequest, RegisterRequest, AuthResponse
│   │   │   │   │   └── auth_models.g.dart     # Generated
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository.dart   # Auth API calls
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── splash_screen.dart
│   │   │       │   ├── login_screen.dart
│   │   │       │   ├── register_screen.dart
│   │   │       │   ├── forgot_password_screen.dart
│   │   │       │   ├── otp_verification_screen.dart
│   │   │       │   └── reset_password_screen.dart
│   │   │       └── widgets/
│   │   │           └── auth_form_field.dart
│   │   │
│   │   ├── home/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── home_screen.dart       # Dashboard per role, search, stats
│   │   │
│   │   ├── task/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── task_models.dart       # TaskResponse, CreateTaskRequest, etc.
│   │   │   │   │   └── task_models.g.dart
│   │   │   │   └── repositories/
│   │   │   │       ├── task_repository.dart    # Task CRUD, status transitions
│   │   │   │       ├── application_repository.dart  # Apply, accept, list applications
│   │   │   │       ├── submission_repository.dart   # Submit, precheck, approve
│   │   │   │       └── milestone_repository.dart    # Milestone CRUD, fund/approve/reject
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── task_list_screen.dart         # My Tasks + Available tabs
│   │   │       │   ├── task_detail_screen.dart       # Full detail with status-aware actions
│   │   │       │   └── create_task_screen.dart       # Multi-step task creation wizard
│   │   │       ├── widgets/
│   │   │       │   ├── task_card.dart
│   │   │       │   ├── task_status_badge.dart
│   │   │       │   ├── criteria_list_widget.dart
│   │   │       │   ├── applicant_list_widget.dart
│   │   │       │   ├── submission_section_widget.dart
│   │   │       │   ├── milestone_list_widget.dart
│   │   │       │   ├── dispute_section_widget.dart
│   │   │       │   └── file_upload_widget.dart
│   │   │       └── providers/
│   │   │           ├── task_list_provider.dart
│   │   │           └── task_detail_provider.dart
│   │   │
│   │   ├── user/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── user_models.dart       # UserProfileResponse, UpdateProfileRequest
│   │   │   │   │   └── user_models.g.dart
│   │   │   │   └── repositories/
│   │   │   │       ├── user_repository.dart
│   │   │   │       ├── portfolio_repository.dart
│   │   │   │       └── review_repository.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── profile_screen.dart           # Own profile + portfolio
│   │   │       │   ├── edit_profile_screen.dart       # Edit profile form
│   │   │       │   └── user_profile_screen.dart       # Public user profile view
│   │   │       └── widgets/
│   │   │           ├── profile_header_widget.dart
│   │   │           ├── stats_section_widget.dart
│   │   │           ├── portfolio_grid_widget.dart
│   │   │           └── review_list_widget.dart
│   │   │
│   │   ├── wallet/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── wallet_models.dart     # WalletResponse, WalletTransactionResponse
│   │   │   │   │   └── wallet_models.g.dart
│   │   │   │   └── repositories/
│   │   │   │       ├── wallet_repository.dart
│   │   │   │       └── escrow_repository.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── wallet_screen.dart     # Balance, deposit, withdraw, history
│   │   │       └── widgets/
│   │   │           ├── balance_card_widget.dart
│   │   │           └── transaction_list_widget.dart
│   │   │
│   │   ├── notification/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── notification_models.dart
│   │   │   │   │   └── notification_models.g.dart
│   │   │   │   └── repositories/
│   │   │   │       └── notification_repository.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── notification_screen.dart
│   │   │       └── widgets/
│   │   │           └── notification_tile_widget.dart
│   │   │
│   │   ├── messaging/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── messaging_models.dart
│   │   │   │   │   └── messaging_models.g.dart
│   │   │   │   └── repositories/
│   │   │   │       └── messaging_repository.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── conversation_list_screen.dart
│   │   │       │   └── chat_screen.dart
│   │   │       └── widgets/
│   │   │           ├── conversation_tile_widget.dart
│   │   │           ├── message_bubble_widget.dart
│   │   │           └── chat_input_widget.dart
│   │   │
│   │   └── search/
│   │       ├── data/
│   │       │   ├── models/
│   │       │   │   └── search_models.dart
│   │       │   └── repositories/
│   │       │       └── search_repository.dart
│   │       └── presentation/
│   │           └── widgets/
│   │               ├── search_bar_widget.dart
│   │               └── search_result_card.dart
│   │
│   └── shared/
│       └── widgets/
│           ├── main_scaffold.dart             # Bottom nav shell (Home, Tasks, Wallet, Messages, Profile)
│           ├── empty_state_widget.dart         # Reusable empty state illustration
│           ├── error_widget.dart               # Error state with retry
│           ├── loading_widget.dart             # Shimmer / skeleton loading
│           ├── paginated_list_view.dart        # Generic infinite scroll list
│           └── confirm_dialog.dart             # Reusable confirmation dialog
│
├── docs/
│   └── mobile_architecture_plan.md            # ← This file
│
├── pubspec.yaml
├── analysis_options.yaml
├── android/
├── ios/
├── web/
└── test/
```

---

## 4. Edge Cases & Error Handling Protocol

### 4.1 HTTP Error Interceptor Logic

> Mirrors the web `apiFetch` in `client.ts` and `auth_interceptor.dart`.

```
┌─────────────────────────────────────────────────────────────────┐
│                    HTTP Response Handler                         │
├─────────────────────────────────────────────────────────────────┤
│ Status 200–299                                                  │
│   ├── Parse body as ApiResponse<T>                              │
│   ├── if response.success == false → throw ApiError(message)    │
│   └── return response.data                                      │
├─────────────────────────────────────────────────────────────────┤
│ Status 401 (Unauthorized)                                       │
│   ├── Attempt token refresh via POST /api/auth/refresh          │
│   │   ├── Success → save new tokens → retry original request    │
│   │   └── Failure → clear session → navigate to /login          │
│   └── Throw AuthExpiredError                                    │
├─────────────────────────────────────────────────────────────────┤
│ Status 403 (Forbidden)                                          │
│   └── Show "Insufficient permissions" snackbar                  │
├─────────────────────────────────────────────────────────────────┤
│ Status 404 (Not Found)                                          │
│   └── Show "Resource not found" with graceful fallback UI       │
├─────────────────────────────────────────────────────────────────┤
│ Status 422 (Validation Error)                                   │
│   └── Parse field errors → highlight form fields                │
├─────────────────────────────────────────────────────────────────┤
│ Status 429 (Rate Limit)                                         │
│   └── Show "Too many requests, please wait" with countdown      │
├─────────────────────────────────────────────────────────────────┤
│ Status 500+ (Server Error)                                      │
│   └── Show "Server error, please try again later" with retry    │
├─────────────────────────────────────────────────────────────────┤
│ Network Error (SocketException / Timeout)                       │
│   └── Show "No internet connection" banner with retry           │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Token Refresh Flow (Mirrors Web RefreshTokenRequest)

```
1. Request fails with 401
2. Check if refreshToken exists in SecureStorage
   ├── No  → clearSession() → redirect /login
   └── Yes → POST /api/auth/refresh { refreshToken }
              ├── 200 → save new (token, refreshToken, expiresAt)
              │         → retry original request with new token
              └── 4xx → clearSession() → redirect /login
3. Concurrent requests during refresh:
   → Queue them → resolve all after refresh completes
```

### 4.3 Empty State Handling

| Screen                    | Empty Condition                          | UI Treatment                                           |
|---------------------------|------------------------------------------|--------------------------------------------------------|
| Task List (Hirer)         | No tasks created                         | Illustration + "Create your first task" CTA button     |
| Task List (Student)       | No available tasks                       | Illustration + "No tasks available, check back later"  |
| Applications (Student)    | No applications submitted                | Illustration + "Browse available tasks" CTA            |
| Applicants (Hirer)        | No applicants on task                    | "No applications yet" card in task detail              |
| Messages                  | No conversations                         | Illustration + "Start a conversation from a task"      |
| Notifications             | No notifications                         | Illustration + "You're all caught up!"                 |
| Wallet Transactions       | No transactions                          | "No transactions yet" empty card                       |
| Portfolio                 | No portfolio items                       | Illustration + "Add your first project" CTA            |
| Reviews (User Profile)    | No reviews received                      | "No reviews yet" informational text                    |
| Search Results            | No matching results                      | "No results found" + suggest broadening search         |

### 4.4 Null Safety & Data Normalization Rules

| Field Pattern                   | Rule                                                           |
|---------------------------------|----------------------------------------------------------------|
| `budget` (from BE)              | Always `parseMoney()` — handles `String`, `num`, `null` → `0` |
| `status` (TaskStatus)           | Uppercase + validate against enum set → fallback `"DRAFT"`     |
| `role` (UserRole)               | Strip `ROLE_` prefix, uppercase, validate → fallback `STUDENT` |
| `avatarUrl`                     | `null` → show `CircleAvatar` with initials                     |
| `skills[]`, `languages[]`       | `null` → `[]` (empty list, never null)                         |
| `deadline` (LocalDateTime)      | Parse ISO string → `DateTime` → format with `intl`            |
| `walletBalance`                 | `null` → `0.0`                                                 |
| `coverLetter`                   | `null` → `""` (show "No cover letter" placeholder)             |
| Pagination `page` / `number`    | Prefer `number` field if present; fallback to `page` field     |
| `lastMessageAt`                 | `null` → show "No messages yet" in conversation tile           |
| `submittedFiles`                | `null` → `[]`; normalize each file with `normalizeSubmittedFile()` |

### 4.5 Offline & Connectivity Protocol

```
1. Use Connectivity Listener to detect online/offline
2. Offline state:
   ├── Show persistent "No connection" banner at top
   ├── Disable mutation buttons (create, submit, send)
   ├── Allow browsing cached screens (if data loaded)
   └── Queue failed requests? → NO, show error immediately
3. Reconnect state:
   └── Auto-refresh current screen data
```

### 4.6 Role-Based UI Divergence

| Feature                  | HIRER View                                   | STUDENT View                                |
|--------------------------|----------------------------------------------|---------------------------------------------|
| Home Dashboard           | "My Tasks" summary, pending reviews          | "Available Tasks", "In Progress" summary    |
| Task List Tabs           | Draft / Active / Completed                   | Available / Applied / In Progress           |
| Task Detail Actions      | Lock, Fund, Publish, Accept/Reject, Dispute  | Apply, Upload, Submit, AI Check             |
| Wallet                   | Deposit, Withdraw, Escrow history            | Earnings, Withdraw                          |
| Create Task              | ✅ Available                                 | ❌ Hidden                                   |
| Bottom Nav               | Home, Tasks, Wallet, Messages, Profile       | Home, Browse, Wallet, Messages, Profile     |

---

## 5. Step-by-Step Execution Checklist

### Phase 0: Project Bootstrap & Core Infrastructure

- [ ] **0.1** Verify Flutter SDK `^3.11.5` is installed; run `flutter doctor`
- [ ] **0.2** Run `flutter pub get` in `taskhubMobile/` to install dependencies
- [ ] **0.3** Verify `pubspec.yaml` has all required dependencies (listed in §1.1)
- [ ] **0.4** Create `core/constants/api_constants.dart` — define `baseUrl`, all endpoint path constants
- [ ] **0.5** Create `core/constants/enums.dart` — define `UserRole`, `TaskStatus`, `ApplicationStatus`, `NotificationType`, `WalletTransactionType`, `EscrowStatus`, `MilestoneStatus`, `ReviewType`, `CriteriaStatus`
- [ ] **0.6** Create `core/constants/app_constants.dart` — token keys, pagination defaults, timeout durations
- [ ] **0.7** Create `core/models/api_response.dart` — generic `ApiResponse<T>` matching BE `{ success, message, errorCode, data }`
- [ ] **0.8** Create `core/models/page_response.dart` — generic `PageResponse<T>` matching BE `{ content, page, size, totalElements, totalPages, first, last, hasNext, hasPrevious }`
- [ ] **0.9** Create `core/models/api_error.dart` — `ApiError` class with `statusCode`, `message`, `payload`
- [ ] **0.10** Create `core/models/result.dart` — sealed `Result<T>` with `.success(data)` and `.failure(error)` constructors

### Phase 1: Network Layer (Dio Client + Interceptors)

- [ ] **1.1** Implement `core/network/dio_client.dart` — Dio factory with base options (baseUrl, connectTimeout, receiveTimeout, content-type headers)
- [ ] **1.2** Implement `core/network/auth_interceptor.dart` — read token from `SecureStorageService` → inject `Authorization: Bearer` header on every request
- [ ] **1.3** Implement `core/network/refresh_interceptor.dart` — on 401 response → attempt `POST /api/auth/refresh` → save new tokens → retry original request; on refresh failure → clear session → queue logout
- [ ] **1.4** Implement `core/network/error_interceptor.dart` — map `DioException` types to `ApiError` instances with appropriate messages
- [ ] **1.5** Implement `core/network/logging_interceptor.dart` — debug-mode request URL, headers, body; response status, body (truncated)
- [ ] **1.6** Implement `core/network/api_service.dart` — typed wrapper: `get<T>()`, `post<T>()`, `patch<T>()`, `put<T>()`, `delete<T>()`, `uploadFile()` with JSON parsing from `ApiResponse<T>`
- [ ] **1.7** Wire interceptor chain in `dio_client.dart`: Auth → Refresh → Error → Logging
- [ ] **1.8** Unit test: mock 401 → verify refresh → retry works
- [ ] **1.9** Unit test: mock network error → verify `ApiError` created correctly

### Phase 2: Secure Storage & Auth Infrastructure

- [ ] **2.1** Implement `core/storage/secure_storage_service.dart` — CRUD for: `accessToken`, `refreshToken`, `expiresAt`, `userId`, `role`, `email`, `fullName`; `isLoggedIn()`, `clearSession()`
- [ ] **2.2** Create `features/auth/data/models/auth_models.dart` — `LoginRequest`, `RegisterRequest`, `AuthResponse`, `RefreshTokenRequest`, `LogoutRequest`, `ForgotPasswordRequest`, `RecoverAccountRequest`, `PasswordResetRequest`, `PasswordResetConfirmRequest`, `ResetPasswordRequest`, `VerifyEmailRequest` with `@JsonSerializable`
- [ ] **2.3** Run `dart run build_runner build` to generate `auth_models.g.dart`
- [ ] **2.4** Implement `features/auth/data/repositories/auth_repository.dart` — `login()`, `register()`, `logout()`, `refreshToken()`, `forgotPassword()`, `recoverAccount()`, `requestPasswordReset()`, `confirmPasswordReset()`, `resetPassword()`, `verifyEmail()` — all returning `Result<T>`
- [ ] **2.5** Implement `AuthNotifier` in `providers.dart` (already scaffolded) — verify `checkAuthStatus()`, `login()`, `register()`, `logout()`, `refreshProfile()` flows match BE contract
- [ ] **2.6** Wire `authNotifierProvider`, `secureStorageProvider`, `authRepositoryProvider` in `providers.dart`

### Phase 3: Auth UI Screens

- [ ] **3.1** Implement `SplashScreen` — check auth → redirect to `/home` or `/login`
- [ ] **3.2** Implement `LoginScreen` — email/password form, validation, error handling, "Forgot password?" link, "Register" link
- [ ] **3.3** Implement `RegisterScreen` — role selector (HIRER/STUDENT), email, password, fullName, university (optional), major (optional), phoneNumber (optional), dateOfBirth (optional)
- [ ] **3.4** Implement `ForgotPasswordScreen` — channel selection (EMAIL/SMS), identifier input, submit
- [ ] **3.5** Implement `OtpVerificationScreen` — OTP input field, resend countdown, verify action
- [ ] **3.6** Implement `ResetPasswordScreen` — new password + confirm password, submit
- [ ] **3.7** Test full auth flow: Register → Login → Logout → Login → Forgot Password → Reset

### Phase 4: Navigation Shell & Home

- [ ] **4.1** Implement `shared/widgets/main_scaffold.dart` — `BottomNavigationBar` with 5 tabs: Home, Tasks/Browse, Wallet, Messages, Profile; badge counters for Messages + Notifications
- [ ] **4.2** Verify `router.dart` GoRouter config — all routes mapped, auth redirect guard working, `ShellRoute` wrapping authenticated pages
- [ ] **4.3** Implement `HomeScreen` — role-aware dashboard:
  - Hirer: task stats (draft/active/completed counts), recent tasks, wallet balance
  - Student: available tasks preview, in-progress tasks, earnings
- [ ] **4.4** Add unread badge providers — `notificationUnreadCountProvider`, `messageUnreadCountProvider` polling every 30s
- [ ] **4.5** Test navigation: login → home → all tabs → logout → redirect to login

### Phase 5: User / Profile Module

- [ ] **5.1** Create `features/user/data/models/user_models.dart` — `UserProfileResponse`, `UpdateProfileRequest`, `ChangePasswordRequest` with `@JsonSerializable`
- [ ] **5.2** Run `build_runner` for `user_models.g.dart`
- [ ] **5.3** Implement `features/user/data/repositories/user_repository.dart` — `getMyProfile()`, `getProfile(id)`, `updateProfile()`, `setAvailability()`, `switchRole()`, `changePassword()`
- [ ] **5.4** Implement `ProfileScreen` — own profile display with: avatar, name, email, role, bio, skills chips, university/major, stats (ratings, completed tasks, earnings), portfolio tab, availability toggle, role switch button, edit button, logout
- [ ] **5.5** Implement `EditProfileScreen` — form for: fullName, bio, skills (tag input), university, major, phone, title, hourlyRate, availability, languages, certifications, portfolioUrl
- [ ] **5.6** Implement `UserProfileScreen` — public profile view (read-only) + reviews tab + portfolio tab + "Message" button
- [ ] **5.7** Implement `shared/widgets/profile_header_widget.dart`, `stats_section_widget.dart`
- [ ] **5.8** Test: view profile → edit → save → verify changes → view other user profile

### Phase 6: Task Module (Core)

- [ ] **6.1** Create `features/task/data/models/task_models.dart` — `TaskResponse`, `CreateTaskRequest`, `PatchTaskRequest`, `ValidateCriteriaRequest`, `CriteriaExtractResponse`, `ValidationPhaseResponse`, `AcceptanceCriteria`, `ApplicationRequest`, `ApplicationResponse`, `SubmissionRequest`, `SubmissionResponse`, `SubmissionAIResult`, `RevisionRequest/Response`, `DisputeRequest/Response`, `MilestoneResponse`, `CreateMilestoneRequest`, `FileUploadResponse`
- [ ] **6.2** Run `build_runner` for `task_models.g.dart`
- [ ] **6.3** Implement `features/task/data/repositories/task_repository.dart` — `createTask()`, `getTask()`, `getMyTasks()`, `getAvailableTasks()`, `patchTask()`, `deleteTask()`, `lockTask()`, `publishTask()`, `completeTask()`, `validateCriteria()`, `extractCriteria()`, `disputeTask()`, `getDisputeReport()`, `resolveDispute()`
- [ ] **6.4** Implement `features/task/data/repositories/application_repository.dart` — `apply()`, `acceptApplication()`, `getTaskApplications()`, `getMyApplications()`, `getMyAppliedTasks()`
- [ ] **6.5** Implement `features/task/data/repositories/submission_repository.dart` — `submit()`, `precheck()`, `requestRevision()`, `getRevisions()`, `approveSubmission()`, `getTaskSubmissions()`, `getLatestSubmission()`
- [ ] **6.6** Implement `features/task/data/repositories/milestone_repository.dart` — `list()`, `create()`, `update()`, `delete()`, `fund()`, `approve()`, `reject()`
- [ ] **6.7** Create `features/task/presentation/providers/task_list_provider.dart` — `FutureProvider` for task lists with role-aware fetching (Hirer: mine, Student: available + mine)
- [ ] **6.8** Create `features/task/presentation/providers/task_detail_provider.dart` — `FutureProvider.family(taskId)` loading full task + applicants + submissions + milestones

### Phase 7: Task UI Screens

- [ ] **7.1** Implement `TaskListScreen` — tabbed view per role:
  - Hirer tabs: All / Draft / Active / In Progress / Completed
  - Student tabs: Available / Applied / In Progress / Completed
  - Pull-to-refresh, infinite scroll pagination, search/filter
- [ ] **7.2** Implement `task_card.dart` — compact card showing: title, budget, deadline, status badge, category, hirer/student name
- [ ] **7.3** Implement `task_status_badge.dart` — colored chip per `TaskStatus` enum
- [ ] **7.4** Implement `TaskDetailScreen` — status-aware view with sections:
  - Header: title, category, budget, deadline, status, hirer/assignee info
  - Description: full markdown/text
  - Acceptance Criteria: checklist with AI validation status
  - **Hirer actions** (contextual per status): Edit Draft → Lock → Fund Escrow → Publish → Accept Applicant → Review Submission → Accept/Revision/Dispute → Complete
  - **Student actions** (contextual per status): Apply (ACTIVE) → Upload Files → AI Pre-check → Submit (IN_PROGRESS) → View Results
  - Milestones section
  - Applicants section (Hirer only)
  - Submission history section
  - Revision history section
  - Dispute section
- [ ] **7.5** Implement `CreateTaskScreen` — multi-step wizard:
  - Step 1: Title, Description, Category (from `/search/categories`), Budget, Deadline
  - Step 2: Acceptance Criteria (min 3, AI suggestion, file extract)
  - Step 3: Review + Wallet readiness check → Create
- [ ] **7.6** Implement `criteria_list_widget.dart` — add/remove criteria, AI validation badges
- [ ] **7.7** Implement `applicant_list_widget.dart` — list of applicants with accept button
- [ ] **7.8** Implement `submission_section_widget.dart` — file list, notes, AI score display
- [ ] **7.9** Implement `milestone_list_widget.dart` — CRUD milestones, fund/approve/reject actions
- [ ] **7.10** Implement `dispute_section_widget.dart` — open dispute, view AI report, resolve
- [ ] **7.11** Implement `file_upload_widget.dart` — pick files, upload via multipart, show progress
- [ ] **7.12** Test complete Hirer flow: Create Task → Lock → Fund → Publish → Accept Applicant → Review Submission → Accept/Revise → Complete
- [ ] **7.13** Test complete Student flow: Browse → Apply → Upload → AI Check → Submit → View Result

### Phase 8: Wallet Module

- [ ] **8.1** Create `features/wallet/data/models/wallet_models.dart` — `WalletResponse`, `WalletTransactionResponse`, `WalletReadinessResponse`
- [ ] **8.2** Implement `features/wallet/data/repositories/wallet_repository.dart` — `getBalance()`, `deposit()`, `withdraw()`, `getTransactions()`, `getTransactionsPaged()`, `checkCreateTaskReadiness()`
- [ ] **8.3** Implement `features/wallet/data/repositories/escrow_repository.dart` — `fundEscrow()`, `releaseEscrow()`, `refundEscrow()`
- [ ] **8.4** Implement `WalletScreen` — balance card (gradient, large balance number), deposit/withdraw buttons, transaction history list with type icons, pull-to-refresh
- [ ] **8.5** Implement `balance_card_widget.dart` — glassmorphism card with gradient background
- [ ] **8.6** Implement `transaction_list_widget.dart` — icon per type (top_up↑, escrow↓, refund↩, release✓, withdrawal↓), amount, date, task link
- [ ] **8.7** Test: deposit → verify balance → create task (triggers escrow) → verify deduction → complete task → verify release

### Phase 9: Messaging Module

- [ ] **9.1** Create `features/messaging/data/models/messaging_models.dart` — `ConversationResponse`, `MessageResponse`, `SendMessageRequest`
- [ ] **9.2** Implement `features/messaging/data/repositories/messaging_repository.dart` — `getConversations()`, `getConversationsPaged()`, `getOrCreateForTask()`, `getMessages()`, `sendMessage()`, `markRead()`, `getUnreadCount()`
- [ ] **9.3** Implement `ConversationListScreen` — list of conversations with: other user name, task title, last message preview, unread count badge, timestamp; pull-to-refresh
- [ ] **9.4** Implement `ChatScreen` — message bubbles (mine vs theirs), text input, send button, auto-scroll, load older messages on scroll up, mark-as-read on open
- [ ] **9.5** Implement `conversation_tile_widget.dart`, `message_bubble_widget.dart`, `chat_input_widget.dart`
- [ ] **9.6** Add polling for new messages every 5s when `ChatScreen` is active
- [ ] **9.7** Test: open conversation from task detail → send messages → verify in list → unread badge updates

### Phase 10: Notification Module

- [ ] **10.1** Create `features/notification/data/models/notification_models.dart` — `NotificationResponse`
- [ ] **10.2** Implement `features/notification/data/repositories/notification_repository.dart` — `list()`, `unread()`, `unreadCount()`, `markRead()`, `markAllRead()`
- [ ] **10.3** Implement `NotificationScreen` — grouped list with: type icon, title, message, time ago, read/unread visual state; tap → navigate to actionUrl; "Mark all read" button
- [ ] **10.4** Implement `notification_tile_widget.dart` — icon/color per `NotificationType`
- [ ] **10.5** Wire unread count polling into `main_scaffold.dart` bottom nav badge
- [ ] **10.6** Test: trigger notification from task action → verify appears → tap → mark read → badge decrements

### Phase 11: Search Module

- [ ] **11.1** Create `features/search/data/models/search_models.dart` — `FreelancerSearchResponse`, `PublicTaskResponse`
- [ ] **11.2** Implement `features/search/data/repositories/search_repository.dart` — `searchFreelancers()`, `searchTasks()`, `getCategories()`
- [ ] **11.3** Integrate search into `HomeScreen` — search bar at top, toggle between Tasks/Freelancers results, category filter chips
- [ ] **11.4** Implement `search_bar_widget.dart` — debounced text input (300ms)
- [ ] **11.5** Implement `search_result_card.dart` — dual layout for task results vs freelancer results
- [ ] **11.6** Test: search by keyword → verify results → tap result → navigate to detail

### Phase 12: Portfolio & Review Modules

- [ ] **12.1** Create portfolio models and implement `portfolio_repository.dart` — `getMyPortfolio()`, `getPublicPortfolio()`, `createItem()`, `updateItem()`, `deleteItem()`, `reorderItems()`
- [ ] **12.2** Create review models and implement `review_repository.dart` — `createReview()`, `getReviewsForUser()`, `getUserProfile()`
- [ ] **12.3** Implement `portfolio_grid_widget.dart` — grid of portfolio items with images, title, links; add/edit/delete actions for own items
- [ ] **12.4** Implement `review_list_widget.dart` — star rating display, reviewer name, comment, date
- [ ] **12.5** Integrate portfolio into `ProfileScreen` (own) and `UserProfileScreen` (public)
- [ ] **12.6** Integrate review creation into `TaskDetailScreen` post-completion flow
- [ ] **12.7** Test: add portfolio item → view on profile → view other user's portfolio → leave review after task completion

### Phase 13: Shared Widgets & Polish

- [ ] **13.1** Implement `empty_state_widget.dart` — reusable with illustration, title, subtitle, optional CTA button
- [ ] **13.2** Implement `error_widget.dart` — error icon, message, "Retry" button with callback
- [ ] **13.3** Implement `loading_widget.dart` — shimmer skeletons matching each list type (task card, conversation tile, notification tile)
- [ ] **13.4** Implement `paginated_list_view.dart` — generic infinite scroll with `PageResponse` support, pull-to-refresh, empty state, error state, loading footer
- [ ] **13.5** Implement `confirm_dialog.dart` — reusable for destructive actions (delete task, logout, dispute)
- [ ] **13.6** Apply `core/theme/app_theme.dart` — Material 3 theme with seed color `#6366F1` (indigo), light/dark mode
- [ ] **13.7** Apply `core/theme/app_colors.dart` — semantic colors for status badges, wallet amounts, notifications
- [ ] **13.8** Apply `core/theme/app_text_styles.dart` — consistent typography scale

### Phase 14: Integration Testing & QA

- [ ] **14.1** End-to-end test: Full Hirer journey (register → create task → lock → fund → publish → accept → review → complete → withdraw)
- [ ] **14.2** End-to-end test: Full Student journey (register → browse → apply → get accepted → upload → AI check → submit → get paid → withdraw)
- [ ] **14.3** Test role switch flow: Hirer → switch to Student → verify UI changes → switch back
- [ ] **14.4** Test token refresh: wait for token expiry → verify automatic refresh → verify no logout
- [ ] **14.5** Test offline handling: airplane mode → verify error states → reconnect → verify recovery
- [ ] **14.6** Test deep linking: `/tasks/123` → verify loads correct task
- [ ] **14.7** Test empty states: new user with no data → verify all empty states render correctly
- [ ] **14.8** Test error states: invalid task ID, 500 server error, network timeout → verify error UI
- [ ] **14.9** Verify all forms: input validation, required field indicators, error messages match BE validation rules
- [ ] **14.10** Performance: verify list scrolling is smooth with 100+ items; verify no memory leaks with `DevTools`

### Phase 15: Build & Release Prep

- [ ] **15.1** Configure Android signing (`android/app/build.gradle` — release keystore)
- [ ] **15.2** Configure iOS signing (Xcode — provisioning profiles, bundle ID)
- [ ] **15.3** Set app icons and splash screen for both platforms
- [ ] **15.4** Configure environment-specific base URLs (dev, staging, production)
- [ ] **15.5** Run `flutter build apk --release` and `flutter build ios --release`
- [ ] **15.6** Test release builds on physical devices (Android + iOS)
- [ ] **15.7** Create `README.md` with setup instructions, architecture overview, and build commands

---

> **Total Atomic Tasks**: ~110 across 16 phases
> **Estimated Timeline**: 6–8 weeks (1 developer) | 3–4 weeks (2 developers)
> **Critical Path**: Phase 0–3 (infrastructure) → Phase 6–7 (task module) → Phase 8 (wallet) → Phase 14 (QA)
