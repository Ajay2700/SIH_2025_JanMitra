abstract class Routes {
  // Auth Routes
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const AUTH = '/auth';

  // Citizen Routes
  static const CITIZEN_HOME = '/citizen/home';
  static const SERVICES_HOME = '/services-home';
  static const SERVICE_ISSUE_FORM = '/service-issue-form';
  static const ENHANCED_HOME = '/enhanced-home';
  static const USER_PROFILE = '/user-profile';
  static const REPORT_ISSUE = '/citizen/report-issue';
  static const ISSUE_DETAILS = '/citizen/issue-details';
  static const ISSUE_TRACKER = '/citizen/issue-tracker';
  static const MY_ISSUES = '/citizen/my-issues';
  static const CITIZEN_PROFILE = '/citizen/profile';

  // Ticket Routes
  static const TICKETS_LIST = '/citizen/tickets';
  static const TICKET_DETAILS = '/citizen/ticket-details';
  static const CREATE_TICKET = '/citizen/create-ticket';

  // Admin Routes
  static const ADMIN_HOME = '/admin/home';
  static const ISSUE_LIST = '/admin/issue-list';
  static const MAP_DASHBOARD = '/admin/map-dashboard';
  static const ANALYTICS = '/admin/analytics';
  static const ADMIN_PROFILE = '/admin/profile';
}
