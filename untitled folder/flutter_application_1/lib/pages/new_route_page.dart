import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';

class NewRoutePage extends StatefulWidget {
  final DocumentSnapshot? existingRoute;

  NewRoutePage({this.existingRoute});

  @override
  State<NewRoutePage> createState() => _NewRoutePageState();
}

class _NewRoutePageState extends State<NewRoutePage> {
  List<LatLng> tappedPoints = [];
  List<LatLng> undonePoints = [];
  double distance = 0.0;
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingRoute != null) {
      final data = widget.existingRoute!.data() as Map<String, dynamic>;
      nameController.text = data['name'] ?? '';
      tappedPoints = (data['points'] as List)
          .map((p) => LatLng(p['lat'], p['lng']))
          .toList();
      calculateDistance();
    }
  }

  void saveRoute() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Geef een naam aan je route!')),
      );
      return;
    }

    if (tappedPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Geen punten geselecteerd!')),
      );
      return;
    }

    final routeData = {
      'name': nameController.text.trim(),
      'points': tappedPoints
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
      'created_at': FieldValue.serverTimestamp(),
      'distance': distance,
    };

    if (widget.existingRoute != null) {
      await widget.existingRoute!.reference.update(routeData);
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        routeData['user_id'] = user.uid;
      }
      await FirebaseFirestore.instance.collection('routes').add(routeData);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Route opgeslagen!')),
    );

    Navigator.pop(context);
  }

  void undoLastPoint() {
    if (tappedPoints.isNotEmpty) {
      setState(() {
        undonePoints.add(tappedPoints.removeLast());
        calculateDistance();
      });
    }
  }

  void redoLastPoint() {
    if (undonePoints.isNotEmpty) {
      setState(() {
        tappedPoints.add(undonePoints.removeLast());
        calculateDistance();
      });
    }
  }

  void discardRoute() {
    setState(() {
      tappedPoints.clear();
      undonePoints.clear();
      distance = 0.0;
    });
  }

  void calculateDistance() {
    final Distance calculator = Distance();
    double totalDistance = 0.0;
    for (int i = 0; i < tappedPoints.length - 1; i++) {
      totalDistance += calculator.as(
        LengthUnit.Kilometer,
        tappedPoints[i],
        tappedPoints[i + 1],
      );
    }
    distance = totalDistance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nieuwe Route Maken')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: tappedPoints.isNotEmpty ? tappedPoints.first : LatLng(51.05, 3.72),
              zoom: 13,
              onTap: (tapPosition, point) {
                setState(() {
                  tappedPoints.add(point);
                  undonePoints.clear();
                  calculateDistance();
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: tappedPoints,
                    strokeWidth: 4,
                    color: Colors.blue,
                  ),
                ],
              ),
              MarkerLayer(
                markers: tappedPoints
                    .map(
                      (point) => Marker(
                        width: 40,
                        height: 40,
                        point: point,
                        child: Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Route Naam',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: undoLastPoint,
                          icon: Icon(Icons.undo),
                          label: Text('Undo'),
                        ),
                        ElevatedButton.icon(
                          onPressed: redoLastPoint,
                          icon: Icon(Icons.redo),
                          label: Text('Redo'),
                        ),
                        ElevatedButton.icon(
                          onPressed: discardRoute,
                          icon: Icon(Icons.delete),
                          label: Text('Discard'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('Afstand: ${distance.toStringAsFixed(2)} km'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: saveRoute,
        icon: Icon(Icons.save),
        label: Text('Opslaan'),
      ),
    );
  }
}
