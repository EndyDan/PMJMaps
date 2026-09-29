import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../models/campus_node.dart';
import '../services/vertical_navigation_service.dart';

class ArNavigationTab extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;
  final String destinationName;
  final CampusNode? destinationNode;
  final double? userLat;
  final double? userLng;
  final int? userFloor;
  final double? userElevation;
  final bool isRecalibrated;
  final Future<CampusNode?> Function() onOpenScanner;

  const ArNavigationTab({
    super.key,
    this.destinationLat = 2.431254,
    this.destinationLng = 103.834120,
    this.destinationName = 'JTMK Department',
    this.destinationNode,
    this.userLat,
    this.userLng,
    this.userFloor,
    this.userElevation,
    this.isRecalibrated = false,
    required this.onOpenScanner,
  });

  @override
  State<ArNavigationTab> createState() => _ArNavigationTabState();
}

class _ArNavigationTabState extends State<ArNavigationTab> {
  CameraController? _cameraController;
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _positionSubscription;

  double? _deviceHeading;
  double? _distanceToDestination;
  double? _targetBearing;
  double? _userElevation;
  int? _userFloor;
  bool _isRecalibrated = false;
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _userFloor = widget.userFloor;
    _isRecalibrated = widget.isRecalibrated;
    final latitude = widget.userLat;
    final longitude = widget.userLng;
    final elevation = widget.userElevation;
    if (latitude != null && longitude != null && elevation != null) {
      _updateNavigationVector(latitude, longitude, elevation);
    }
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([_initializeCamera(), _initializeLocation()]);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No camera is available on this device.');
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() => _cameraController = controller);
    } on CameraException catch (error) {
      _setInitializationError(
        'Unable to initialize the camera: ${error.description ?? error.code}.',
      );
    } on StateError catch (error) {
      _setInitializationError(error.message);
    }
  }

  Future<void> _initializeLocation() async {
    _compassSubscription = FlutterCompass.events?.listen(
      (event) {
        if (!mounted || event.heading == null) {
          return;
        }
        setState(() => _deviceHeading = event.heading);
      },
      onError: (Object error) {
        _setInitializationError('Unable to read the device heading: $error');
      },
    );

    if (_isRecalibrated) {
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (_isRecalibrated) {
      return;
    }
    if (!serviceEnabled) {
      _setInitializationError('Location services are disabled.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (_isRecalibrated) {
      return;
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _setInitializationError(
        'Location permission is required for AR navigation.',
      );
      return;
    }

    _positionSubscription = Geolocator.getPositionStream().listen(
      _updatePosition,
      onError: (Object error) {
        _setInitializationError('Unable to read the current location: $error');
      },
    );
  }

  void _updatePosition(Position position) {
    if (!mounted || _isRecalibrated) {
      return;
    }

    setState(() {
      _updateNavigationVector(
        position.latitude,
        position.longitude,
        position.altitude,
      );
    });
  }

  void _updateNavigationVector(
    double latitude,
    double longitude,
    double elevation,
  ) {
    _distanceToDestination = Geolocator.distanceBetween(
      latitude,
      longitude,
      widget.destinationLat,
      widget.destinationLng,
    );
    _userElevation = elevation;
    _targetBearing = Geolocator.bearingBetween(
      latitude,
      longitude,
      widget.destinationLat,
      widget.destinationLng,
    );
  }

  Future<void> _scanIndoorWaypoint() async {
    final node = await widget.onOpenScanner();
    if (!mounted || node == null) {
      return;
    }

    setState(() {
      _isRecalibrated = true;
      _userFloor = node.floor;
      _initializationError = null;
      _updateNavigationVector(node.latitude, node.longitude, node.elevation);
    });
  }

  void _setInitializationError(String message) {
    if (mounted) {
      setState(() => _initializationError = message);
    }
  }

  double get _arrowRotation {
    final heading = _deviceHeading;
    final bearing = _targetBearing;
    if (heading == null || bearing == null) {
      return 0;
    }

    final relativeBearing = (bearing - heading + 360) % 360;
    return relativeBearing * math.pi / 180;
  }

  VerticalNavigationHint? get _verticalHint {
    final targetNode = widget.destinationNode;
    final userElevation = _userElevation;
    if (targetNode == null || userElevation == null) {
      return null;
    }

    return VerticalNavigationService.compare(
      targetNode: targetNode,
      userElevation: userElevation,
      userFloor: _userFloor,
      horizontalDistanceMeters: _distanceToDestination ?? 0,
    );
  }

  @override
  void dispose() {
    unawaited(_compassSubscription?.cancel());
    unawaited(_positionSubscription?.cancel());
    final cameraController = _cameraController;
    if (cameraController != null) {
      unawaited(cameraController.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = _cameraController;

    return Scaffold(
      backgroundColor: const Color(0xFF030A24),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (cameraController?.value.isInitialized == true)
            CameraPreview(cameraController!)
          else
            const ColoredBox(color: Color(0xFF030A24)),
          if (_initializationError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _initializationError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                _buildHud(),
                _buildVerticalHintBadge(),
                const Spacer(),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateZ(_arrowRotation)
                    ..rotateX(-(_verticalHint?.pitchOffsetRadians ?? 0)),
                  child: const Icon(
                    Icons.navigation,
                    color: Color(0xFF4DA3FF),
                    size: 96,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 18)],
                  ),
                ),
                const Spacer(),
                _buildScanButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHud() {
    final distance = _distanceToDestination;
    final distanceText = distance == null ? '-- m' : '${distance.round()} m';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF030A24).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const Icon(Icons.place, color: Color(0xFF4DA3FF)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.destinationName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  distanceText,
                  style: const TextStyle(
                    color: Color(0xFF8EC5FF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalHintBadge() {
    final hint = _verticalHint;
    if (hint == null) {
      return const SizedBox.shrink();
    }

    final icon = switch (hint.direction) {
      VerticalLocationDirection.above => Icons.arrow_upward,
      VerticalLocationDirection.below => Icons.arrow_downward,
      VerticalLocationDirection.sameFloor => Icons.horizontal_rule,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF030A24).withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF4DA3FF)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF8EC5FF)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hint.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _scanIndoorWaypoint,
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan Indoor Waypoint QR'),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFF030A24),
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF4DA3FF), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
