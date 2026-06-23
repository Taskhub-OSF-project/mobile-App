class AppConstants {
  AppConstants._();
}

class StorageKeys {
  StorageKeys._();

  static const String accessToken = 'taskhub.access_token';
  static const String refreshToken = 'taskhub.refresh_token';
  static const String userId = 'taskhub.user_id';
  static const String userRole = 'taskhub.user_role';
  static const String userEmail = 'taskhub.user_email';
  static const String userFullName = 'taskhub.user_full_name';
  static const String isLoggedIn = 'taskhub.is_logged_in';
}

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String userProfile = '/user/:id';
  static const String tasks = '/tasks';
  static const String taskDetail = '/tasks/:id';
  static const String createTask = '/tasks/create';
  static const String myTasks = '/tasks/mine';
  static const String availableTasks = '/tasks/available';
  static const String wallet = '/wallet';
  static const String notifications = '/notifications';
  static const String messages = '/messages';
  static const String conversation = '/messages/:id';
  static const String settings = '/settings';
  static const String changePassword = '/settings/change-password';
  static const String portfolio = '/portfolio';
  static const String reviews = '/reviews/:userId';
  static const String search = '/search';
  static const String admin = '/admin';
}
