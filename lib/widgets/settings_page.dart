import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../app_info.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkModeEnabled;
  final ValueChanged<bool> onThemeChanged;
  final MapType mapType;
  final ValueChanged<MapType> onMapTypeChanged;

  const SettingsPage({
    super.key,
    required this.isDarkModeEnabled,
    required this.onThemeChanged,
    required this.mapType,
    required this.onMapTypeChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDarkModeEnabled;
  late MapType _mapType;

  @override
  void initState() {
    super.initState();
    _isDarkModeEnabled = widget.isDarkModeEnabled;
    _mapType = widget.mapType;
  }

  void _clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Image cache cleared.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const _SectionLabel('APPEARANCE'),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
            shape: const Border(bottom: BorderSide(color: Color(0xFF24365F))),
            secondary: const Icon(
              Icons.dark_mode_outlined,
              color: Color(0xFF00E5FF),
              size: 20,
            ),
            title: const Text('App Theme'),
            subtitle: const Text('Use a light or dark appearance'),
            value: _isDarkModeEnabled,
            onChanged: (value) {
              setState(() => _isDarkModeEnabled = value);
              widget.onThemeChanged(value);
            },
          ),
          const _SectionLabel('MAP'),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
            shape: const Border(bottom: BorderSide(color: Color(0xFF24365F))),
            leading: const Icon(
              Icons.layers_outlined,
              color: Color(0xFF00E5FF),
              size: 20,
            ),
            title: const Text('Map Layer'),
            subtitle: Text(
              _mapType == MapType.satellite ? 'Satellite' : 'Normal',
            ),
            trailing: DropdownButton<MapType>(
              value: _mapType,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: MapType.normal, child: Text('Normal')),
                DropdownMenuItem(
                  value: MapType.satellite,
                  child: Text('Satellite'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _mapType = value);
                widget.onMapTypeChanged(value);
              },
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
            shape: const Border(bottom: BorderSide(color: Color(0xFF24365F))),
            leading: const Icon(
              Icons.cleaning_services_outlined,
              color: Color(0xFF00E5FF),
              size: 20,
            ),
            title: const Text('Clear Cache'),
            subtitle: const Text('Clear cached images used by the app'),
            trailing: FilledButton(
              onPressed: _clearCache,
              child: const Text('Clear'),
            ),
          ),
          const _SectionLabel('ABOUT'),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
            leading: const Icon(
              Icons.info_outline,
              color: Color(0xFF00E5FF),
              size: 20,
            ),
            title: const Text('About PMJMaps'),
            subtitle: const Text('Version and project information'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF00E5FF),
              size: 20,
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF00E5FF),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
