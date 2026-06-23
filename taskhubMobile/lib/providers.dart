import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final isLoggedIn = await _storage.isLoggedIn();
      if (!isLoggedIn) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
      final result = await _userRepo.getMyProfile();
      if (result.isSuccess && result.data != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.data,
        );
      } else {
        await _storage.clearSession();
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      await _storage.clearSession();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _authRepo.login(
      LoginRequest(email: email, password: password),
    );

    return result.when(
      success: (auth) async {
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
          errorMessage: error.message,
        );
        return false;
      },
    );
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
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
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
      ),
    );

    return result.when(
      success: (auth) async {
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
          errorMessage: error.message,
        );
        return false;
      },
    );
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
