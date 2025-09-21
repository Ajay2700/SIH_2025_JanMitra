class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  @override
  String toString() => 'Location(latitude: $latitude, longitude: $longitude)';
}

// Alias for backward compatibility
typedef LocationModel = Location;
