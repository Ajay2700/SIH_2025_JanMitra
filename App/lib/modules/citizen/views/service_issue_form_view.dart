import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jan_mitra/core/ui/app_button.dart';
import 'package:jan_mitra/core/ui/app_text_field.dart';
import 'package:jan_mitra/core/ui/app_loading.dart';
import 'package:jan_mitra/data/services/issue_service_supabase.dart';
import 'package:jan_mitra/routes/app_routes.dart';
import 'package:jan_mitra/data/services/firebase_auth_service.dart';
import 'package:jan_mitra/core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:jan_mitra/data/models/issue_model.dart';
// import 'package:jan_mitra/data/models/location_model.dart';

class ServiceIssueFormController extends GetxController {
  late IssueServiceSupabase _issueService;
  final LocationService _locationService = LocationService();

  final RxString serviceType = ''.obs;
  final RxString title = ''.obs;
  final RxString description = ''.obs;
  final RxString locationAddress = ''.obs;
  final RxString priority = 'medium'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGettingLocation = false.obs;
  final RxString errorMessage = ''.obs;

  // Location variables
  final RxDouble latitude = 28.6139.obs; // Default to Delhi
  final RxDouble longitude = 77.2090.obs;
  final RxBool locationFetched = false.obs;
  final Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final RxSet<Marker> markers = <Marker>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['serviceType'] != null) {
      serviceType.value = args['serviceType'];
      _initializeFormData();
    }
    // Auto-fetch location when form opens
    getCurrentLocation();
  }

  @override
  void onClose() {
    mapController.value?.dispose();
    super.onClose();
  }

  void _initializeService() {
    try {
      _issueService = Get.find<IssueServiceSupabase>();
    } catch (e) {
      // If service is not found, initialize it
      _issueService = Get.put(IssueServiceSupabase());
    }
  }

  void _initializeFormData() {
    switch (serviceType.value) {
      case 'garbage_collection':
        title.value = 'Garbage Collection Request';
        description.value = 'Please describe the garbage collection issue...';
        break;
      case 'complaint':
        title.value = 'Civic Complaint';
        description.value = 'Please describe your complaint...';
        break;
      case 'animal':
        title.value = 'Animal-Related Issue';
        description.value = 'Please describe the animal-related issue...';
        break;
    }
  }

  String get serviceTitle {
    switch (serviceType.value) {
      case 'garbage_collection':
        return 'Garbage Collection';
      case 'complaint':
        return 'Raise Complaint';
      case 'animal':
        return 'Animal Issue';
      default:
        return 'Service Request';
    }
  }

  IconData get serviceIcon {
    switch (serviceType.value) {
      case 'garbage_collection':
        return Icons.local_shipping;
      case 'complaint':
        return Icons.report_problem;
      case 'animal':
        return Icons.pets;
      default:
        return Icons.help_outline;
    }
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    isGettingLocation.value = true;
    errorMessage.value = '';

    try {
      Position? position = await _locationService.getCurrentPosition();
      if (position != null) {
        latitude.value = position.latitude;
        longitude.value = position.longitude;
        selectedLocation.value = LatLng(position.latitude, position.longitude);

        // Get address from coordinates
        String address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        locationAddress.value = address;

        // Update map marker
        _updateMapMarker();

        locationFetched.value = true;
        print(
          'DEBUG: Location fetched: ${position.latitude}, ${position.longitude}',
        );
      } else {
        errorMessage.value =
            'Unable to get current location. Please check location permissions.';
      }
    } catch (e) {
      print('DEBUG: Error getting location: $e');
      errorMessage.value = 'Error getting location: $e';
    } finally {
      isGettingLocation.value = false;
    }
  }

  // Update map marker
  void _updateMapMarker() {
    if (selectedLocation.value != null) {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: selectedLocation.value!,
          infoWindow: const InfoWindow(title: 'Issue Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  // Handle map tap to select custom location
  void onMapTap(LatLng position) async {
    selectedLocation.value = position;
    latitude.value = position.latitude;
    longitude.value = position.longitude;

    // Get address for the tapped location
    try {
      String address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      locationAddress.value = address;
    } catch (e) {
      locationAddress.value = 'Custom location selected';
    }

    _updateMapMarker();
  }

  // Move camera to current location
  void moveToCurrentLocation() {
    if (selectedLocation.value != null && mapController.value != null) {
      mapController.value!.animateCamera(
        CameraUpdate.newLatLngZoom(selectedLocation.value!, 16),
      );
    }
  }

  Future<void> submitIssue() async {
    print('DEBUG: submitIssue called');
    if (title.value.isEmpty || description.value.isEmpty) {
      errorMessage.value = 'Please fill in all required fields';
      return;
    }

    if (!locationFetched.value) {
      errorMessage.value =
          'Please wait for location to be fetched or select a location on the map';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Get authenticated user ID (authentication is required)
      final authService = Get.find<FirebaseAuthService>();
      final currentUser = authService.getCurrentUser()!;
      final userId = currentUser.id;
      print('DEBUG: User ID: $userId');

      print(
        'DEBUG: Calling _issueService.createIssue with location: ${latitude.value}, ${longitude.value}',
      );
      await _issueService.createIssue(
        title: title.value,
        description: description.value,
        latitude: latitude.value,
        longitude: longitude.value,
        address: locationAddress.value,
        priority: priority.value,
        userId: userId,
      );
      print('DEBUG: createIssue succeeded');

      Get.snackbar(
        'Success',
        'Your ${serviceTitle.toLowerCase()} request has been submitted successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      // Navigate to citizen home (which has My Issues tab)
      Get.offAllNamed(Routes.CITIZEN_HOME);
    } catch (e) {
      print('DEBUG: submitIssue failed: $e');
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

class ServiceIssueFormView extends GetView<ServiceIssueFormController> {
  const ServiceIssueFormView({super.key});

  @override
  Widget build(BuildContext context) {
    // Require Firebase authentication - no demo mode
    bool firebaseInitialized = false;
    try {
      firebaseInitialized = Get.find<bool>(tag: 'firebaseInitialized') ?? false;
    } catch (e) {
      // Firebase initialization status not available yet, assume false
      firebaseInitialized = false;
    }

    // Always require authentication - redirect to login if not authenticated
    if (!firebaseInitialized) {
      // Firebase not initialized, show loading
      return const Scaffold(
        body: Center(
          child: AppLoading(message: 'Initializing authentication...'),
        ),
      );
    }

    final authService = Get.find<FirebaseAuthService>();
    if (!authService.isAuthenticated.value ||
        authService.getCurrentUser() == null) {
      // User not authenticated, redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(Routes.LOGIN);
      });
      return const Scaffold(
        body: Center(child: AppLoading(message: 'Redirecting to login...')),
      );
    }

    Get.put(ServiceIssueFormController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.serviceTitle)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Icon and Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        controller.serviceIcon,
                        size: 40,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.serviceTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please provide details about your request',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Title Field
              const Text(
                'Title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                hintText: 'Enter a descriptive title',
                onChanged: (value) => controller.title.value = value,
              ),
              const SizedBox(height: 20),

              // Description Field
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                hintText: 'Provide detailed description of the issue',
                onChanged: (value) => controller.description.value = value,
                maxLines: 5,
              ),
              const SizedBox(height: 20),

              // Location Section
              const Text(
                'Location',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Location Status and Controls
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: controller.locationFetched.value
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: controller.locationFetched.value
                          ? Colors.green[200]!
                          : Colors.orange[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.locationFetched.value
                            ? Icons.location_on
                            : Icons.location_searching,
                        color: controller.locationFetched.value
                            ? Colors.green[600]
                            : Colors.orange[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.locationFetched.value
                              ? 'Location detected automatically'
                              : 'Getting your location...',
                          style: TextStyle(
                            color: controller.locationFetched.value
                                ? Colors.green[700]
                                : Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (!controller.locationFetched.value)
                        Obx(
                          () => controller.isGettingLocation.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : TextButton(
                                  onPressed: controller.getCurrentLocation,
                                  child: const Text('Retry'),
                                ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Map Section
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Obx(() {
                  if (controller.selectedLocation.value == null) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Loading map...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: controller.selectedLocation.value!,
                        zoom: 16,
                      ),
                      markers: controller.markers,
                      onMapCreated: (GoogleMapController mapController) {
                        controller.mapController.value = mapController;
                      },
                      onTap: controller.onMapTap,
                      zoomControlsEnabled: false,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                    ),
                  );
                }),
              ),

              // Map Controls
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.getCurrentLocation,
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text('Use Current Location'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.moveToCurrentLocation,
                      icon: const Icon(Icons.center_focus_strong, size: 18),
                      label: const Text('Center Map'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),

              // Address Display
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(
                        () => Text(
                          controller.locationAddress.value.isNotEmpty
                              ? controller.locationAddress.value
                              : 'Tap on map to select location',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Priority Selection
              const Text(
                'Priority',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPriorityOption('low', 'Low', Colors.green),
                    const Divider(height: 1),
                    _buildPriorityOption('medium', 'Medium', Colors.blue),
                    const Divider(height: 1),
                    _buildPriorityOption('high', 'High', Colors.orange),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Error Message
              if (controller.errorMessage.value.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ),
                    ],
                  ),
                ),

              // Submit Button
              AppButton(
                label: 'Submit Request',
                onPressed: controller.isLoading.value
                    ? () {}
                    : () => controller.submitIssue(),
                isLoading: controller.isLoading.value,
                isFullWidth: true,
                size: AppButtonSize.large,
              ),
              const SizedBox(height: 20),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your request will be reviewed and processed by the concerned department.',
                        style: TextStyle(color: Colors.blue[600], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption(String value, String label, Color color) {
    return Obx(() {
      final isSelected = controller.priority.value == value;

      return InkWell(
        onTap: () => controller.priority.value = value,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? color : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
