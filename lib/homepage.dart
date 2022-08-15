import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:side_projects/dircetions.dart';
import 'package:side_projects/direction_model.dart';

class MapWithDirection extends StatefulWidget {
  const MapWithDirection({Key? key}) : super(key: key);

  @override
  State<MapWithDirection> createState() => _MapWithDirectionState();
}

class _MapWithDirectionState extends State<MapWithDirection> {
  static const _initialCameraPosition =
      CameraPosition(target: LatLng(37.773972, -122.431297), zoom: 11.5);

  late GoogleMapController _googleMapController;

  Marker? _origin;
  Marker? _destination;
  Directions? _info;

  MapType _defaultMapType = MapType.normal;

  void _changeMapType() {
    setState(() {
      _defaultMapType = _defaultMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  ///////////////
  final Set<Marker> _markers = {};

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text("Google Map"),
          actions: [
            _origin != null
                ? TextButton(
                    onPressed: () {
                      _googleMapController.animateCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                              target: _origin!.position,
                              zoom: 14.5,
                              tilt: 50.0)));
                    },
                    child: const Text("ORIGIN"),
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle:
                            const TextStyle(fontWeight: FontWeight.bold)),
                  )
                : Container(),
            _destination != null
                ? TextButton(
                    onPressed: () {
                      _googleMapController.animateCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                              target: _destination!.position,
                              zoom: 14.5,
                              tilt: 50.0)));
                    },
                    child: const Text("DEST"),
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle:
                            const TextStyle(fontWeight: FontWeight.bold)),
                  )
                : Container()
          ]),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _initialCameraPosition,
              mapType: _defaultMapType,
              //instead of intantiating i.e initState, google map provides this line.
              onMapCreated: (controller) => _googleMapController = controller,

              markers: {
                _origin ?? const Marker(markerId: MarkerId("origin")),
                _destination ?? const Marker(markerId: MarkerId("destination"))
              },
              onLongPress: _addMaker,
            ),
            if (_info != null)
              Positioned(
                  top: 20.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                        color: Colors.yellowAccent,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 6.0)
                        ]),
                    child: Text(
                      '${_info!.totalDistance}, ${_info!.totalDuration}',
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w600),
                    ),
                  )),
            Container(
              margin: EdgeInsets.only(top: 80, right: 10),
              alignment: Alignment.topRight,
              child: Column(children: <Widget>[
                FloatingActionButton(
                    child: Icon(Icons.layers),
                    elevation: 5,
                    backgroundColor: Colors.teal[200],
                    onPressed: () {
                      _changeMapType();
                      print('Changing the Map Type');
                    }),
              ]),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () {
          _googleMapController.animateCamera(
            _info != null
                ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
                : CameraUpdate.newCameraPosition(_initialCameraPosition),
          );
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  void _addMaker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      //set origin
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
        //reset destination
        _destination = null;
        //Rest info to null
        _info = null;
      });
    } else {
      //origin is already set. set destination
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: pos,
        );
      });

      //Get Direction
      final directions = await DirectionsRepository()
          .getDirections(origin: _origin!.position, destination: pos);
      setState(() {
        _info = directions;
      });
    }
  }
}
