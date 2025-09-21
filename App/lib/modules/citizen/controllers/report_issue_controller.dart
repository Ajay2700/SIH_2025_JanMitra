import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
// Speech to text temporarily disabled
// import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:jan_mitra/core/utils/constants.dart';
import 'package:jan_mitra/data/models/user_model.dart';
import 'package:jan_mitra/data/repository/auth_repository.dart';
import 'package:jan_mitra/data/repository/issue_repository.dart';
import 'package:jan_mitra/routes/app_routes.dart';

class ReportIssueController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final IssueRepository _issueRepository = Get.find<IssueRepository>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxString address = ''.obs;
  final RxString priority = AppConstants.priorityMedium.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Speech to text (temporarily disabled)
  // final stt.SpeechToText _speech = stt.SpeechToText();
  final RxBool isListening = false.obs;
  final RxString recognizedText = ''.obs;
  final RxDouble speechConfidence = 0.0.obs;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getCurrentUser();
    getCurrentLocation();
    _initSpeech();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Initialize speech recognition (temporarily disabled)
  Future<void> _initSpeech() async {
    // Speech recognition disabled due to compatibility issues
    print("Speech recognition disabled");
  }

  Future<void> getCurrentUser() async {
    try {
      currentUser.value = await _authRepository.getCurrentUser();
    } catch (e) {
      errorMessage.value = 'Failed to get user: ${e.toString()}';
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage.value = 'Location services are disabled.';
        _useMockLocationData();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorMessage.value = 'Location permissions are denied.';
          _useMockLocationData();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage.value = 'Location permissions are permanently denied.';
        _useMockLocationData();
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      await getAddressFromLatLng();
    } catch (e) {
      print('Location error: ${e.toString()}');
      errorMessage.value = 'Failed to get location: ${e.toString()}';
      _useMockLocationData();
    }
  }

  void _useMockLocationData() {
    // Use a default location if we can't get the actual location
    latitude.value = 28.6139;
    longitude.value = 77.2090;
    address.value = 'Location not available. Please enable location services.';
  }

  Future<void> getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude.value,
        longitude.value,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        address.value =
            '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}';
      }
    } catch (e) {
      print('Geocoding error: ${e.toString()}');
      // Use a default address if geocoding fails
      address.value = 'Near ${latitude.value}, ${longitude.value}';
    }
  }

  Future<void> pickImage() async {
    try {
      await showImageSourceDialog();
    } catch (e) {
      print('Image picker error: ${e.toString()}');
      errorMessage.value = 'Failed to pick image: ${e.toString()}';
    }
  }

  Future<void> showImageSourceDialog() async {
    await Get.dialog(
      AlertDialog(
        title: Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Get.back();
                _getImageFromSource(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Get.back();
                _getImageFromSource(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImageFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      print('Image picker error: ${e.toString()}');
      errorMessage.value = 'Failed to pick image: ${e.toString()}';
    }
  }

  void setPriority(String value) {
    priority.value = value;
  }

  // Start speech recognition (temporarily disabled)
  Future<void> startListening() async {
    Get.snackbar(
      'Feature Disabled',
      'Speech recognition is temporarily disabled due to compatibility issues.',
      backgroundColor: Colors.orange[100],
      colorText: Colors.orange[800],
      duration: Duration(seconds: 3),
    );
  }

  // Stop speech recognition (temporarily disabled)
  void stopListening() {
    isListening.value = false;
  }

  // Toggle speech recognition (temporarily disabled)
  void toggleListening() {
    Get.snackbar(
      'Feature Disabled',
      'Speech recognition is temporarily disabled due to compatibility issues.',
      backgroundColor: Colors.orange[100],
      colorText: Colors.orange[800],
      duration: Duration(seconds: 3),
    );
  }

  Future<void> submitIssue() async {
    if (currentUser.value == null) {
      errorMessage.value = 'User not logged in.';
      return;
    }

    if (titleController.text.isEmpty) {
      errorMessage.value = 'Please enter a title.';
      return;
    }

    if (descriptionController.text.isEmpty) {
      errorMessage.value = 'Please enter a description.';
      return;
    }

    if (selectedImage.value == null) {
      errorMessage.value = 'Please select an image.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _issueRepository.createIssue(
        title: titleController.text,
        description: descriptionController.text,
        imagePath: selectedImage.value!.path,
        latitude: latitude.value,
        longitude: longitude.value,
        address: address.value,
        priority: priority.value,
        userId: currentUser.value!.id,
      );

      Get.snackbar(
        'Success',
        'Issue reported successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offNamed(Routes.CITIZEN_HOME);
    } catch (e) {
      errorMessage.value = 'Failed to submit issue: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
