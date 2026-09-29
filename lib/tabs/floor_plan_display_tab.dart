import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../data/campus_directory.dart';

class FloorPlanDisplayTab extends StatefulWidget {
  final String scannedLocationName;
  final String? routingTarget;
  final String? routingRouteId;
  final LatLng? routingDestination;
  final String? navigationSteps;
  final VoidCallback onClearRoute;
  final VoidCallback onOpenDirectory;
  final VoidCallback onOpenAr;
  final ValueChanged<bool> onThemeChanged;
  final MapType mapType;
  final ValueChanged<MapType> onMapTypeChanged;

  const FloorPlanDisplayTab({
    super.key,
    required this.scannedLocationName,
    required this.routingTarget,
    required this.routingRouteId,
    required this.routingDestination,
    required this.navigationSteps,
    required this.onClearRoute,
    required this.onOpenDirectory,
    required this.onOpenAr,
    required this.onThemeChanged,
    required this.mapType,
    required this.onMapTypeChanged,
  });

  @override
  State<FloorPlanDisplayTab> createState() => _FloorPlanDisplayTabState();
}

class _FloorPlanDisplayTabState extends State<FloorPlanDisplayTab> {
  bool _locationPermissionGranted = false;
  bool _locationPermissionDeniedForever = false;
  bool _mapConnectionChecked = false;
  bool _mapConnectionAvailable = false;
  Set<Polyline> _polylines = {};
  GoogleMapController? _mapController;

  static final Set<Factory<OneSequenceGestureRecognizer>>
  _mapGestureRecognizers = {
    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
  };

  static const _defaultOrigin = LatLng(2.4156667, 103.8279219);
  static const _defaultCameraPosition = CameraPosition(
    target: LatLng(2.4156667, 103.8279219),
    zoom: 17.5,
  );

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _checkMapConnection();
  }

  Future<void> _checkMapConnection() async {
    try {
      final addresses = await InternetAddress.lookup('maps.googleapis.com');
      if (!mounted) {
        return;
      }
      setState(() {
        _mapConnectionAvailable = addresses.isNotEmpty;
        _mapConnectionChecked = true;
      });
    } on SocketException {
      if (!mounted) {
        return;
      }
      setState(() {
        _mapConnectionAvailable = false;
        _mapConnectionChecked = true;
      });
    }
  }

  @override
  void didUpdateWidget(covariant FloorPlanDisplayTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routingTarget == null) {
      if (_polylines.isNotEmpty) {
        setState(() => _polylines = {});
      }
      return;
    }

    if (widget.routingTarget != oldWidget.routingTarget ||
        widget.routingRouteId != oldWidget.routingRouteId ||
        widget.routingDestination != oldWidget.routingDestination ||
        widget.scannedLocationName != oldWidget.scannedLocationName) {
      _drawActiveRoute();
    }
  }

  void _drawActiveRoute() {
    final routeId = widget.routingRouteId;
    final destination =
        widget.routingDestination ??
        (routeId == null ? null : officeRouteCoordinates[routeId]);
    if (destination == null) {
      return;
    }

    drawRoute(_originForLocation(widget.scannedLocationName), destination);
  }

  LatLng _originForLocation(String location) {
    final normalized = location.toLowerCase();
    if (normalized.contains('jke')) {
      return officeRouteCoordinates['jke_office']!;
    }
    if (normalized.contains('jtmk')) {
      return officeRouteCoordinates['jtmk_office']!;
    }
    if (normalized.contains('jmsk')) {
      return officeRouteCoordinates['jmsk_office']!;
    }
    if (normalized.contains('jp ')) {
      return officeRouteCoordinates['jp_office']!;
    }
    if (normalized.contains('hep')) {
      return officeRouteCoordinates['hep_office']!;
    }
    return _defaultOrigin;
  }

  void drawRoute(LatLng origin, LatLng destination) {
    final midpoint = LatLng(
      (origin.latitude + destination.latitude) / 2,
      (origin.longitude + destination.longitude) / 2,
    );
    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('active_route'),
          color: Colors.blue,
          width: 5,
          points: [origin, midpoint, destination],
        ),
      };
    });
  }

  Future<void> _checkLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location services are off'),
          content: const Text(
            'Turn on location services to display your position on campus.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: const Text('Open settings'),
            ),
          ],
        ),
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _locationPermissionGranted =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
      _locationPermissionDeniedForever =
          permission == LocationPermission.deniedForever;
    });
  }

  Future<void> _centerOnUserLocation() async {
    if (!_locationPermissionGranted) {
      await _checkLocationPermission();
    }
    if (!_locationPermissionGranted || !mounted) {
      _showLocationError('Location permission is required to center the map.');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final controller = _mapController;
      if (controller == null) {
        _showLocationError('The map is still loading. Please try again.');
        return;
      }
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          18,
        ),
      );
    } on LocationServiceDisabledException {
      _showLocationError('Turn on location services to center the map.');
    } on PermissionDeniedException {
      _showLocationError('Location permission is required to center the map.');
    } on TimeoutException {
      _showLocationError('Could not get your location. Please try again.');
    }
  }

  void _showLocationError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveRoute = widget.routingTarget != null;
    final routeId = widget.routingRouteId;
    final destination =
        widget.routingDestination ??
        (routeId == null ? null : officeRouteCoordinates[routeId]);
    final markers = <Marker>{
      if (hasActiveRoute && destination != null)
        Marker(
          markerId: const MarkerId('active_route_destination'),
          position: destination,
          infoWindow: InfoWindow(
            title: widget.routingTarget!.split(' (').first,
          ),
        ),
    };

    return _buildMapScreen(markers, hasActiveRoute);
  }

  Widget _buildMapScreen(Set<Marker> markers, bool hasActiveRoute) {
    return Stack(
      fit: StackFit.expand,
      children: [
        !_mapConnectionChecked
            ? const ColoredBox(
                color: Color(0xFF0B1738),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                ),
              )
            : !_mapConnectionAvailable
            ? const _MapFailureCard()
            : GoogleMap(
                initialCameraPosition: _defaultCameraPosition,
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: _locationPermissionGranted,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                gestureRecognizers: _mapGestureRecognizers,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                markers: markers,
                polylines: _polylines,
                mapType: widget.mapType,
              ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF030A24).withValues(alpha: 0.35),
                    Colors.transparent,
                    const Color(0xFF030A24).withValues(alpha: 0.55),
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 14,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: _GlassMapButton(
                  onTap: widget.onOpenDirectory,
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: Color(0xFFB9C6E8)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search departments, classrooms...',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFB9C6E8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _GlassMapIconButton(
                icon: Icons.tune_rounded,
                onTap: widget.onOpenDirectory,
              ),
            ],
          ),
        ),
        Positioned(
          top: 90,
          right: 16,
          child: Column(
            children: [
              _GlassMapIconButton(
                icon: Icons.layers_rounded,
                onTap: () => widget.onMapTypeChanged(
                  widget.mapType == MapType.normal
                      ? MapType.satellite
                      : MapType.normal,
                ),
              ),
              const SizedBox(height: 10),
              _GlassMapIconButton(
                icon: Icons.my_location_rounded,
                onTap: _centerOnUserLocation,
              ),
            ],
          ),
        ),
        if (hasActiveRoute)
          Positioned(
            left: 16,
            right: 16,
            bottom: 112,
            child: _ActiveRouteCard(
              target: widget.routingTarget!,
              navigationSteps: widget.navigationSteps,
              onClearRoute: widget.onClearRoute,
              onOpenAr: widget.onOpenAr,
            ),
          ),
        if (_locationPermissionDeniedForever)
          Positioned(
            left: 16,
            right: 16,
            bottom: hasActiveRoute ? 264 : 172,
            child: const _PermissionBanner(),
          ),
      ],
    );
  }
}

class _GlassMapButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _GlassMapButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xE60B1738),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x665C78B4)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44030A24),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassMapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassMapIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xE60B1738),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x665C78B4)),
          ),
          child: Icon(icon, color: const Color(0xFFE5EEFF), size: 23),
        ),
      ),
    );
  }
}

class _ActiveRouteCard extends StatelessWidget {
  final String target;
  final String? navigationSteps;
  final VoidCallback onClearRoute;
  final VoidCallback onOpenAr;

  const _ActiveRouteCard({
    required this.target,
    required this.navigationSteps,
    required this.onClearRoute,
    required this.onOpenAr,
  });

  @override
  Widget build(BuildContext context) {
    final destination = target.split(' (').first;
    final floor = target.contains(', ')
        ? target.split(', ').last.replaceAll(')', '')
        : 'Indoor route';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xF21B2949),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x805C78B4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66030A24),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x668EA4D4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ACTIVE ROUTE',
                  style: TextStyle(
                    color: Color(0xFF9CAED5),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClearRoute,
                icon: const Icon(Icons.close_rounded),
                color: const Color(0xFFB9C6E8),
                visualDensity: VisualDensity.compact,
                tooltip: 'Clear route',
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  destination,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                constraints: const BoxConstraints(maxWidth: 86),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF31405F),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x665C78B4)),
                ),
                child: Text(
                  floor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE2EBFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.route_rounded, color: Color(0xFF00E5FF), size: 17),
              SizedBox(width: 7),
              Text(
                'Indoor route',
                style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 6),
              Text(
                '·',
                style: TextStyle(color: Color(0xFF9CAED5), fontSize: 14),
              ),
              SizedBox(width: 6),
              Text(
                'Follow highlighted path',
                style: TextStyle(color: Color(0xFFD4E2FF), fontSize: 13),
              ),
            ],
          ),
          if (navigationSteps != null && navigationSteps!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              navigationSteps!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFB9C6E8),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpenAr,
              icon: const Icon(Icons.navigation_rounded, size: 19),
              label: const Text('Start navigation'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00D9E9),
                foregroundColor: const Color(0xFF03122D),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner();

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Color(0xF20B1738),
      borderRadius: BorderRadius.all(Radius.circular(14)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'Location permission is disabled. Enable it to show your position.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFD4E2FF), fontSize: 12),
        ),
      ),
    );
  }
}

/*
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _CampusChip(label: 'JTMK', active: true),
                  _CampusChip(label: 'JKE'),
                  _CampusChip(label: 'Admin'),
                  _CampusChip(label: 'You are here'),
                ],
              ),
            ),
          ),
          Positioned(
            top: 44,
            left: 8,
            right: 8,
            child: Material(
              color: const Color(0xFF091536).withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(18),
              child: Column(
                children: [
                  _DestinationSuggestion(
                    icon: Icons.business_rounded,
                    title: 'JTMK Building',
                    subtitle: 'Academic Block',
                    onTap: widget.onOpenDirectory,
                  ),
                  _DestinationSuggestion(
                    icon: Icons.local_library_rounded,
                    title: 'Main Library',
                    subtitle: 'Campus Center',
                    onTap: widget.onOpenDirectory,
                  ),
                  _DestinationSuggestion(
                    icon: Icons.restaurant_rounded,
                    title: 'Student Cafeteria',
                    subtitle: 'Food Court',
                    onTap: widget.onOpenDirectory,
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF24365F)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF123A62),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current scanned position',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.scannedLocationName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: hasActiveRoute
                          ? const Color(0xFF00E5FF)
                          : const Color(0xFF24365F),
                      width: hasActiveRoute ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: !_mapConnectionChecked
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00E5FF),
                                ),
                              )
                            : !_mapConnectionAvailable
                            ? const _MapFailureCard()
                            : GoogleMap(
                                initialCameraPosition: const CameraPosition(
                                  target: LatLng(2.4156667, 103.8279219),
                                  zoom: 17.5,
                                ),
                                myLocationEnabled: _locationPermissionGranted,
                                myLocationButtonEnabled:
                                    _locationPermissionGranted,
                                gestureRecognizers: _mapGestureRecognizers,
                                markers: markers,
                                polylines: _polylines,
                                mapType: widget.mapType,
                              ),
                      ),
                      if (_locationPermissionDeniedForever)
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF091536),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF24365F),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0F172A,
                                    ).withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Campus location tracking requires GPS to display your position.',
                                      style: TextStyle(
                                        color: Color(0xFFD7E5FF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () async {
                                      await Geolocator.openAppSettings();
                                    },
                                    child: const Text('Open settings'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          child: IconButton(
                            tooltip: 'Open full screen map',
                            icon: const Icon(
                              Icons.fullscreen_rounded,
                              color: Color(0xFF64748B),
                            ),
                            onPressed: () => _openFullscreenMap(markers),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasActiveRoute) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF24365F)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.turn_right_rounded,
                                color: Color(0xFF00E5FF),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Step-by-step directions',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          GestureButton(onTap: widget.onClearRoute),
                        ],
                      ),
                      const Divider(height: 18, color: Color(0xFF24365F)),
                      Text(
                        widget.navigationSteps ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFFD7E5FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          Positioned(
            top: 8,
            left: 8,
            right: 64,
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: const Color(0xFF091536).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: widget.onOpenDirectory,
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Color(0xFF8A9ABC)),
                            SizedBox(width: 10),
                            Text(
                              'Search departments, classrooms...',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Color(0xFF8A9ABC)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: const Color(0xFF00E5FF),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: widget.onOpenAr,
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.navigation_rounded,
                        color: Color(0xFF030A24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF091536).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(999),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.settings_rounded,
                  color: Color(0xFF00E5FF),
                ),
                tooltip: 'App Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(
                        isDarkModeEnabled:
                            Theme.of(context).brightness == Brightness.dark,
                        onThemeChanged: widget.onThemeChanged,
                        mapType: widget.mapType,
                        onMapTypeChanged: widget.onMapTypeChanged,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );*/

class GestureButton extends StatelessWidget {
  final VoidCallback onTap;
  const GestureButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: const Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(Icons.cancel, color: Colors.grey, size: 20),
      ),
    );
  }
}

class _MapFailureCard extends StatelessWidget {
  const _MapFailureCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, color: Color(0xFF64748B), size: 48),
          SizedBox(height: 12),
          Text(
            'Unable to load map tiles. Please check your network connection.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
