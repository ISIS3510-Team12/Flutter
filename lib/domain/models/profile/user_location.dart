class UserLocation {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.notifyWithin,
  });

  final double latitude;
  final double longitude;
  final int notifyWithin;

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      notifyWithin: json['notify_within'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'notify_within': notifyWithin,
  };
}
