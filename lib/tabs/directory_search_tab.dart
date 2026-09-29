import 'package:flutter/material.dart';
import '../data/campus_directory.dart';
import '../models/directory_item.dart';
import '../widgets/room_details_page.dart';

class DirectorySearchTab extends StatefulWidget {
  final ValueChanged<DirectoryItem> onRouteSelected;
  final bool Function(DirectoryItem) isSaved;
  final ValueChanged<DirectoryItem> onSave;

  const DirectorySearchTab({
    super.key,
    required this.onRouteSelected,
    required this.isSaved,
    required this.onSave,
  });

  @override
  State<DirectorySearchTab> createState() => _DirectorySearchTabState();
}

class _DirectorySearchTabState extends State<DirectorySearchTab> {
  final List<String> _categories = [
    'All',
    'Labs',
    'Offices',
    'Lectures',
    'Amenities',
  ];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _locationsScrollController = ScrollController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    _locationsScrollController.dispose();
    super.dispose();
  }

  void _selectCategory(String category) {
    setState(() => _selectedCategory = category);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_locationsScrollController.hasClients) {
        _locationsScrollController.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = campusDirectoryItems.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.tag == _selectedCategory;
      final matchesSearchText =
          item.room.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.block.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearchText;
    }).toList();

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Find your destination',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 6, 20, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Search campus rooms, labs, and facilities',
                  style: TextStyle(color: Color(0xFF9CAED5), fontSize: 13),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search classrooms, labs, or departments...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF8A9ABC),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Color(0xFF475569),
                            size: 20,
                          ),
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _searchQuery = "";
                          }),
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xCC0B1738),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0x665C78B4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0x665C78B4)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      label: Text(category),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF03122D)
                            : const Color(0xFFB9C6E8),
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: const Color(0xCC0B1738),
                      selectedColor: const Color(0xFF00D9E9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF00D9E9)
                            : const Color(0x665C78B4),
                        width: 1,
                      ),
                      onSelected: (selected) => _selectCategory(category),
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Campus locations',
                  style: TextStyle(
                    color: Color(0xFF9CAED5),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              color: Color(0xFF64748B),
                              size: 48,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No matching department or room found.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _locationsScrollController,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: const Color(0xCC0B1738),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RoomDetailsPage(
                                      roomName: item.room,
                                      block: item.block,
                                      floor: item.floor,
                                      description: item.desc,
                                      coordinates: item.coordinates,
                                      isSaved: widget.isSaved(item),
                                      onSave: () => widget.onSave(item),
                                      onPlotRouteTrigger: () {
                                        widget.onRouteSelected(item);
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF123A62),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Icon(
                                        Icons.meeting_room_rounded,
                                        color: Color(0xFF00E5FF),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.room,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 7),
                                          Text(
                                            '${item.block} · ${item.floor}',
                                            style: const TextStyle(
                                              color: Color(0xFFB9C6E8),
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            item.tag.toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFF00E5FF),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 17,
                                      color: Color(0xFF8A9ABC),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
