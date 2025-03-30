/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'Edutech';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String userBoxName = 'user_box';
  static const String courseBoxName = 'course_box';
  static const String settingsBoxName = 'settings_box';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleStudent = 'student';

  // File Types
  static const String typePdf = 'pdf';
  static const String typeVideo = 'video';

  // Routes
  static const String routeLogin = '/login';
  static const String routeAdminHome = '/admin/home';
  static const String routeStudentHome = '/student/home';
  static const String routeCourseDetail = '/course/detail';
  static const String routeSettings = '/settings';

  // Assets
  static const String assetLogo = 'assets/images/logo.svg';
  static const String assetPlaceholder = 'assets/images/placeholder.svg';

  // Error Messages
  static const String errorInvalidCredentials = 'Invalid username or password';
  static const String errorUsernameExists = 'Username already exists';
  static const String errorFileUpload = 'Failed to upload file';
  static const String errorFileDownload = 'Failed to download file';
  static const String errorFileOpen = 'Failed to open file';
  static const String errorStorageFull = 'Storage is full';

  // Success Messages
  static const String successLogin = 'Login successful';
  static const String successFileUpload = 'File uploaded successfully';
  static const String successFileDelete = 'File deleted successfully';
  static const String successCourseUpdate = 'Course updated successfully';
}
