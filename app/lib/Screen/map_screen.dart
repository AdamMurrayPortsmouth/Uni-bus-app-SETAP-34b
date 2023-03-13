import 'package:app/MapData/feature.dart';
import 'package:app/MapData/map_data_loader.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Map/map_data_id_enum.dart';
import '../Map/open_layers_map.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final OpenLayersMap _mapController;
  final List<DropDownValueModel> dropDownList = [];

  bool _u1ValueCheck = true;
  bool _uniBuildingValueCheck = true;
  bool _landmarkValueCheck = true;

  @override
  void initState() {
    _mapController = OpenLayersMap();
    MapDataLoader.getDataLoader().onDataLoaded((mapData) {
      setState(() {
        for (Feature feature in mapData.getAllFeatures())
        {
          dropDownList.add(DropDownValueModel(name: feature.name, value: feature.id));
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _mapController.onMarkerClicked((markerId) {
      // TODO: Add implementation for what happens when a marker is clicked
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          DropDownTextField(
            controller: SingleValueDropDownController(),
            clearOption: true,
            enableSearch: true,
            textFieldDecoration: const InputDecoration(
                hintText: "Enter location here"),
            searchDecoration: const InputDecoration(
                hintText: "Enter location here"),
            validator: (value) {
              if (value == null) {
                return "Required field";
              } else {
                return null;
              }
            },
            dropDownItemCount: 5,
            dropDownList: dropDownList,
            onChanged: (value) {},
          ),
          Container(
              margin: const EdgeInsets.all(0),
              padding: const EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7059,
              decoration: BoxDecoration(
                color: const Color(0x1f000000),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.zero,
                border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
              ),
              child: WebViewWidget(controller: _mapController) // Map
              ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  "U1",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff000000),
                  ),
                ),
                Checkbox(
                  onChanged: (value) {
                    setState(() {
                      _u1ValueCheck = value!;
                    });
                    _mapController.toggleMarkers(MapDataId.u1, value!);
                  },
                  activeColor: Color(0xff3a57e8),
                  autofocus: false,
                  checkColor: Color(0xffffffff),
                  hoverColor: Color(0x42000000),
                  splashRadius: 20,
                  value: _u1ValueCheck,
                ),
                const Text(
                  "Uni building",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff000000),
                  ),
                ),
                Checkbox(
                  onChanged: (value) {
                    setState(() {
                      _uniBuildingValueCheck = value!;
                    });
                    _mapController.toggleMarkers(MapDataId.uniBuilding, value!);
                  },
                  activeColor: Color(0xff3a57e8),
                  autofocus: false,
                  checkColor: Color(0xffffffff),
                  hoverColor: Color(0x42000000),
                  splashRadius: 20,
                  value: _uniBuildingValueCheck,
                ),
                const Text(
                  "Landmarks",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff000000),
                  ),
                ),
                Checkbox(
                  onChanged: (value) {
                    setState(() {
                      _landmarkValueCheck = value!;
                    });
                    _mapController.toggleMarkers(MapDataId.landmark, value!);
                  },
                  activeColor: Color(0xff3a57e8),
                  autofocus: false,
                  checkColor: Color(0xffffffff),
                  hoverColor: Color(0x42000000),
                  splashRadius: 20,
                  value: _landmarkValueCheck,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}