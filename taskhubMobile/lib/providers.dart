import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/models/api_error.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/network/api_service.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/models/auth_models.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/user/data/models/user_models.dart';
import 'features/user/data/repositories/user_repository.dart';
import 'features/task/data/repositories/task_repository.dart';
import 'features/wallet/data/repositories/wallet_repository.dart';
import 'features/notification/data/repositories/notification_repository.dart';
import 'features/messaging/data/repositories/messaging_repository.dart';

// Auth state
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AuthResponse? authResponse;
  final UserProfileResponse? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authResponse,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthResponse? authResponse,
    UserProfileResponse? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      authResponse: authResponse ?? this.authResponse,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isError => status == AuthStatus.error;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;
  final SecureStorageService _storage;

  AuthNotifier(this._authRepo, this._userRepo, this._storage)
      : super(const AuthState());

  Future<void> checkAuthStatus() async {
    print('AuthNotifier: checkAuthStatus started');
    state = state.copyWith(status: AuthStatus.loading);
    try {
      print('AuthNotifier: Reading from storage');
      final isLoggedIn = await _storage.isLoggedIn();
      print('AuthNotifier: Storage result: $isLoggedIn');
      
      if (!isLoggedIn) {
        print('AuthNotifier: Changing state to unauthenticated');
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
      
      print('AuthNotifier: Calling API getMyProfile');
      final result = await _userRepo.getMyProfile().timeout(const Duration(seconds: 5));
      print('AuthNotifier: API getMyProfile completed, isSuccess: ${result.isSuccess}');
      
      if (result.isSuccess && result.data != null) {
        print('AuthNotifier: Changing state to authenticated');
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.data,
        );
      } else {
        print('AuthNotifier: Clearing session (API failed/no data)');
        await _storage.clearSession();
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      print('AuthNotifier: Exception in checkAuthStatus: $e');
      await _storage.clearSession();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final result = await _authRepo.login(
        LoginRequest(email: email, password: password),
      );

      return result.when(
        success: (AuthResponse auth) async {
          await _storage.saveTokens(
            accessToken: auth.accessToken,
            refreshToken: auth.refreshToken,
          );
          await _storage.saveUserSession(
            userId: auth.userId,
            role: auth.role.name,
            email: auth.email,
            fullName: auth.fullName,
          );
          final profileResult = await _userRepo.getProfile(auth.userId);
          state = state.copyWith(
            status: AuthStatus.authenticated,
            authResponse: auth,
            user: profileResult.data,
          );
          return true;
        },
        failure: (error) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: (error as ApiError).message,
          );
          return false;
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Lỗi hệ thống: $e',
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? university,
    String? major,
    String? phoneNumber,
    String? dateOfBirth,
    int? age,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final result = await _authRepo.register(
        RegisterRequest(
          email: email,
          password: password,
          fullName: fullName,
          role: role,
          university: university,
          major: major,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          age: age,
        ),
      );

      return result.when(
        success: (AuthResponse auth) async {
          await _storage.saveTokens(
            accessToken: auth.accessToken,
            refreshToken: auth.refreshToken,
          );
          await _storage.saveUserSession(
            userId: auth.userId,
            role: auth.role.name,
            email: auth.email,
            fullName: auth.fullName,
          );
          state = state.copyWith(
            status: AuthStatus.authenticated,
            authResponse: auth,
          );
          return true;
        },
        failure: (error) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: (error as ApiError).message,
          );
          return false;
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Lỗi hệ thống: $e',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      await _authRepo.logout(refreshToken);
    } catch (e) {
      // Ignore logout API errors
    }
    await _storage.clearSession();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> switchRole() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _userRepo.switchRole();
    
    return result.when(
      success: (AuthResponse auth) async {
        await _storage.saveTokens(
          accessToken: auth.accessToken,
          refreshToken: auth.refreshToken,
        );
        await _storage.saveUserSession(
          userId: auth.userId,
          role: auth.role.name,
          email: auth.email,
          fullName: auth.fullName,
        );
        final profileResult = await _userRepo.getProfile(auth.userId);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authResponse: auth,
          user: profileResult.data,
        );
        return true;
      },
      failure: (error) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: (error as ApiError).message,
        );
        // Ensure state drops back to authenticated but with error
        // Or wait, if switch role fails, we are still authenticated as the old role
        refreshProfile(); 
        return false;
      },
    );
  }

  Future<void> refreshProfile() async {
    if (state.user == null) return;
    final result = await _userRepo.getProfile(state.user!.id);
    if (result.isSuccess) {
      state = state.copyWith(user: result.data);
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<bool> loginByPhone(String phone, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final result = await _authRepo.loginByPhone(phone, password);

      return result.when(
        success: (AuthResponse auth) async {
          await _storage.saveTokens(
            accessToken: auth.accessToken,
            refreshToken: auth.refreshToken,
          );
          await _storage.saveUserSession(
            userId: auth.userId,
            role: auth.role.name,
            email: auth.email,
            fullName: auth.fullName,
          );
          final profileResult = await _userRepo.getProfile(auth.userId);
          state = state.copyWith(
            status: AuthStatus.authenticated,
            authResponse: auth,
            user: profileResult.data,
          );
          return true;
        },
        failure: (error) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: (error as ApiError).message,
          );
          return false;
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Lỗi hệ thống: $e',
      );
      return false;
    }
  }

  Future<bool> resetPasswordWithOtp(String phone, String code, String newPassword) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _authRepo.resetPasswordWithOtp(phone, code, newPassword);
    return result.when(
      success: (_) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return true;
      },
      failure: (error) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: (error as ApiError).message,
        );
        return false;
      },
    );
  }

  Future<bool> requestPhoneOtp(String phone, String type) async {
    final result = await _authRepo.requestPhoneOtp(phone, type);
    return result.when(
      success: (_) => true,
      failure: (error) {
        state = state.copyWith(errorMessage: (error as ApiError).message);
        return false;
      },
    );
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiServiceProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(apiServiceProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.read(apiServiceProvider));
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.read(apiServiceProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(apiServiceProvider));
});

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return MessagingRepository(ref.read(apiServiceProvider));
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(userRepositoryProvider),
    ref.read(secureStorageProvider),
  );
});

final currentUserProvider = Provider<UserProfileResponse?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

final notificationUnreadCountProvider = StreamProvider.autoDispose<int>((ref) async* {
  final repo = ref.read(notificationRepositoryProvider);
  while (true) {
    if (ref.read(isAuthenticatedProvider)) {
      final res = await repo.getUnreadCount();
      if (res.isSuccess) {
        yield res.data ?? 0;
      }
    } else {
      yield 0;
    }
    await Future.delayed(const Duration(seconds: 30));
  }
});

final messageUnreadCountProvider = StreamProvider.autoDispose<int>((ref) async* {
  final repo = ref.read(messagingRepositoryProvider);
  while (true) {
    if (ref.read(isAuthenticatedProvider)) {
      final res = await repo.getUnreadCount();
      if (res.isSuccess) {
        yield res.data ?? 0;
      }
    } else {
      yield 0;
    }
    await Future.delayed(const Duration(seconds: 30));
  }
});
