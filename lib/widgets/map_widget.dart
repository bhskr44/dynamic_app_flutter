import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/permission_service.dart';

class MapWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;

  const MapWidget({super.key, required this.widgetData});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _currentLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Add markers from data
    final markersData = widget.widgetData['markers'] as List<dynamic>? ?? [];
    for (var markerData in markersData) {
      final lat = (markerData['latitude'] as num?)?.toDouble();
      final lng = (markerData['longitude'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(markerData['id']?.toString() ?? '${lat}_$lng'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: markerData['title']?.toString() ?? '',
              snippet: markerData['description']?.toString() ?? '',
            ),
          ),
        );
      }
    }

    // Get current location if requested
    if (widget.widgetData['show_current_location'] == true) {
      await _getCurrentLocation();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      // Request location permission with user-friendly dialog
      final hasPermission = await PermissionService.requestPermissionWithDialog(
        context: context,
        permission: Permission.location,
        title: 'Location Permission',
        message: 'This app needs access to your location to show it on the map.',
      );

      if (!hasPermission) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      _currentLocation = LatLng(position.latitude, position.longitude);

      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = (widget.widgetData['height'] as num?)?.toDouble() ?? 400.0;
    final latitude = (widget.widgetData['latitude'] as num?)?.toDouble() ?? 0.0;
    final longitude = (widget.widgetData['longitude'] as num?)?.toDouble() ?? 0.0;
    final zoom = (widget.widgetData['zoom'] as num?)?.toDouble() ?? 12.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _isLoading
              ? Container(
                  color: const Color(0xFFF8FAFC),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? LatLng(latitude, longitude),
                    zoom: zoom,
                  ),
                  markers: _markers,
                  myLocationEnabled: widget.widgetData['show_current_location'] == true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: _getMapType(),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
        ),
      ),
    );
  }

  MapType _getMapType() {
    final type = widget.widgetData['map_type']?.toString() ?? 'normal';
    switch (type) {
      case 'satellite':
        return MapType.satellite;
      case 'hybrid':
        return MapType.hybrid;
      case 'terrain':
        return MapType.terrain;
      default:
        return MapType.normal;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
