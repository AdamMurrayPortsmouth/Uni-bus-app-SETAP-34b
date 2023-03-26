import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import '../Permissions/location_permissions_handler.dart';
import 'map_data_id_enum.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => MapWidgetState<MapWidget>();
}

/// The route screen state.
class MapWidgetState<E extends StatefulWidget> extends State<E> {

  @protected
  String mapPath = "";
  @protected
  late final WebViewPlus webView;
  @protected
  late final WebViewPlusController controllerPlus;
  @protected
  late final WebViewController webViewController;
  @protected
  late final Function(String)? onPageFinished;
  @protected
  final Set<JavascriptChannel> javascriptChannels = {};

  /// Creates the webview with the map.
  @override
  void initState() {
    webView = WebViewPlus(
      serverPort: 5353,
      initialUrl: mapPath,
      javascriptChannels: javascriptChannels,
      onWebViewCreated: (controller) async {
        controllerPlus = controller;
        webViewController = controllerPlus.webViewController;
      },
      onPageFinished: onPageFinished,
      javascriptMode: JavascriptMode.unrestricted,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: webView,
    );
  }

  // Centres and zooms the map around the given lat, long and zoom.
  @protected
  setMapCentreZoom(double lat, double long, double zoom) {
    String jsObject = "{lat: $lat, long: $long, zoom: $zoom}";
    webViewController.runJavascript("setCentreZoom($jsObject)");
  }

  // Adds the markers.
  @protected
  addMarker(MapDataId layerId, String id, double long, double lat)
  {
    String jsObject =
        "{layerId: '${layerId
        .idPrefix}', id: '$id', longitude: $long, latitude: $lat}";
    webViewController.runJavascript("addMarker($jsObject)");
  }

  // Updates the position of the marker.
  @protected
  updateMarker(MapDataId layerId, String id, double long, double lat) {
    String jsObject =
        "{layerId: '${layerId
        .idPrefix}', id: '$id', longitude: $long, latitude: $lat}";
    webViewController.runJavascript("updateMarker($jsObject)");
  }

  // Adds the users location to the map as a marker and sets for it be updated
  // whenever the user moves.
  @protected
  addUserLocationIcon() async {
    LocationPermissionsHandler handler =
    LocationPermissionsHandler.getHandler();
    Location location = handler.getLocation();

    if (await handler.hasPermission()) {
      LocationData currentLocation = await location.getLocation();
      addMarker(MapDataId.userLocation, MapDataId.userLocation.idPrefix,
          currentLocation.longitude!, currentLocation.latitude!);
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      updateMarker(MapDataId.userLocation, MapDataId.userLocation.idPrefix,
          currentLocation.longitude!, currentLocation.latitude!);
    });
  }
}