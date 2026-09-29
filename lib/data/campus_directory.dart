import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'campus_levels.dart';
import '../models/directory_item.dart';

DirectoryItem _surveyedLocation({
  required String room,
  required String tag,
  required double latitude,
  required double longitude,
}) {
  return DirectoryItem(
    room: room,
    block: 'PMJ Campus',
    floor: campusFloorLabel(campusFloorForName(room)) ?? 'Not specified',
    tag: tag,
    desc: 'Coordinates recorded in the PMJ campus survey.',
    coordinates: LatLng(latitude, longitude),
  );
}

const officeRouteCoordinates = <String, LatLng>{
  'jke_office': LatLng(2.415179117, 103.827920567),
  'jtmk_office': LatLng(2.415437217, 103.827640883),
  'jmsk_office': LatLng(2.4152618, 103.8276459),
  'jp_office': LatLng(2.4150647, 103.8277995),
  'hep_office': LatLng(2.4171502, 103.829128233),
};

final campusDirectoryItems = <DirectoryItem>[
  _surveyedLocation(
    room: 'FIBER LAB',
    tag: 'Labs',
    latitude: 2.415129117,
    longitude: 103.8278784,
  ),
  _surveyedLocation(
    room: 'PEJABAT HAL EHWAL PELAJAR (HEP)',
    tag: 'Offices',
    latitude: 2.4171502,
    longitude: 103.829128233,
  ),
  _surveyedLocation(
    room: 'BANGUNAN DELIMA SARI (LODGE)',
    tag: 'Amenities',
    latitude: 2.416701733,
    longitude: 103.828819467,
  ),
  _surveyedLocation(
    room: 'DBIZZ',
    tag: 'Amenities',
    latitude: 2.416102367,
    longitude: 103.829138917,
  ),
  _surveyedLocation(
    room: 'RUMAH SOLAR',
    tag: 'Amenities',
    latitude: 2.415778967,
    longitude: 103.828815833,
  ),
  _surveyedLocation(
    room: 'POWER SYSTEM & CONTROL WORKSHOP',
    tag: 'Labs',
    latitude: 2.415702283,
    longitude: 103.828635383,
  ),
  _surveyedLocation(
    room: 'Parking Motosikal Pelajar',
    tag: 'Amenities',
    latitude: 2.41723795,
    longitude: 103.829289917,
  ),
  _surveyedLocation(
    room: 'PENTADBIRAN (ADMIN)',
    tag: 'Offices',
    latitude: 2.416598033,
    longitude: 103.828367433,
  ),
  _surveyedLocation(
    room: 'POLYSPORT',
    tag: 'Amenities',
    latitude: 2.416765767,
    longitude: 103.827456317,
  ),
  _surveyedLocation(
    room: 'DEWAN PERMATA MARJAN (DPM)',
    tag: 'Lectures',
    latitude: 2.417226083,
    longitude: 103.828283733,
  ),
  _surveyedLocation(
    room: 'WATER RECYCLING PLANTS',
    tag: 'Amenities',
    latitude: 2.416163167,
    longitude: 103.827081467,
  ),
  _surveyedLocation(
    room: 'PADANG PMJ',
    tag: 'Amenities',
    latitude: 2.4165358,
    longitude: 103.826554183,
  ),
  _surveyedLocation(
    room: 'KIOSK',
    tag: 'Amenities',
    latitude: 2.415710483,
    longitude: 103.8270601,
  ),
  _surveyedLocation(
    room: 'LAB FAD 3',
    tag: 'Labs',
    latitude: 2.415820433,
    longitude: 103.827251883,
  ),
  _surveyedLocation(
    room: 'LAB FIT 2',
    tag: 'Labs',
    latitude: 2.415824883,
    longitude: 103.827252217,
  ),
  _surveyedLocation(
    room: 'LAB PEMBANGUNAN APLIKASI 2',
    tag: 'Labs',
    latitude: 2.415980967,
    longitude: 103.827337483,
  ),
  _surveyedLocation(
    room: 'LAB FHY 2',
    tag: 'Labs',
    latitude: 2.415999617,
    longitude: 103.827371783,
  ),
  _surveyedLocation(
    room: 'LAB FIT 1',
    tag: 'Labs',
    latitude: 2.416058267,
    longitude: 103.827383533,
  ),
  _surveyedLocation(
    room: 'LAB FCCN 1',
    tag: 'Labs',
    latitude: 2.416147683,
    longitude: 103.827437617,
  ),
  _surveyedLocation(
    room: 'LAB FHY 1',
    tag: 'Labs',
    latitude: 2.41620075,
    longitude: 103.827465833,
  ),
  _surveyedLocation(
    room: 'LAB CYBER RANGE ACADEMY',
    tag: 'Labs',
    latitude: 2.415631767,
    longitude: 103.827371833,
  ),
  _surveyedLocation(
    room: 'DEWAN MUTIARA UTAMA (DMU)',
    tag: 'Lectures',
    latitude: 2.415794217,
    longitude: 103.827550833,
  ),
  _surveyedLocation(
    room: 'DEWAN MUTIARA 3',
    tag: 'Lectures',
    latitude: 2.41590135,
    longitude: 103.827561183,
  ),
  _surveyedLocation(
    room: 'DEWAN MUTIARA 2',
    tag: 'Lectures',
    latitude: 2.415885183,
    longitude: 103.827669767,
  ),
  _surveyedLocation(
    room: 'DEWAN MUTIARA 1',
    tag: 'Lectures',
    latitude: 2.416019517,
    longitude: 103.827647783,
  ),
  _surveyedLocation(
    room: 'BILIK KULIAH 2 (BK2)',
    tag: 'Lectures',
    latitude: 2.4159758,
    longitude: 103.827682533,
  ),
  _surveyedLocation(
    room: 'LAB FPR',
    tag: 'Labs',
    latitude: 2.416121767,
    longitude: 103.827595283,
  ),
  _surveyedLocation(
    room: 'BILIK KULIAH 1 (BK1)',
    tag: 'Lectures',
    latitude: 2.416048617,
    longitude: 103.827753367,
  ),
  _surveyedLocation(
    room: 'LAB HIBURAN DIGITAL',
    tag: 'Labs',
    latitude: 2.416147717,
    longitude: 103.827770917,
  ),
  _surveyedLocation(
    room: 'TECHNOLOGY ENABLED CLASSROOM 1 (TEC1)',
    tag: 'Lectures',
    latitude: 2.4161381,
    longitude: 103.827845983,
  ),
  _surveyedLocation(
    room: 'UiDM',
    tag: 'Offices',
    latitude: 2.4161256,
    longitude: 103.827905217,
  ),
  _surveyedLocation(
    room: 'PERPUSTAKAAN NILAM SARI',
    tag: 'Amenities',
    latitude: 2.415866717,
    longitude: 103.828010683,
  ),
  _surveyedLocation(
    room: 'JABATAN TEKNOLOGI MAKLUMAT DAN KOMUNIKASI (JTMK)',
    tag: 'Offices',
    latitude: 2.415437217,
    longitude: 103.827640883,
  ),
  _surveyedLocation(
    room: 'BILIK KULIAH 17 (BK17)',
    tag: 'Lectures',
    latitude: 2.415178517,
    longitude: 103.827879267,
  ),
  _surveyedLocation(
    room: 'JABATAN KEJURUTERAAN ELEKTRIK (JKE)',
    tag: 'Offices',
    latitude: 2.415179117,
    longitude: 103.827920567,
  ),
  _surveyedLocation(
    room: 'LAB JURUTEKNIK SAINS',
    tag: 'Labs',
    latitude: 2.41516355,
    longitude: 103.827920083,
  ),
  _surveyedLocation(
    room: 'TANDAS PELAJAR LELAKI (BLOCK JKE)',
    tag: 'Amenities',
    latitude: 2.41527305,
    longitude: 103.8281652,
  ),
  _surveyedLocation(
    room: 'LAB SISTEM ELEKTRONIK',
    tag: 'Labs',
    latitude: 2.415307383,
    longitude: 103.828194733,
  ),
  _surveyedLocation(
    room: 'TANDAS PELAJAR PEREMPUAN (BLOCK JKE)',
    tag: 'Amenities',
    latitude: 2.415596383,
    longitude: 103.828356617,
  ),
  _surveyedLocation(
    room: 'LAB MEMBAIKI ELEKTRONIK',
    tag: 'Labs',
    latitude: 2.4156234,
    longitude: 103.8283622,
  ),
  _surveyedLocation(
    room: 'TECHNOLOGY ENABLED COLLABORATIVE CLASSROOM (TECC)',
    tag: 'Lectures',
    latitude: 2.415766633,
    longitude: 103.828254167,
  ),
  _surveyedLocation(
    room: 'BILIK KULIAH 24 (BK24)',
    tag: 'Lectures',
    latitude: 2.415815933,
    longitude: 103.828292283,
  ),
  _surveyedLocation(
    room: 'LAB KUASA ELEKTRONIK',
    tag: 'Labs',
    latitude: 2.415847933,
    longitude: 103.828358,
  ),
];
