import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:lottie/lottie.dart';
import 'package:sportistan_partners/utils/errors.dart';

class SportistanCredit extends StatefulWidget {
  const SportistanCredit({super.key});

  @override
  State<SportistanCredit> createState() => _SportistanCreditState();
}

class _SportistanCreditState extends State<SportistanCredit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  String? result;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    _futureGroundTypes();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> groundID = [];
  int groundIndex = 0;
  List<String> dropDownList = [];
  String? dropDownValue;

  final _server = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  ValueNotifier<bool> switchGrounds = ValueNotifier<bool>(true);
  ValueNotifier<bool> showError = ValueNotifier<bool>(false);

  late num balance;

  Future<void> _futureGroundTypes() async {
    dropDownList.clear();
    groundID.clear();

    _server
        .collection("SportistanPartners")
        .where("userID", isEqualTo: _auth.currentUser!.uid)
        .get()
        .then((value) => {
      if (value.docChanges.isNotEmpty)
        {
          for (int i = 0; i < value.size; i++)
            {
              dropDownList.add(value.docs[i]["groundName"]),
              groundID.add(value.docs[i]["groundID"]),
            },
          dropDownValue = dropDownList[0],
          getBalance()
        }
      else
        {
          Errors.flushBarInform("Ground not found or may deleted",
              context, "No Ground Found")
        },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(children: [
        SafeArea(
          child: ValueListenableBuilder(
            valueListenable: switchGrounds,
            builder: (context, value, child) => value
                ? const Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(7.0),
                    child: CircularProgressIndicator(
                      color: Colors.black45,
                      strokeWidth: 1,
                    ),
                  ),
                ],
              ),
            )
                : Card(
              color: Colors.teal.shade400,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton(
                    elevation: 0,
                    underline: Container(),
                    value: dropDownValue,
                    dropdownColor: Colors.black,
                    style: TextStyle(
                      fontFamily: "DMSans",
                      fontSize: MediaQuery.of(context).size.height / 50,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    items: dropDownList.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (dropDownValue != newValue) {
                        dropDownValue = newValue!;
                        switchGrounds.value = true;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        ValueListenableBuilder(
            valueListenable: switchGrounds,
            builder: (context, value, child) => value
                ? Container()
                : DelayedDisplay(
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        overflow: TextOverflow.fade,
                        "Your Balance in ${dropDownList[groundIndex]}",
                        style: const TextStyle(
                            fontFamily: "DMSans", fontSize: 20),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Rs.",
                          style: TextStyle(
                              fontFamily: "DMSans", fontSize: 25),
                        ),
                        Text(
                          balance.toString(),
                          style: const TextStyle(
                              fontFamily: "DMSans", fontSize: 100),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            )),

        Lottie.asset(
          'assets/wallet.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
          },
        ),
        Column(
          children: [
            const Text("Need more credits?",style: TextStyle(fontFamily: "DMSans")),
            CupertinoButton(
                color: Colors.green,
                child: const Text("Contact Support"),
                onPressed: () {
                  FlutterPhoneDirectCaller.callNumber('+918591719905');
                }),
          ],
        ),

      ]),
    );
  }

  Future<void> getBalance() async {
    await _server
        .collection("SportistanPartners")
        .where("groundID", isEqualTo: groundID[groundIndex])
        .get()
        .then((value) => {
      if (value.docChanges.isNotEmpty)
        {
          balance = value.docChanges.first.doc.get('sportistanCredit'),
          switchGrounds.value = false,
        }
      else
        {showError.value = true}
    });
  }

}