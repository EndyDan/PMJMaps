import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectoryItem {
  final String room;
  final String block;
  final String floor;
  final String tag;
  final String desc;
  final LatLng coordinates;

  const DirectoryItem({
    required this.room,
    required this.block,
    required this.floor,
    required this.tag,
    required this.desc,
    required this.coordinates,
  });

  String get markerId =>
      room.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
}
