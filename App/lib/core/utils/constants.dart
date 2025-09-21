class AppConstants {
  // User Types (renamed for compatibility with MockDataService)
  static const String roleCitizen = 'citizen';
  static const String roleStaff = 'staff';
  static const String roleAdmin = 'admin';

  // Legacy user types (for backward compatibility)
  static const String userTypeCitizen = roleCitizen;
  static const String userTypeStaff = roleStaff;
  static const String userTypeAdmin = roleAdmin;

  // Issue Status
  static const String statusSubmitted = 'submitted';
  static const String statusAcknowledged = 'acknowledged';
  static const String statusInProgress = 'in_progress';
  static const String statusResolved = 'resolved';
  static const String statusRejected = 'rejected';

  // Issue Priority
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';

  // App Info
  static const String appName = 'Jan Mitra';
  static const String appVersion = '1.0.0';

  // Storage Buckets
  static const String bucketIssueImages = 'issue_images';
  static const String bucketProfileImages = 'profile_images';

  // Storage Paths
  static const String pathIssues = 'issues';
  static const String pathProfiles = 'profiles';

  // Pagination
  static const int defaultPageSize = 10;

  // Map
  static const double defaultMapZoom = 15.0;
  static const double defaultMapLatitude = 28.6139;
  static const double defaultMapLongitude = 77.2090;

  // Timeouts
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds

  // Cache Keys
  static const String cacheKeyUser = 'user';
  static const String cacheKeyToken = 'token';
  static const String cacheKeyIssues = 'issues';
  static const String cacheKeyNotifications = 'notifications';

  // Feature Flags
  static const bool enableVoiceInput = true;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableFeedback = true;
}
