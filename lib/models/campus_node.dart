import '../data/campus_levels.dart';

class CampusNode {
  final String name;
  final double latitude;
  final double longitude;
  final int? floor;
  final double elevation;
  final String? qrCode;

  const CampusNode({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.floor,
    required this.elevation,
    this.qrCode,
  });

  factory CampusNode.fromJson(Map<String, dynamic> json) {
    return CampusNode(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      floor: json['floor'] as int?,
      elevation: (json['elevation'] as num).toDouble(),
      qrCode: json['qrCode'] as String?,
    );
  }

  String get floorLabel => campusFloorLabel(floor) ?? 'Unknown level';

  CampusNode copyWith({int? floor, String? qrCode}) => CampusNode(
    name: name,
    latitude: latitude,
    longitude: longitude,
    floor: floor ?? this.floor,
    elevation: elevation,
    qrCode: qrCode ?? this.qrCode,
  );
}
