// lib/widgets/room_details_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoomDetailsPage extends StatefulWidget {
  final String roomName;
  final String block;
  final String floor;
  final String description;
  final LatLng? coordinates;
  final VoidCallback onPlotRouteTrigger;
  final bool isSaved;
  final VoidCallback? onSave;

  const RoomDetailsPage({
    super.key,
    required this.roomName,
    required this.block,
    required this.floor,
    required this.description,
    this.coordinates,
    required this.onPlotRouteTrigger,
    this.isSaved = false,
    this.onSave,
  });

  @override
  State<RoomDetailsPage> createState() => _RoomDetailsPageState();
}

class _RoomDetailsPageState extends State<RoomDetailsPage> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.roomName)),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF030A24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF091536),
                  border: Border.all(color: const Color(0xFF24365F)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF123A62),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: Color(0xFF00E5FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Block location: ${widget.block}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Floor level: ${widget.floor}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8A9ABC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.coordinates != null) ...[
                const SizedBox(height: 22),
                const Text(
                  'Survey coordinates',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00E5FF),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF091536),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF24365F)),
                  ),
                  child: Text(
                    'Latitude: ${widget.coordinates!.latitude}\n'
                    'Longitude: ${widget.coordinates!.longitude}',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFFD7E5FF),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              const Text(
                'Room description',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00E5FF),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF091536),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF24365F)),
                ),
                child: Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFFD7E5FF),
                  ),
                ),
              ),
              if (widget.onSave != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isSaved
                        ? null
                        : () {
                            widget.onSave!();
                            setState(() => _isSaved = true);
                          },
                    icon: Icon(
                      _isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_add_outlined,
                    ),
                    label: Text(_isSaved ? 'Saved' : 'Save room'),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onPlotRouteTrigger();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text(
                    'Plot route on map',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
