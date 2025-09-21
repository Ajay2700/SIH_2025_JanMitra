import 'package:get/get.dart';
import 'package:jan_mitra/modules/admin/bindings/admin_binding.dart';
import 'package:jan_mitra/modules/admin/views/admin_home_view.dart';
import 'package:jan_mitra/modules/admin/views/analytics_view.dart';
import 'package:jan_mitra/modules/admin/views/issue_list_view.dart';
import 'package:jan_mitra/modules/admin/views/map_dashboard_view.dart';
import 'package:jan_mitra/modules/admin/views/profile_view.dart' as admin;
import 'package:jan_mitra/modules/auth/bindings/auth_binding.dart';
// import 'package:jan_mitra/modules/auth/views/google_signin_view.dart';
import 'package:jan_mitra/modules/auth/views/login_view.dart';
import 'package:jan_mitra/modules/auth/views/register_view.dart';
import 'package:jan_mitra/modules/auth/views/splash_view.dart';
import 'package:jan_mitra/modules/citizen/bindings/citizen_binding.dart';
import 'package:jan_mitra/modules/citizen/bindings/dynamic_issue_binding.dart';
import 'package:jan_mitra/modules/citizen/bindings/service_issue_binding.dart';
// import 'package:jan_mitra/modules/citizen/bindings/ticket_binding.dart';
// import 'package:jan_mitra/modules/citizen/views/citizen_home_view.dart';
import 'package:jan_mitra/modules/citizen/views/citizen_main_view.dart';
// import 'package:jan_mitra/modules/citizen/views/create_ticket_view.dart';
import 'package:jan_mitra/modules/citizen/views/enhanced_home_view.dart';
import 'package:jan_mitra/modules/citizen/views/services_home_view.dart';
import 'package:jan_mitra/modules/citizen/views/service_issue_form_view.dart';
import 'package:jan_mitra/modules/citizen/views/issue_tracker_view.dart';
import 'package:jan_mitra/modules/citizen/views/my_issues_view.dart';
import 'package:jan_mitra/modules/citizen/views/profile_view.dart';
import 'package:jan_mitra/modules/citizen/views/report_issue_view.dart';
// import 'package:jan_mitra/modules/citizen/views/ticket_details_view.dart';
// import 'package:jan_mitra/modules/citizen/views/tickets_list_view.dart';
import 'package:jan_mitra/modules/citizen/views/user_profile_view.dart';
import 'package:jan_mitra/routes/app_routes.dart';

class AppPages {
  static final routes = [
    // Auth Routes
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(name: Routes.AUTH, page: () => LoginView(), binding: AuthBinding()),

    // Citizen Routes
    GetPage(
      name: Routes.CITIZEN_HOME,
      page: () => CitizenMainView(),
      binding: CitizenBinding(),
    ),
    GetPage(
      name: Routes.SERVICES_HOME,
      page: () => ServicesHomeView(),
      binding: CitizenBinding(),
    ),
    GetPage(
      name: Routes.SERVICE_ISSUE_FORM,
      page: () => ServiceIssueFormView(),
      binding: ServiceIssueBinding(),
    ),
    GetPage(
      name: Routes.REPORT_ISSUE,
      page: () => ReportIssueView(),
      binding: CitizenBinding(),
    ),
    GetPage(
      name: Routes.ISSUE_TRACKER,
      page: () => IssueTrackerView(),
      binding: CitizenBinding(),
    ),
    GetPage(
      name: Routes.MY_ISSUES,
      page: () => const MyIssuesView(),
      binding: DynamicIssueBinding(),
    ),
    GetPage(
      name: Routes.CITIZEN_PROFILE,
      page: () => ProfileView(),
      binding: CitizenBinding(),
    ),
    GetPage(
      name: Routes.ENHANCED_HOME,
      page: () => EnhancedHomeView(),
      binding: CitizenBinding(),
    ),
    GetPage(
      name: Routes.USER_PROFILE,
      page: () => UserProfileView(user: Get.arguments),
    ),

    // Ticket Routes - Temporarily commented out to fix compilation
    // GetPage(
    //   name: Routes.TICKETS_LIST,
    //   page: () => TicketsListView(),
    //   binding: TicketBinding(),
    // ),
    // GetPage(
    //   name: Routes.TICKET_DETAILS,
    //   page: () => TicketDetailsView(),
    //   binding: TicketBinding(),
    // ),
    // GetPage(
    //   name: Routes.CREATE_TICKET,
    //   page: () => CreateTicketView(),
    //   binding: TicketBinding(),
    // ),

    // Admin Routes
    GetPage(
      name: Routes.ADMIN_HOME,
      page: () => AdminHomeView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: Routes.ISSUE_LIST,
      page: () => IssueListView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: Routes.MAP_DASHBOARD,
      page: () => MapDashboardView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: Routes.ANALYTICS,
      page: () => AnalyticsView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: Routes.ADMIN_PROFILE,
      page: () => admin.ProfileView(),
      binding: AdminBinding(),
    ),
  ];
}
