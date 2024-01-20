import 'package:app_settings/app_settings.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:sportistan_partners/authentication/phone_authentication.dart';
import 'package:sportistan_partners/utils/page_router.dart';

class CheckLocationPermission extends StatefulWidget {
  const CheckLocationPermission({super.key});

  @override
  State<CheckLocationPermission> createState() =>
      _CheckLocationPermissionState();
}

class _CheckLocationPermissionState extends State<CheckLocationPermission>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _controller.dispose();
    super.dispose();
  }

  bool locationPermission = false;

  Future<void> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _moveToRegister();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      setState(() {
        locationPermission = true;
      });
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

  void onResumed() {
    determinePosition();
  }

  void onHidden() {}

  void onPaused() {}

  void onInactive() {}

  void onDetached() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/permissionBackground.png"),
              fit: BoxFit.fill),
        ),
        child: SafeArea(
            child: DelayedDisplay(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 10,
                    width: MediaQuery.of(context).size.width / 2,
                    child: Image.asset(
                      "assets/logo.png",
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "We need location permission to register your ground.",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "DMSans",
                          fontSize: MediaQuery.of(context).size.height / 30,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              Card(color: Colors.green.shade100,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 4,
                  width: MediaQuery.of(context).size.width / 2,
                  child: Lottie.asset(
                    'assets/permission.json',
                    controller: _controller,
                    onLoaded: (composition) {
                      _controller
                        ..duration = composition.duration
                        ..repeat();
                    },
                  ),
                ),
              ),
              locationPermission
                  ? CupertinoButton(
                      color: Colors.white,
                      onPressed: () {
                        AppSettings.openAppSettings();
                      },
                      child: const Text(
                        "Open Settings",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ))
                  : CupertinoButton(
                      color: Colors.white,
                      onPressed: () {
                        determinePosition();
                      },
                      child: const Text(
                        "Allow Permission",
                        style: TextStyle(
                            color: Colors.blueGrey,fontFamily: "DMSans",
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            ),
                      )),
              Padding(
                padding:  EdgeInsets.all(MediaQuery.of(context).size.width/25),
                child: Text(
                  "Important: If an app has permission to use your device's location, it can use your device's approximate location, precise location, or both.",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "DMSans",
                      fontSize: MediaQuery.of(context).size.height / 50,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  void _moveToRegister() {
    if (mounted) {
      PageRouter.pushRemoveUntil(context, const PhoneAuthentication());
    }
  }
}
