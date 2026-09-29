import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_info.dart';
import 'firebase_options.dart';

// Import your newly segregated modules cleanly
import 'data/campus_directory.dart';
import 'models/campus_node.dart';
import 'models/directory_item.dart';
import 'services/vertical_navigation_service.dart';
import 'tabs/qr_scanner_tab.dart';
import 'tabs/directory_search_tab.dart';
import 'tabs/floor_plan_display_tab.dart';
import 'tabs/ar_navigation_tab.dart';
import 'screens/splash_screen.dart';
import 'widgets/room_details_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PMJMapsApp());
}

class PMJMapsApp extends StatefulWidget {
  const PMJMapsApp({super.key});

  @override
  State<PMJMapsApp> createState() => _PMJMapsAppState();
}

class _PMJMapsAppState extends State<PMJMapsApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PMJMaps',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        primaryColor: const Color(0xFF0D9488),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
          secondary: const Color(0xFF14B8A6),
          tertiary: const Color(0xFFB7F3E7),
          surface: const Color(0xFFF8FAFC),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Color(0xFFF8FAFC),
          foregroundColor: Color(0xFF0F172A),
          iconTheme: IconThemeData(color: Color(0xFF0F172A)),
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Color(0xFFF8FAFC),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D9488),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF14B8A6), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE2E8F0),
          thickness: 1,
          space: 1,
        ),
        listTileTheme: const ListTileThemeData(
          tileColor: Color(0xFFF8FAFC),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFFF8FAFC),
          surfaceTintColor: const Color(0xFFF8FAFC),
          shadowColor: Colors.transparent,
          elevation: 0,
          indicatorColor: const Color(0xFF0D9488),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? Colors.white
                  : const Color(0xFF64748B),
              size: 20,
            ),
          ),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF030A24),
        primaryColor: const Color(0xFF00E5FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
          primary: const Color(0xFF00E5FF),
          secondary: const Color(0xFF4DA3FF),
          surface: const Color(0xFF091536),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF030A24),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF091536),
          hintStyle: TextStyle(color: Color(0xFF8A9ABC)),
          prefixIconColor: Color(0xFF8A9ABC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFF24365F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFF24365F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFF00E5FF)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF07102D),
          indicatorColor: const Color(0xFF164B71),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: SplashScreen(
        destination: MainNavigationHub(
          isDarkModeEnabled: _themeMode == ThemeMode.dark,
          onThemeChanged: (isDark) {
            setState(() {
              _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
            });
          },
        ),
      ),
    );
  }
}

class MainNavigationHub extends StatefulWidget {
  final bool isDarkModeEnabled;
  final ValueChanged<bool> onThemeChanged;

  const MainNavigationHub({
    super.key,
    required this.isDarkModeEnabled,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  static final Uri _bugReportUri = Uri.parse(
    'https://forms.gle/fNims48hNgXkopzt8',
  );
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  String _currentScannedLocation = "JKE Block A - Ground Floor Main Corridor";
  String? _activeRoutingTarget;
  String? _activeRoutingDestinationName;
  String? _activeRoutingDirections;
  String? _activeRoutingRouteId;
  LatLng? _activeRoutingDestination;
  MapType _mapType = MapType.normal;
  NavigationLocationState? _navigationLocationState;
  final Map<String, DirectoryItem> _savedLocations = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showBetaNotice();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showBetaNotice() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.science_outlined, color: Color(0xFF00D9E9)),
        title: const Text('Beta version'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This is a beta version of the app, if you found any bugs '
                'report it here!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Image.asset(
                'assets/icon/bug_report_qr.png',
                width: 210,
                height: 210,
                fit: BoxFit.contain,
                semanticLabel: 'QR code for reporting app bugs',
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await _openBugReportForm();
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open bug report form'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _openBugReportForm() async {
    try {
      final launched = await launchUrl(
        _bugReportUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the bug report form.')),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the bug report form: $error')),
        );
      }
    }
  }

  void _goToPage(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }

    setState(() {
      _currentIndex = index;
    });
  }

  String _routeIdForRoom(String roomName) {
    final normalized = roomName.toLowerCase();
    if (normalized.startsWith('jke ')) {
      return 'jke_office';
    }
    if (normalized.startsWith('jtmk ')) {
      return 'jtmk_office';
    }
    if (normalized.startsWith('jmsk ')) {
      return 'jmsk_office';
    }
    if (normalized.startsWith('jp ')) {
      return 'jp_office';
    }
    if (normalized.startsWith('hep ')) {
      return 'hep_office';
    }
    return '';
  }

  bool _isLocationSaved(DirectoryItem item) =>
      _savedLocations.containsKey(item.markerId);

  void _saveLocation(DirectoryItem item) {
    setState(() => _savedLocations[item.markerId] = item);
  }

  void _removeSavedLocation(DirectoryItem item) {
    setState(() => _savedLocations.remove(item.markerId));
  }

  void _routeToItem(DirectoryItem item) {
    setState(() {
      _activeRoutingTarget = '${item.room} (${item.block}, ${item.floor})';
      _activeRoutingDestinationName = item.room;
      _activeRoutingDirections = null;
      _activeRoutingRouteId = _routeIdForRoom(item.room);
      _activeRoutingDestination = item.coordinates;
    });
    _goToPage(0);
  }

  void _openDirectory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DirectorySearchTab(
          onRouteSelected: (item) {
            _routeToItem(item);
            Navigator.of(context).pop();
          },
          isSaved: _isLocationSaved,
          onSave: _saveLocation,
        ),
      ),
    );
  }

  Future<void> _openAr() async {
    final routeId = _activeRoutingRouteId;
    final destination =
        _activeRoutingDestination ??
        (routeId == null ? null : officeRouteCoordinates[routeId]);
    final destinationName = _activeRoutingDestinationName ?? 'JTMK Department';
    CampusNode? destinationNode;

    try {
      destinationNode = await VerticalNavigationService.findNodeByName(
        destinationName,
      );
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load campus node data: $error')),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArNavigationTab(
          destinationLat: destination?.latitude ?? 2.4156667,
          destinationLng: destination?.longitude ?? 103.8279219,
          destinationName: destinationName,
          destinationNode: destinationNode,
          userLat: _navigationLocationState?.userLat,
          userLng: _navigationLocationState?.userLng,
          userFloor: _navigationLocationState?.isRecalibrated == true
              ? _navigationLocationState?.userFloor
              : VerticalNavigationService.floorFromLabel(
                  _currentScannedLocation,
                ),
          userElevation: _navigationLocationState?.userElevation,
          isRecalibrated: _navigationLocationState?.isRecalibrated ?? false,
          onOpenScanner: _openScanner,
        ),
      ),
    );
  }

  bool recalibrateFromQR(String scannedCode) {
    final locationState = _navigationLocationState;
    if (locationState == null ||
        !locationState.recalibrateFromQR(scannedCode)) {
      return false;
    }

    final node = locationState.recalibratedNode!;
    setState(() {
      _currentScannedLocation = '${node.name} (${node.floorLabel})';
    });
    return true;
  }

  Future<CampusNode?> _openScanner() async {
    try {
      final nodes = await VerticalNavigationService.loadNodes();
      _navigationLocationState ??= NavigationLocationState(nodes);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load campus node data: $error')),
        );
      }
      return null;
    }

    if (!mounted) {
      return null;
    }

    return Navigator.of(context).push<CampusNode>(
      MaterialPageRoute<CampusNode>(
        builder: (_) => QRScannerTab(
          onScanDetected: (newLocation) {
            setState(() {
              _currentScannedLocation = newLocation;
            });
            Navigator.of(context).pop();
          },
          onCampusNodeDetected: (scannedCode) {
            if (!recalibrateFromQR(scannedCode)) {
              return null;
            }
            return _navigationLocationState?.recalibratedNode;
          },
          onRoomDetected: (room) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RoomDetailsPage(
                  roomName: room.room,
                  block: room.block,
                  floor: room.floor,
                  description: room.description,
                  coordinates:
                      officeRouteCoordinates[_routeIdForRoom(room.room)],
                  onPlotRouteTrigger: () {
                    setState(() {
                      _activeRoutingTarget =
                          '${room.room} (${room.block}, ${room.floor})';
                      _activeRoutingDestinationName = room.room;
                      _activeRoutingDirections = room.route;
                      _activeRoutingRouteId = _routeIdForRoom(room.room);
                      _activeRoutingDestination = null;
                    });
                    _goToPage(0);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final shellPadding = screenWidth < 360
        ? 8.0
        : screenWidth >= 600
        ? 24.0
        : 16.0;
    final List<Widget> pages = [
      FloorPlanDisplayTab(
        scannedLocationName: _currentScannedLocation,
        routingTarget: _activeRoutingTarget,
        routingRouteId: _activeRoutingRouteId,
        routingDestination: _activeRoutingDestination,
        navigationSteps: _activeRoutingDirections,
        onClearRoute: () {
          setState(() {
            _activeRoutingTarget = null;
            _activeRoutingDestinationName = null;
            _activeRoutingDirections = null;
            _activeRoutingRouteId = null;
            _activeRoutingDestination = null;
          });
        },
        onOpenDirectory: _openDirectory,
        onOpenAr: _openAr,
        onThemeChanged: widget.onThemeChanged,
        mapType: _mapType,
        onMapTypeChanged: (mapType) {
          setState(() => _mapType = mapType);
        },
      ),
      DirectorySearchTab(
        onRouteSelected: _routeToItem,
        isSaved: _isLocationSaved,
        onSave: _saveLocation,
      ),
      _SavedLocationsTab(
        savedLocations: _savedLocations.values.toList(growable: false),
        onRouteSelected: (item) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => RoomDetailsPage(
                roomName: item.room,
                block: item.block,
                floor: item.floor,
                description: item.desc,
                coordinates: item.coordinates,
                isSaved: true,
                onPlotRouteTrigger: () => _routeToItem(item),
              ),
            ),
          );
        },
        onRemoveSaved: _removeSavedLocation,
      ),
      _ProfileTab(
        mapType: _mapType,
        onMapTypeChanged: (mapType) {
          setState(() => _mapType = mapType);
        },
      ),
    ];

    Widget navigationItem({
      required int index,
      required IconData icon,
      required String label,
    }) {
      final selected = _currentIndex == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => _goToPage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF164B71) : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? Colors.white : const Color(0xFF8A9ABC),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF8A9ABC),
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              children: pages,
            ),
          ),
          Positioned(
            left: shellPadding,
            right: shellPadding,
            bottom: 10,
            child: SafeArea(
              top: false,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF07102D,
                          ).withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF24365F)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF0F172A,
                              ).withValues(alpha: 0.1),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            navigationItem(
                              index: 0,
                              icon: Icons.map_rounded,
                              label: 'Map',
                            ),
                            navigationItem(
                              index: 1,
                              icon: Icons.alt_route_rounded,
                              label: 'Routes',
                            ),
                            const SizedBox(width: 64),
                            navigationItem(
                              index: 2,
                              icon: Icons.bookmark_rounded,
                              label: 'Saved',
                            ),
                            navigationItem(
                              index: 3,
                              icon: Icons.person_rounded,
                              label: 'Profile',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        width: 58,
                        height: 58,
                        child: Material(
                          color: const Color(0xFF00D9E9),
                          shape: const CircleBorder(),
                          elevation: 8,
                          shadowColor: const Color(0xAA00D9E9),
                          child: InkWell(
                            onTap: _openScanner,
                            customBorder: const CircleBorder(),
                            child: const Center(
                              child: Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Color(0xFF03122D),
                                size: 27,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedLocationsTab extends StatefulWidget {
  final List<DirectoryItem> savedLocations;
  final ValueChanged<DirectoryItem> onRouteSelected;
  final ValueChanged<DirectoryItem> onRemoveSaved;

  const _SavedLocationsTab({
    required this.savedLocations,
    required this.onRouteSelected,
    required this.onRemoveSaved,
  });

  @override
  State<_SavedLocationsTab> createState() => _SavedLocationsTabState();
}

class _SavedLocationsTabState extends State<_SavedLocationsTab> {
  Future<void> _confirmRemoval(DirectoryItem item) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove saved place?'),
        content: Text('Remove ${item.room} from your saved places?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (shouldRemove == true) {
      widget.onRemoveSaved(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
        children: [
          const Text(
            'Saved locations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your bookmarked campus destinations',
            style: TextStyle(color: Color(0xFF9CAED5), fontSize: 13),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xCC0B1738),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x665C78B4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.bookmark_rounded, color: Color(0xFF00E5FF)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Quick access to places you visit often.',
                    style: TextStyle(color: Color(0xFFD4E2FF), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'BOOKMARKED PLACES',
            style: TextStyle(
              color: Color(0xFF9CAED5),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          if (widget.savedLocations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    color: Color(0xFF64748B),
                    size: 42,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Rooms you save will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFB9C6E8)),
                  ),
                ],
              ),
            ),
          ...widget.savedLocations.map(
            (location) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: const Color(0xCC0B1738),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => widget.onRouteSelected(location),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF123A62),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.meeting_room_rounded,
                            color: const Color(0xFF00E5FF),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location.room,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                '${location.block} · ${location.floor}',
                                style: const TextStyle(
                                  color: Color(0xFFB9C6E8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove saved location',
                          onPressed: () => _confirmRemoval(location),
                          icon: const Icon(
                            Icons.bookmark_rounded,
                            color: Color(0xFF00E5FF),
                            size: 21,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatefulWidget {
  final MapType mapType;
  final ValueChanged<MapType> onMapTypeChanged;

  const _ProfileTab({required this.mapType, required this.onMapTypeChanged});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab>
    with AutomaticKeepAliveClientMixin<_ProfileTab> {
  static const _profileStorageKey = 'pmjmaps_profile_v1';

  String _displayName = 'PMJ Maps visitor';
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _courseController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  Map<String, String> _savedBiodata = {};
  Uint8List? _profileImageBytes;
  String? _profileImageData;
  bool _isEditing = false;
  bool _isLoadingProfile = true;
  bool _isSavingProfile = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _nameController.text = _displayName;
    _recoverProfileImage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedProfile = preferences.getString(_profileStorageKey);
      if (savedProfile != null) {
        final decodedProfile = jsonDecode(savedProfile);
        if (decodedProfile is! Map<String, dynamic>) {
          throw const FormatException('Profile data must be a JSON object.');
        }

        final name = decodedProfile['displayName'];
        final biodata = decodedProfile['biodata'];
        final imageData = decodedProfile['profileImage'];
        final loadedBiodata = <String, String>{};
        if (biodata is Map) {
          for (final entry in biodata.entries) {
            if (entry.key is String && entry.value is String) {
              loadedBiodata[entry.key as String] = entry.value as String;
            }
          }
        }

        Uint8List? imageBytes;
        var hasInvalidImage = false;
        if (imageData is String && imageData.isNotEmpty) {
          try {
            imageBytes = base64Decode(imageData);
          } on FormatException {
            hasInvalidImage = true;
          }
        }

        if (mounted) {
          setState(() {
            if (name is String && name.trim().isNotEmpty) {
              _displayName = name.trim();
            }
            _nameController.text = _displayName;
            _savedBiodata = loadedBiodata;
            _studentIdController.text =
                loadedBiodata['Student / staff ID'] ?? '';
            _emailController.text = loadedBiodata['Email'] ?? '';
            _phoneController.text = loadedBiodata['Phone'] ?? '';
            _courseController.text = loadedBiodata['Course / department'] ?? '';
            _profileImageData = imageBytes == null ? null : imageData as String;
            _profileImageBytes = imageBytes;
          });
        }

        if (hasInvalidImage) {
          _showProfileMessage('The saved profile picture could not be loaded.');
        }
      }
    } on FormatException {
      _showProfileMessage('Saved profile information could not be read.');
    } on PlatformException catch (error) {
      _showProfileMessage(
        'Could not load your profile: ${error.message ?? error.code}',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _recoverProfileImage() async {
    await _loadProfile();
    if (!mounted) {
      return;
    }

    try {
      final cropper = ImageCropper();
      final recoveredCrop = await cropper.recoverImage();
      if (recoveredCrop != null) {
        await _saveCroppedProfileImage(recoveredCrop);
        return;
      }

      if (defaultTargetPlatform != TargetPlatform.android) {
        return;
      }

      final lostData = await _imagePicker.retrieveLostData();
      if (lostData.exception case final exception?) {
        throw exception;
      }
      final lostImage = lostData.file;
      if (lostImage != null && mounted) {
        await _cropAndSaveProfileImage(lostImage.path);
      }
    } on PlatformException catch (error) {
      if (mounted) {
        _setProfileImageSaveState(false);
        _showProfileMessage(
          'Could not recover your profile picture: '
          '${error.message ?? error.code}',
        );
      }
    } on Object catch (error) {
      if (mounted) {
        _setProfileImageSaveState(false);
        _showProfileMessage('Could not recover your profile picture: $error');
      }
    }
  }

  Map<String, String> _currentBiodata() => {
    'Student / staff ID': _studentIdController.text.trim(),
    'Email': _emailController.text.trim(),
    'Phone': _phoneController.text.trim(),
    'Course / department': _courseController.text.trim(),
  };

  void _startEditing() {
    setState(() {
      _nameController.text = _displayName;
      _studentIdController.text = _savedBiodata['Student / staff ID'] ?? '';
      _emailController.text = _savedBiodata['Email'] ?? '';
      _phoneController.text = _savedBiodata['Phone'] ?? '';
      _courseController.text = _savedBiodata['Course / department'] ?? '';
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    FocusScope.of(context).unfocus();
    setState(() => _isEditing = false);
  }

  Future<bool> _persistProfile({
    required String displayName,
    required Map<String, String> biodata,
    String? profileImageData,
  }) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final wasSaved = await preferences.setString(
        _profileStorageKey,
        jsonEncode({
          'displayName': displayName,
          'biodata': biodata,
          'profileImage': profileImageData ?? _profileImageData,
        }),
      );
      if (!wasSaved) {
        _showProfileMessage(
          'Your profile could not be saved. Please try again.',
        );
      }
      return wasSaved;
    } on PlatformException catch (error) {
      _showProfileMessage(
        'Could not save your profile: ${error.message ?? error.code}',
      );
      return false;
    }
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    final displayName = _nameController.text.trim();
    if (displayName.isEmpty) {
      _showProfileMessage('Please enter your name before saving.');
      return;
    }

    setState(() => _isSavingProfile = true);
    final biodata = _currentBiodata();
    final wasSaved = await _persistProfile(
      displayName: displayName,
      biodata: biodata,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _isSavingProfile = false;
      if (wasSaved) {
        _displayName = displayName;
        _savedBiodata = biodata;
        _isEditing = false;
      }
    });
    if (wasSaved) {
      _showProfileMessage('Profile information saved.');
    }
  }

  Future<void> _chooseProfilePicture() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 90,
      );
      if (image == null || !mounted) {
        return;
      }

      await _cropAndSaveProfileImage(image.path);
    } on PlatformException catch (error) {
      if (mounted) {
        _setProfileImageSaveState(false);
        _showProfileMessage(
          'Could not update your profile picture: '
          '${error.message ?? error.code}',
        );
      }
    } on Object catch (error) {
      if (mounted) {
        _setProfileImageSaveState(false);
        _showProfileMessage('Could not update your profile picture: $error');
      }
    }
  }

  Future<void> _cropAndSaveProfileImage(String sourcePath) async {
    final cropper = ImageCropper();
    final croppedImage = await cropper.cropImage(
      sourcePath: sourcePath,
      maxWidth: 512,
      maxHeight: 512,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop profile picture',
          toolbarColor: const Color(0xFF07102D),
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop profile picture',
          aspectRatioLockEnabled: true,
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(width: 512, height: 512),
        ),
      ],
    );
    await cropper.recoverImage();
    if (croppedImage == null || !mounted) {
      return;
    }

    await _saveCroppedProfileImage(croppedImage);
  }

  Future<void> _saveCroppedProfileImage(CroppedFile croppedImage) async {
    if (!mounted) {
      return;
    }

    final imageBytes = await croppedImage.readAsBytes();
    final imageData = base64Encode(imageBytes);
    setState(() => _isSavingProfile = true);
    final wasSaved = await _persistProfile(
      displayName: _displayName,
      biodata: _savedBiodata,
      profileImageData: imageData,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _isSavingProfile = false;
      if (wasSaved) {
        _profileImageData = imageData;
        _profileImageBytes = imageBytes;
      }
    });
    if (wasSaved) {
      _showProfileMessage('Profile picture updated.');
    }
  }

  void _setProfileImageSaveState(bool isSaving) {
    if (mounted) {
      setState(() => _isSavingProfile = isSaving);
    }
  }

  void _showProfileMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final savedBiodata = _savedBiodata.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList(growable: false);
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your PMJ Maps experience',
            style: TextStyle(color: Color(0xFF9CAED5), fontSize: 13),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xCC0B1738),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0x665C78B4)),
            ),
            child: Row(
              children: [
                Tooltip(
                  message: 'Change profile picture',
                  child: Material(
                    color: const Color(0xFF123A62),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _isLoadingProfile || _isSavingProfile
                          ? null
                          : _chooseProfilePicture,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF123A62),
                              backgroundImage: _profileImageBytes == null
                                  ? null
                                  : MemoryImage(_profileImageBytes!),
                              child: _profileImageBytes == null
                                  ? const Icon(
                                      Icons.person_rounded,
                                      color: Color(0xFF00E5FF),
                                      size: 30,
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00D9E9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF0B1738),
                                    width: 2,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.photo_camera_rounded,
                                    color: Color(0xFF03122D),
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _isEditing
                                ? TextField(
                                    controller: _nameController,
                                    autofocus: true,
                                    enabled: !_isSavingProfile,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                      isDense: true,
                                    ),
                                    textInputAction: TextInputAction.next,
                                  )
                                : Text(
                                    _isLoadingProfile
                                        ? 'Loading profile...'
                                        : _displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                          IconButton(
                            tooltip: _isEditing
                                ? 'Cancel profile edits'
                                : 'Edit profile',
                            onPressed: _isLoadingProfile || _isSavingProfile
                                ? null
                                : _isEditing
                                ? _cancelEditing
                                : _startEditing,
                            icon: Icon(
                              _isEditing
                                  ? Icons.close_rounded
                                  : Icons.edit_outlined,
                              color: const Color(0xFF00E5FF),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Politeknik Mersing Johor',
                        style: TextStyle(
                          color: Color(0xFFB9C6E8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xCC0B1738),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0x665C78B4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal biodata',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isEditing
                      ? 'Edit your name and details, then save your profile.'
                      : 'Your saved profile details.',
                  style: const TextStyle(
                    color: Color(0xFF9CAED5),
                    fontSize: 12,
                  ),
                ),
                if (_isLoadingProfile) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ] else if (_isEditing) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: _studentIdController,
                    enabled: !_isSavingProfile,
                    decoration: const InputDecoration(
                      labelText: 'Student / staff ID',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    enabled: !_isSavingProfile,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneController,
                    enabled: !_isSavingProfile,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _courseController,
                    enabled: !_isSavingProfile,
                    decoration: const InputDecoration(
                      labelText: 'Course / department',
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _isSavingProfile ? null : _cancelEditing,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isSavingProfile ? null : _saveProfile,
                          icon: _isSavingProfile
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _isSavingProfile ? 'Saving...' : 'Save profile',
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (savedBiodata.isEmpty) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'No personal details added yet. Tap the pencil to edit your profile.',
                    style: TextStyle(color: Color(0xFFB9C6E8), fontSize: 12),
                  ),
                ] else ...[
                  const SizedBox(height: 14),
                  ...savedBiodata.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(
                          color: Color(0xFFB9C6E8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xCC0B1738),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0x665C78B4)),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 3,
                  ),
                  leading: const Icon(
                    Icons.layers_outlined,
                    color: Color(0xFF00E5FF),
                  ),
                  title: const Text(
                    'Map layer',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    widget.mapType == MapType.satellite
                        ? 'Satellite'
                        : 'Normal',
                    style: const TextStyle(
                      color: Color(0xFF9CAED5),
                      fontSize: 12,
                    ),
                  ),
                  trailing: DropdownButton<MapType>(
                    value: widget.mapType,
                    dropdownColor: const Color(0xFF091536),
                    underline: const SizedBox.shrink(),
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(
                        value: MapType.normal,
                        child: Text('Normal'),
                      ),
                      DropdownMenuItem(
                        value: MapType.satellite,
                        child: Text('Satellite'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        widget.onMapTypeChanged(value);
                      }
                    },
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 3,
                  ),
                  leading: const Icon(
                    Icons.cleaning_services_outlined,
                    color: Color(0xFF00E5FF),
                  ),
                  title: const Text(
                    'Clear cache',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Clear cached map and image data',
                    style: TextStyle(color: Color(0xFF9CAED5), fontSize: 12),
                  ),
                  onTap: () {
                    PaintingBinding.instance.imageCache.clear();
                    PaintingBinding.instance.imageCache.clearLiveImages();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image cache cleared.')),
                    );
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 3,
                  ),
                  leading: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF00E5FF),
                  ),
                  title: const Text(
                    'About PMJ Maps',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Version and project information',
                    style: TextStyle(color: Color(0xFF9CAED5), fontSize: 12),
                  ),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'PMJMaps',
                    applicationVersion: appVersion,
                    applicationLegalese:
                        'Indoor wayfinding for Politeknik Mersing Johor.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
