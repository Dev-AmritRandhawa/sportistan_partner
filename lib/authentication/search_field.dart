import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sportistan_partners/assistants/map_key.dart';
import 'package:sportistan_partners/assistants/request_api.dart';
import 'package:sportistan_partners/authentication/ground_photos.dart';
import 'package:sportistan_partners/nav_bar/nav_home.dart';
import 'package:sportistan_partners/utils/page_router.dart';
import 'package:sportistan_partners/utils/register_data_class.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> with WidgetsBindingObserver {
  PanelController pc = PanelController();
  late Position position;
  List<dynamic> listData = [];
  var searchController = TextEditingController();
  late double customLatitude;
  late double customLongitude;

  late String placeId;

  late double latitude;
  late double longitude;

  late String address;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    locateMe();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ValueNotifier<bool> setMap = ValueNotifier<bool>(false);
  final List<Marker> markers = <Marker>[];
  double panelHeightOpen = 0.0;
  double panelHeightClosed = 0.0;
  late GoogleMapController refController;
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGoogle = CameraPosition(
    target: LatLng(20.593683, 78.962883),
    zoom: 18,
  );

  @override
  Widget build(BuildContext context) {
    panelHeightClosed = MediaQuery.of(context).size.height / 15;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(alignment: Alignment.topCenter, children: <Widget>[
        GoogleMap(
          zoomGesturesEnabled: true,
          initialCameraPosition: _kGoogle,
          markers: Set<Marker>.of(markers),
          scrollGesturesEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          buildingsEnabled: true,
          compassEnabled: false,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            if(!_controller.isCompleted){
              _controller.complete(controller);
              pc.open();
            }

          },
        ),
        SafeArea(
          child: SingleChildScrollView(
            child: DelayedDisplay(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 1.0,
                      child: TextFormField(
                        style: const TextStyle(color: Colors.black),
                        controller: searchController,
                        onChanged: (value) {
                          _placeApiRequest(value);
                        },
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    searchController.clear();
                                    listData = [];
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.black87,
                                )),
                            hintText: "Search location on Map",
                            fillColor: Colors.white,
                            filled: true,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            )),
                      ),
                    ),
                  ),
                  (listData.isNotEmpty)
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListView.builder(
                            itemCount: listData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () async {
                                  address =
                                      "${listData[index]["structured_formatting"]["main_text"] + " ${listData[index]["structured_formatting"]["secondary_text"]}" + " ${listData[index]["description"]}"}";
                                  setState(() {});

                                  placeId = listData[index]["place_id"];

                                  String url =
                                      "https://maps.googleapis.com/maps/api/place/details/json?placeid=${listData[index]["place_id"]}&key=${MapKey.key}";
                                  var response =
                                      await RequestApi.getRequestUrl(url);
                                  if (RequestApi.responseState) {
                                    customLatitude = await response["result"]
                                        ["geometry"]["location"]["lat"];
                                    customLongitude = await response["result"]
                                        ["geometry"]["location"]["lng"];
                                  }
                                  clearList();
                                  final GoogleMapController controller =
                                      await _controller.future;
                                  await controller.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: LatLng(customLatitude,
                                                  customLongitude),
                                              zoom: 18)));
                                  markers.add(
                                    Marker(
                                        draggable: true,
                                        onDragEnd: (latlng) {
                                          dragCustomLocation(latlng);
                                        },
                                        visible: true,
                                        infoWindow: InfoWindow(
                                          // given title for marker
                                          title: 'Location: $address',
                                        ),
                                        position: LatLng(
                                            customLatitude, customLongitude),
                                        markerId:
                                            const MarkerId("Custom Location"),
                                        icon: BitmapDescriptor.defaultMarker),
                                  );
                                  latitude = customLatitude;
                                  longitude = customLongitude;
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.height / 60),
                                    child: ListBody(
                                      children: [
                                        Text(
                                          listData[index]["structured_formatting"]
                                                  ["main_text"]
                                              .toString(),
                                          style: const TextStyle(
                                            fontFamily: "Nunito",
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          softWrap: false,
                                          maxLines: 4,
                                        ),
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.height /
                                                  30,
                                        ),
                                        Text(
                                          listData[index]["structured_formatting"]
                                                  ["secondary_text"]
                                              .toString(),
                                          softWrap: false,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          listData[0]["description"].toString(),
                                          softWrap: false,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.height /
                                                  30,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: MediaQuery.of(context).size.width / 25,
          bottom: MediaQuery.of(context).size.height / 10,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              myLocationMarker();
              locateMe();
              clearList();
            },
            child: const Icon(
              Icons.location_on,
              color: Colors.green,
            ),
          ),
        ),
        SlidingUpPanel(
          controller: pc,
          defaultPanelState: PanelState.CLOSED,
          maxHeight: panelHeightOpen = MediaQuery.of(context).size.height / 3,
          minHeight: panelHeightClosed,
          parallaxEnabled: true,
          parallaxOffset: .5,
          panelBuilder: (sc) => _panel(sc),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
        )
      ]),
    );
  }

  _panel(ScrollController sc) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [

                const Icon(Icons.location_on,color: Colors.red,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      "Hold & drag marker to change location",
                      style: TextStyle(
                        fontFamily: "Nunito",
                        fontSize: MediaQuery.of(context).size.width / 22,
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder(
                  builder: (BuildContext context, value, Widget? child) {
                    return value
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    address,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                25,
                                        fontFamily: "Nunito"),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container();
                  },
                  valueListenable: setMap,
                ),
              ],
            ),
            ValueListenableBuilder(
              valueListenable: setMap,
              builder: (BuildContext context, value, Widget? child) {
                return value
                    ? CupertinoButton(
                        color: Colors.green,
                        child: const Text(
                          "Proceed",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          RegisterDataClass.latitude = latitude;
                          RegisterDataClass.longitude = longitude;
                          RegisterDataClass.address = address;
                          PageRouter.push(
                              context,
                              const GroundPhotos(
                              ));
                        })
                    : Platform.isIOS
                        ? const CupertinoActivityIndicator()
                        : const CircularProgressIndicator(strokeWidth: 1,);
              },
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Set Ground Location to Get Relevant result to users",
                style: TextStyle(
                    fontSize: 15, fontFamily: "Nunito", color: Colors.black54),
              ),
            )
          ],
        ),
      ),
    );
  }

  void locateMe() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 18,
    );
    final GoogleMapController controller = await _controller.future;
    refController = controller;
    if(mounted) {
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }

    String data = await RequestMethods.searchCoordinateRequests(
        LatLng(position.latitude, position.longitude));
    latitude = position.latitude;
    longitude = position.longitude;
    address = data;

    myLocationMarker();

    address = data;
    setMap.value = true;
  }

  void myLocationMarker() {
    markers.add(
      Marker(
          draggable: true,
          onDragEnd: (latlng) {
            dragCustomLocation(latlng);
          },
          visible: true,
          infoWindow: InfoWindow(
            title: 'Location: $address',
          ),
          position: LatLng(position.latitude, position.longitude),
          markerId: const MarkerId("My Location"),
          icon: BitmapDescriptor.defaultMarker),
    );
    if(mounted){
    setState(() {});
  }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        onPaused();
        break;
      case AppLifecycleState.paused:
        onInactive();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
      case AppLifecycleState.hidden:
        onHidden();
        break;
    }
  }

  Future<void> onResumed() async {
    locateMe();
  }

  void onPaused() {}

  void onHidden() {}

  void onInactive() {}

  void onDetached() {}

  showError() {
    if (Platform.isAndroid) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Location Disabled"),
          content:
              const Text("Location is disabled please allow in app settings"),
          actions: [
            TextButton(
                onPressed: () {
                  AppSettings.openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text("Allow")),
            TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NavHome(),
                      ),
                      (route) => false);
                },
                child: const Text("Cancel"))
          ],
        ),
      );
    }
    if (Platform.isIOS) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Location Disabled"),
          content:
              const Text("Location is disabled please allow in app settings"),
          actions: [
            TextButton(
                onPressed: () {
                  AppSettings.openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text(
                  "Allow",
                  style: TextStyle(color: Colors.black),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const NavHome(),
                      ),
                      (route) => false);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ))
          ],
        ),
      );
    }
  }

  Future<void> dragCustomLocation(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 18)));
    address = await RequestMethods.searchCoordinateRequests(position);
    longitude = position.longitude;
    latitude = position.latitude;
    pc.open();
    setState(() {});
  }

  Future<void> _placeApiRequest(String userKeyboard) async {
    if (userKeyboard.length > 1) {
      String autoComplete =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$userKeyboard&location=$latitude%2C$longitude&radius=100&key=${MapKey.key}";
      var response = await RequestApi.getRequestUrl(autoComplete);
      if (response["status"] == "OK") {
        var prediction = response["predictions"];
        setState(() {
          listData = prediction;
        });
      }
    }
  }

  void clearList() {
    searchController.clear();
    listData = [];
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
