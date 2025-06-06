import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'routeoverview_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return _currentPosition == null
  //       ? Center(child: CircularProgressIndicator())
  //       : FlutterMap(
  //           options: MapOptions(
  //             center: _currentPosition,
  //             zoom: 15.0,
  //           ),
  //           children: [
  //             TileLayer(
  //               urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  //               userAgentPackageName: 'com.example.flutter_application_1',
  //             ),
  //             MarkerLayer(
  //               markers: [
  //                 Marker(
  //                   point: _currentPosition!,
  //                   width: 40,
  //                   height: 40,
  //                   child: Icon(Icons.my_location, color: Colors.blue, size: 40),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         );
  // }


  @override
  Widget build(BuildContext context) {
    return RoutesOverviewPage(); // gewoon direct jouw grid tonen!
  }


}

