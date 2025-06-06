import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/pages/new_route_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RoutesOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mijn Routes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('routes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final routes = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewRoutePage(existingRoute: route),
                    ),
                  );
                },
                child: Card(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: FlutterMap(
                              options: MapOptions(
                                center: getCenter(route['points']),
                                zoom: 13,
                                interactiveFlags: InteractiveFlag.none,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.app',
                                ),
                                if (route['points'] != null)
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: (route['points'] as List)
                                            .map((p) => LatLng(p['lat'], p['lng']))
                                            .toList(),
                                        strokeWidth: 4,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              route['name'] ?? 'Geen naam',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _confirmDelete(context, route),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.delete, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewRoutePage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  LatLng getCenter(List points) {
    if (points.isEmpty) {
      return LatLng(51.05, 3.72);
    }
    double avgLat = 0;
    double avgLng = 0;
    for (var p in points) {
      avgLat += p['lat'];
      avgLng += p['lng'];
    }
    return LatLng(avgLat / points.length, avgLng / points.length);
  }

  void _confirmDelete(BuildContext context, DocumentSnapshot route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Route verwijderen'),
        content: Text('Ben je zeker dat je deze route wilt verwijderen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // annuleren
            child: Text('Annuleren'),
          ),
          TextButton(
            onPressed: () async {
              await route.reference.delete();
              Navigator.pop(context); // sluit de dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Route verwijderd')),
              );
            },
            child: Text('Verwijderen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
