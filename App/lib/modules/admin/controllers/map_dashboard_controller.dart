import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jan_mitra/core/utils/constants.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/data/repository/issue_repository.dart';

class MapDashboardController extends GetxController {
  final IssueRepository _issueRepository = Get.find<IssueRepository>();

  final RxList<IssueModel> allIssues = <IssueModel>[].obs;
  final RxMap<String, Marker> markers = <String, Marker>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Filter options
  final RxString statusFilter = 'all'.obs;
  final RxString priorityFilter = 'all'.obs;

  // Map controller
  Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final Rx<CameraPosition> initialCameraPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629), // Center of India
    zoom: 5,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    getAllIssues();
  }

  @override
  void onClose() {
    mapController.value?.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController.value = controller;
  }

  Future<void> getAllIssues() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      allIssues.value = await _issueRepository.getAllIssues();
      _createMarkers();
    } catch (e) {
      errorMessage.value = 'Failed to get issues: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await getAllIssues();
  }

  void setStatusFilter(String status) {
    statusFilter.value = status;
    _createMarkers();
  }

  void setPriorityFilter(String priority) {
    priorityFilter.value = priority;
    _createMarkers();
  }

  List<IssueModel> get filteredIssues {
    return allIssues.where((issue) {
      bool statusMatch =
          statusFilter.value == 'all' || issue.status == statusFilter.value;
      bool priorityMatch =
          priorityFilter.value == 'all' ||
          issue.priority == priorityFilter.value;
      return statusMatch && priorityMatch;
    }).toList();
  }

  void _createMarkers() {
    final Map<String, Marker> markerMap = {};

    for (var issue in filteredIssues) {
      final markerId = MarkerId(issue.id);

      final marker = Marker(
        markerId: markerId,
        position: LatLng(issue.location.latitude, issue.location.longitude),
        infoWindow: InfoWindow(
          title: issue.title,
          snippet:
              'Status: ${issue.status.capitalize}, Priority: ${issue.priority.capitalize}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerHue(issue.status),
        ),
        onTap: () {
          // Navigate to issue details
          Get.toNamed('/admin/issue-details', arguments: {'issueId': issue.id});
        },
      );

      markerMap[issue.id] = marker;
    }

    markers.value = markerMap;

    // If we have issues, move camera to first issue
    if (filteredIssues.isNotEmpty) {
      final firstIssue = filteredIssues.first;
      _moveCamera(firstIssue.location.latitude, firstIssue.location.longitude);
    }
  }

  void _moveCamera(double latitude, double longitude) {
    if (mapController.value != null) {
      mapController.value!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 14.0),
      );
    }
  }

  double _getMarkerHue(String status) {
    switch (status) {
      case AppConstants.statusSubmitted:
        return BitmapDescriptor.hueOrange; // Amber
      case AppConstants.statusAcknowledged:
        return BitmapDescriptor.hueAzure; // Blue
      case AppConstants.statusInProgress:
        return BitmapDescriptor.hueViolet; // Purple
      case AppConstants.statusResolved:
        return BitmapDescriptor.hueGreen; // Green
      case AppConstants.statusRejected:
        return BitmapDescriptor.hueRed; // Red
      default:
        return BitmapDescriptor.hueYellow;
    }
  }

  // Clustering logic could be added here for better performance with many markers
}
