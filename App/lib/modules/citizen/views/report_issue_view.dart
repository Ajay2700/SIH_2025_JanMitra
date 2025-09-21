import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/core/utils/constants.dart';
import 'package:jan_mitra/core/utils/platform_utils.dart';
import 'package:jan_mitra/modules/citizen/controllers/report_issue_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReportIssueView extends StatelessWidget {
  final ReportIssueController _controller = Get.find<ReportIssueController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Report Issue')),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error Message
              if (_controller.errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _controller.errorMessage.value,
                    style: TextStyle(color: Colors.red[900]),
                  ),
                ),

              // Title Field
              TextField(
                controller: _controller.titleController,
                decoration: InputDecoration(
                  labelText: 'Issue Title',
                  hintText: 'e.g., Pothole on Main Street',
                  prefixIcon: Icon(Icons.title),
                ),
                maxLength: 100,
              ),
              SizedBox(height: 16),

              // Description Field with Voice Input
              Stack(
                children: [
                  TextField(
                    controller: _controller.descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe the issue in detail',
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                      suffixIcon: Obx(
                        () => IconButton(
                          icon: Icon(
                            _controller.isListening.value
                                ? Icons.mic
                                : Icons.mic_none,
                            color: _controller.isListening.value
                                ? Colors.red
                                : null,
                          ),
                          onPressed: _controller.toggleListening,
                          tooltip: _controller.isListening.value
                              ? 'Stop recording'
                              : 'Start voice input',
                        ),
                      ),
                    ),
                    maxLines: 5,
                    maxLength: 500,
                  ),
                  Obx(
                    () => _controller.isListening.value
                        ? Positioned(
                            bottom: 10,
                            right: 50,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.graphic_eq,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Listening...',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Image Picker
              Card(
                child: InkWell(
                  onTap: _controller.pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    child: _controller.selectedImage.value != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                _controller.selectedImage.value!,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  radius: 20,
                                  child: IconButton(
                                    icon: Icon(Icons.edit, color: Colors.white),
                                    onPressed: _controller.pickImage,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add a photo of the issue',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Camera or Gallery',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Location Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton.icon(
                    onPressed: _controller.getCurrentLocation,
                    icon: Icon(Icons.my_location, size: 18),
                    label: Text('Update'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[700],
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Map Preview with Draggable Marker
              Container(
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Obx(() {
                    if (_controller.latitude.value != 0.0 &&
                        _controller.longitude.value != 0.0) {
                      // Check if Google Maps is supported on this platform
                      if (PlatformUtils.isGoogleMapsSupported) {
                        // Use a try-catch to handle Google Maps errors
                        try {
                          return _buildGoogleMap();
                        } catch (e) {
                          print("Google Maps error: $e");
                          return _buildLocationFallback();
                        }
                      } else {
                        // Use fallback on platforms where Maps isn't supported
                        return _buildLocationFallback();
                      }
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text(
                              'Getting your location...',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Please enable location services',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
                ),
              ),
              SizedBox(height: 12),

              // Address with icon
              if (_controller.address.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.blue[700],
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _controller.address.value,
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 24),

              // Priority Section
              Text('Priority', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),

              // Priority Selection
              Row(
                children: [
                  _buildPriorityButton(
                    context,
                    AppConstants.priorityLow,
                    'Low',
                    Color(0xFF66BB6A),
                  ),
                  SizedBox(width: 8),
                  _buildPriorityButton(
                    context,
                    AppConstants.priorityMedium,
                    'Medium',
                    Color(0xFFFFA000),
                  ),
                  SizedBox(width: 8),
                  _buildPriorityButton(
                    context,
                    AppConstants.priorityHigh,
                    'High',
                    Color(0xFFEF5350),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _controller.submitIssue,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Submit Issue'),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPriorityButton(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Obx(() {
        final isSelected = _controller.priority.value == value;

        return OutlinedButton(
          onPressed: () => _controller.setPriority(value),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? color.withOpacity(0.2) : null,
            side: BorderSide(
              color: isSelected ? color : Colors.grey,
              width: isSelected ? 2 : 1,
            ),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }),
    );
  }

  // Google Maps widget
  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_controller.latitude.value, _controller.longitude.value),
        zoom: 16,
      ),
      markers: {
        Marker(
          markerId: MarkerId('issue_location'),
          position: LatLng(
            _controller.latitude.value,
            _controller.longitude.value,
          ),
          draggable: true,
          onDragEnd: (LatLng position) {
            _controller.latitude.value = position.latitude;
            _controller.longitude.value = position.longitude;
            _controller.getAddressFromLatLng();
          },
        ),
      },
      zoomControlsEnabled: true,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      mapToolbarEnabled: true,
      onTap: (LatLng position) {
        _controller.latitude.value = position.latitude;
        _controller.longitude.value = position.longitude;
        _controller.getAddressFromLatLng();
      },
    );
  }

  // Fallback for when Google Maps fails
  Widget _buildLocationFallback() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Location Selected',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Latitude: ${_controller.latitude.value.toStringAsFixed(6)}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Longitude: ${_controller.longitude.value.toStringAsFixed(6)}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _controller.getCurrentLocation,
              icon: Icon(Icons.refresh),
              label: Text('Refresh Location'),
            ),
          ],
        ),
      ),
    );
  }
}
