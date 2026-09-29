class QrLocationPayload {
  final String nodeId;
  final String name;
  final String block;
  final String floor;

  const QrLocationPayload({
    required this.nodeId,
    required this.name,
    required this.block,
    required this.floor,
  });
}

class QrRoomPayload {
  final String room;
  final String block;
  final String floor;
  final String description;
  final String route;

  const QrRoomPayload({
    required this.room,
    required this.block,
    required this.floor,
    required this.description,
    required this.route,
  });
}

QrLocationPayload? parseQrLocationPayload(String value) {
  const locationPrefix = 'pmjmaps://location?';
  if (!value.startsWith(locationPrefix)) {
    return null;
  }

  final uri = Uri.tryParse(value);
  final nodeId = uri?.queryParameters['node_id'];
  final name = uri?.queryParameters['name'];
  final block = uri?.queryParameters['block'];
  final floor = uri?.queryParameters['floor'];

  if (uri == null ||
      nodeId == null ||
      nodeId.isEmpty ||
      name == null ||
      name.isEmpty ||
      block == null ||
      block.isEmpty ||
      floor == null ||
      floor.isEmpty) {
    return null;
  }

  return QrLocationPayload(
    nodeId: nodeId,
    name: name,
    block: block,
    floor: floor,
  );
}

QrRoomPayload? parseQrRoomPayload(String value) {
  const roomPrefix = 'pmjmaps://room?';
  if (!value.startsWith(roomPrefix)) {
    return null;
  }

  final uri = Uri.tryParse(value);
  final room = uri?.queryParameters['room'];
  final block = uri?.queryParameters['block'];
  final floor = uri?.queryParameters['floor'];
  final description = uri?.queryParameters['description'];
  final route = uri?.queryParameters['route'];

  if (uri == null ||
      room == null ||
      room.isEmpty ||
      block == null ||
      block.isEmpty ||
      floor == null ||
      floor.isEmpty ||
      description == null ||
      description.isEmpty ||
      route == null ||
      route.isEmpty) {
    return null;
  }

  return QrRoomPayload(
    room: room,
    block: block,
    floor: floor,
    description: description,
    route: route,
  );
}
