import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/campus_node.dart';
import '../models/qr_location_payload.dart';

class QRScannerTab extends StatefulWidget {
  final Function(String) onScanDetected;
  final ValueChanged<QrRoomPayload>? onRoomDetected;
  final FutureOr<CampusNode?> Function(String scannedCode)?
  onCampusNodeDetected;

  const QRScannerTab({
    super.key,
    required this.onScanDetected,
    this.onRoomDetected,
    this.onCampusNodeDetected,
  });

  @override
  State<QRScannerTab> createState() => _QRScannerTabState();
}

class _QRScannerTabState extends State<QRScannerTab>
    with WidgetsBindingObserver {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasDetectedCode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _scannerController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _scannerController.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) {
    if (_hasDetectedCode) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value == null || value.isEmpty) {
        continue;
      }

      setState(() => _hasDetectedCode = true);
      _scannerController.stop();
      _handleScannedValue(value);
      break;
    }
  }

  Future<void> _handleScannedValue(String value) async {
    final node = await widget.onCampusNodeDetected?.call(value);
    if (!mounted) {
      return;
    }
    if (node != null) {
      await HapticFeedback.selectionClick();
      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(node);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Location Recalibrated! Checked in at: ${node.name} '
            '(Floor ${node.floor ?? 'Unknown'})',
          ),
        ),
      );
      return;
    }

    final roomPayload = parseQrRoomPayload(value);
    if (roomPayload != null) {
      if (widget.onRoomDetected == null) {
        _showInvalidQrMessage();
        return;
      }

      widget.onRoomDetected!(roomPayload);
      return;
    }

    final payload = parseQrLocationPayload(value);
    if (payload == null) {
      _showInvalidQrMessage();
      return;
    }

    final shouldSetStartingLocation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Location Marker Found'),
          content: Text(
            'Current Location set to: ${payload.name} '
            '(${payload.block}, ${payload.floor})',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Set as Starting Location'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (shouldSetStartingLocation == true) {
      widget.onScanDetected(
        '${payload.name} (${payload.block}, ${payload.floor})',
      );
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() => _hasDetectedCode = false);
    await _scannerController.start();
  }

  void _showInvalidQrMessage() {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unrecognized campus QR code.')),
    );
    setState(() => _hasDetectedCode = false);
    _scannerController.start();
  }

  Future<void> _requestCameraPermission() async {
    await _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final scannerSize = math
                .min(
                  math.min(constraints.maxWidth, constraints.maxHeight) * 0.72,
                  320,
                )
                .toDouble();

            return Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  fit: BoxFit.cover,
                  onDetect: _handleDetection,
                  errorBuilder: (context, error) {
                    if (error.errorCode ==
                        MobileScannerErrorCode.permissionDenied) {
                      return _CameraPermissionFallback(
                        onGrantPermission: _requestCameraPermission,
                      );
                    }

                    return ColoredBox(
                      color: const Color(0xFF091536),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            error.errorDetails?.message ??
                                'Camera unavailable. Check camera permissions.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFD7E5FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: scannerSize,
                      height: scannerSize,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(color: Colors.black54, blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(72, 12, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.58),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Scan a PMJ corridor marker',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Find your position',
                              style: TextStyle(
                                color: Color(0xFFD7E5FF),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.58),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Close scanner',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.58),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Position the QR code inside the square',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CameraPermissionFallback extends StatelessWidget {
  final Future<void> Function() onGrantPermission;

  const _CameraPermissionFallback({required this.onGrantPermission});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF091536),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.no_photography_rounded,
            color: Color(0xFF00E5FF),
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Camera access is required to scan PMJMaps markers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD7E5FF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onGrantPermission,
            child: const Text('Grant Camera Permission'),
          ),
        ],
      ),
    );
  }
}

class PMJMapsAboutPage extends StatelessWidget {
  const PMJMapsAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App Information Guide',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff004d40),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Welcome to PMJMaps',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff004d40),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'PMJMaps is a lightweight indoor location-finding system engineered specifically for Politeknik Mersing Johor. It aims to eliminate orientation confusion for new students, external examiners, and guests navigating circular structures.',
            style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          const Text(
            'How to Navigate:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 12),
          _buildStepRow(
            '1',
            'Locate a physical PMJMaps QR code sticker placed along the main corridor pillars or entry walls.',
          ),
          _buildStepRow(
            '2',
            'Open the "Scan Marker" tab inside this application and center the QR graphic inside the camera borders.',
          ),
          _buildStepRow(
            '3',
            'Your immediate position will sync instantly on your layout display blueprint, outlining surrounding classrooms.',
          ),
          const Divider(height: 48),
          const Center(
            child: Text(
              'Project developed by Ahmad Daniel (25DET24F1120)\nDepartment of Electrical Engineering, PMJ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(String stepNumber, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xff004d40),
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
