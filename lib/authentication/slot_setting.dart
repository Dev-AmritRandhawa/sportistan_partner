import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportistan_partners/nav_bar/slot_add_settings.dart';

class UniqueID {
  static String generateRandomString() {
    var random = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(25, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}

class SlotSettings extends StatefulWidget {
  const SlotSettings({super.key});

  @override
  SlotSettingsState createState() => SlotSettingsState();
}

class SlotSettingsState extends State<SlotSettings> {
  final PageController _pageController = PageController(initialPage: 0);

  int currentPage = 0;

  ValueNotifier<bool> showSlots = ValueNotifier<bool>(false);

  _onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  void initState() {
    setGroundID();
    super.initState();
  }

  setGroundID() async {
    String id = UniqueID.generateRandomString();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('groundID', id);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              itemCount: 7,
              onPageChanged: _onPageChanged,
              itemBuilder: (ctx, i) => ValueListenableBuilder(
                    valueListenable: showSlots,
                    builder: (context, value, child) {
                      return _listOfWidget[i];
                    },
                  )),
          SafeArea(
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                  child: const Text(
                    "Next",
                  ),
                  onPressed: () {
                    if (DataSave.entries.isNotEmpty) {
                      if (DataSave.isDataSave) {
                        _pageController.animateToPage(currentPage + 1,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeIn);
                        DataSave.isDataSave = false;
                        DataSave.entries.clear();
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (ctx) => Platform.isAndroid
                            ? AlertDialog(
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text("Ok"))
                                ],
                                title: const Text("Save Data"),
                                content:
                                    const Text("Please Save Slots to Continue Next."),
                              )
                            : CupertinoAlertDialog(
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text("Ok"))
                                ],
                                title: const Text("Save Data"),
                                content:
                                    const Text("Please Save The Slots First"),
                              ),
                      );
                    }
                  }),
            ]),
          ),
        ],
      ),
    );
  }

  final List<Widget> _listOfWidget = <Widget>[
    const SlotAddSettings(
      day: 'Monday',
    ),
    const SlotAddSettings(
      day: 'Tuesday',
    ),
    const SlotAddSettings(
      day: 'Wednesday',
    ),
    const SlotAddSettings(
      day: 'Thursday',
    ),
    const SlotAddSettings(
      day: 'Friday',
    ),
    const SlotAddSettings(
      day: 'Saturday',
    ),
    const SlotAddSettings(
      day: 'Sunday',
    ),
  ];
}
