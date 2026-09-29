import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../models/campus_node.dart';

enum VerticalLocationDirection { above, below, sameFloor }

class VerticalNavigationHint {
  final VerticalLocationDirection direction;
  final String message;
  final int? floorDelta;
  final double elevationDeltaMeters;
  final double pitchOffsetRadians;

  const VerticalNavigationHint({
    required this.direction,
    required this.message,
    required this.floorDelta,
    required this.elevationDeltaMeters,
    required this.pitchOffsetRadians,
  });
}

class NavigationLocationState {
  final List<CampusNode> nodes;

  double? userLat;
  double? userLng;
  int? userFloor;
  double? userElevation;
  bool isRecalibrated = false;
  CampusNode? recalibratedNode;

  NavigationLocationState(Iterable<CampusNode> nodes)
    : nodes = List<CampusNode>.unmodifiable(nodes);

  bool recalibrateFromQR(String scannedCode) {
    CampusNode? matchedNode;
    for (final node in nodes) {
      if (node.qrCode == scannedCode) {
        matchedNode = node;
        break;
      }
    }
    if (matchedNode == null) {
      return false;
    }

    userLat = matchedNode.latitude;
    userLng = matchedNode.longitude;
    userFloor = matchedNode.floor;
    userElevation = matchedNode.elevation;
    isRecalibrated = true;
    recalibratedNode = matchedNode;
    return true;
  }
}

class VerticalNavigationService {
  static const double elevationThresholdMeters = 3.0;
  static Future<List<CampusNode>>? _cachedNodes;

  const VerticalNavigationService._();

  static Future<List<CampusNode>> loadNodes() => _cachedNodes ??= _readNodes();

  static Future<CampusNode?> findNodeByName(String name) async {
    final normalizedName = _normalizeName(name);
    for (final node in await loadNodes()) {
      if (_normalizeName(node.name) == normalizedName) {
        return node;
      }
    }
    return null;
  }

  static int? floorFromLabel(String label) {
    if (RegExp(
      r'\b(?:ground|ground floor|ground level)\b',
      caseSensitive: false,
    ).hasMatch(label)) {
      return 0;
    }
    final match = RegExp(
      r'\b(?:fl|floor|level|aras)\s*[-:]?\s*(\d+)\b',
      caseSensitive: false,
    ).firstMatch(label);
    return match == null ? null : int.parse(match.group(1)!);
  }

  static Future<List<CampusNode>> _readNodes() async {
    final contents = await rootBundle.loadString(
      'assets/data/campus_nodes.json',
    );
    final decoded = jsonDecode(contents);
    if (decoded is! List) {
      throw const FormatException('Campus node data must be a JSON list.');
    }

    return List<CampusNode>.unmodifiable(
      decoded.map((entry) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException(
            'Each campus node must be a JSON object.',
          );
        }
        return CampusNode.fromJson(entry);
      }),
    );
  }

  static String _normalizeName(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static VerticalNavigationHint compare({
    required CampusNode targetNode,
    required double userElevation,
    int? userFloor,
    required double horizontalDistanceMeters,
  }) {
    final elevationDelta = targetNode.elevation - userElevation;
    final targetFloor = targetNode.floor;
    final floorDelta = userFloor == null || targetFloor == null
        ? 0
        : targetFloor - userFloor;

    final direction = floorDelta > 0
        ? VerticalLocationDirection.above
        : floorDelta < 0
        ? VerticalLocationDirection.below
        : elevationDelta > elevationThresholdMeters
        ? VerticalLocationDirection.above
        : elevationDelta < -elevationThresholdMeters
        ? VerticalLocationDirection.below
        : VerticalLocationDirection.sameFloor;

    final floorLabel = targetNode.floorLabel;
    final message = floorLabel == 'Unknown level'
        ? switch (direction) {
            VerticalLocationDirection.above => 'Destination is above you',
            VerticalLocationDirection.below => 'Destination is below you',
            VerticalLocationDirection.sameFloor => 'On your floor',
          }
        : 'Destination is on ${targetNode.floor == 0 ? floorLabel.toLowerCase() : floorLabel}';

    return VerticalNavigationHint(
      direction: direction,
      message: message,
      floorDelta: userFloor == null || targetFloor == null ? null : floorDelta,
      elevationDeltaMeters: elevationDelta,
      pitchOffsetRadians: math.atan2(
        _pitchElevationDelta(floorDelta, elevationDelta),
        math.max(0, horizontalDistanceMeters),
      ),
    );
  }

  static double _pitchElevationDelta(int floorDelta, double elevationDelta) {
    if (floorDelta != 0) {
      return floorDelta * elevationThresholdMeters;
    }
    return elevationDelta;
  }
}
