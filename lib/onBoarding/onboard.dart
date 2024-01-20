import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportistan_partners/authentication/location_permission.dart';
import 'package:sportistan_partners/authentication/phone_authentication.dart';
import 'package:sportistan_partners/onBoarding/slide_items.dart';
import 'package:sportistan_partners/onBoarding/slide_list.dart';
import 'package:sportistan_partners/utils/page_router.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({super.key});

  @override
  State<OnBoard> createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return  Scaffold(
        bottomSheet: _currentPage != slideList.length - 1
            ? Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height / 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                        color: Colors.green.shade900,
                        onPressed: () {
                          _pageController.animateToPage(_currentPage + 1,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeIn);
                        },
                        child: const Text(
                          "Next",
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              )
            : DelayedDisplay(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:   EdgeInsets.only(bottom: MediaQuery.of(context).size.height/25),
                      child: CupertinoButton(
                        onPressed: () {
                             _check();
                        },
                        color: Colors.indigo,
                        child: Text(

                          "Let's Start",
                          style: TextStyle(
                          letterSpacing: 1.0,
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.height / 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        body: Stack(
          children: [
             SafeArea(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sportistan Partners",
                  style: TextStyle(
                      fontFamily: "Nunito",fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height/30),
                ),
              ],
            )),
            PageView.builder(
              physics: const BouncingScrollPhysics(),
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: slideList.length,
              itemBuilder: (ctx, i) => SlideItem(i),
            ),
          ],
        ),

    );
  }

  void _moveToRegister() {
    PageRouter.pushRemoveUntil(context, const PhoneAuthentication());
  }

  void _moveToPermission() {
    PageRouter.pushRemoveUntil(context, const CheckLocationPermission());

  }

  Future<void> _check() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    userStateSave();
    if(permission == LocationPermission.always || permission == LocationPermission.whileInUse){
      _moveToRegister();
    }else{
      _moveToPermission();
    }
  }
}

void userStateSave() async {
  final data = await SharedPreferences.getInstance();
  data.setBool("onBoarding", true);
}
