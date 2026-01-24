class AppConstants {
  // App Info
  static const String appName = 'UCBS Attendance';
  static const String appVersion = '1.0.0';
  
  // Routes
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String teacherHomeRoute = '/teacher-home';
  
  // Storage Keys
  static const String isLoggedKey = 'isLogged';
  static const String roleKey = 'role';
  static const String employeeIdKey = 'employee_id';
  static const String userNameKey = 'UserName';
  
  // Roles
  static const String studentRole = 'Student';
  static const String teacherRole = 'Teacher';
  
  // API Endpoints
  static const String detectEndpoint = 'https://nida-untutelar-lustrelessly.ngrok-free.dev/detect';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double cardRadius = 20.0;
}