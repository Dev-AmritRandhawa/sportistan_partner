import 'dart:io';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sportistan_partners/nav_bar/nav_home.dart';
import 'package:http/http.dart' as http;
import 'package:sportistan_partners/utils/errors.dart';
import 'package:sportistan_partners/utils/page_router.dart';
import 'package:sportistan_partners/utils/send_cloud_message.dart';

class BookingEntireDayInfo extends StatefulWidget {
  final String bookingID;

  const BookingEntireDayInfo({super.key, required this.bookingID});

  @override
  State<BookingEntireDayInfo> createState() => _BookingEntireDayInfoState();
}

class _BookingEntireDayInfoState extends State<BookingEntireDayInfo> {
  String? bookingType;

  String? userID;
  String? groundName;

  String? token;

  String? date;

  String? refDetails;

  num? rating;

  String? timeMsg;

  String? number;

  String? groupID;

  String? groundID;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  final _server = FirebaseFirestore.instance;

  ScreenshotController screenshotController = ScreenshotController();
  PanelController pc = PanelController();
  List<String> ratingTags = [];

  List<String> ratingOptions = [
    'Punctual',
    'Cleanliness',
    'Payment',
    'Bad Behaviour',
    'No Sportsman Spirit',
    'Last Moment Cancelled',
  ];

  ValueNotifier<bool> ratingListenable = ValueNotifier<bool>(false);

  double? updateRating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        maxHeight: MediaQuery.of(context).size.height / 2,
        minHeight: 0,
        panelBuilder: (sc) => panel(sc),
        controller: pc,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              StreamBuilder(
                stream: _server
                    .collection("GroundBookings")
                    .where("bookingID", isEqualTo: widget.bookingID)
                    .snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = snapshot.data!.docs[index];
                        bookingType = doc['bookingPerson'];
                        userID = doc['userID'];
                        groundName = doc['groundName'];
                        rating = doc['rating'];
                        refDetails = doc.id;

                        Timestamp time = doc['bookedAt'];

                        Timestamp day = doc['bookingCreated'];
                        date = DateFormat.MMMMEEEEd().format(day.toDate());
                        timeMsg = DateFormat.jm().format(time.toDate());
                        number = doc['teamA']['phoneNumber'];
                        DateTime booked = time.toDate();
                        List<dynamic> allSlotsRef = doc['includeSlots'];
                        groupID = doc['groupID'];
                        groundID = doc['groundID'];
                        return Column(
                          children: [
                            Screenshot(
                              controller: screenshotController,
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width /
                                                20,
                                        right:
                                            MediaQuery.of(context).size.width /
                                                20,
                                        top: MediaQuery.of(context).size.width /
                                            20,
                                        bottom:
                                            MediaQuery.of(context).size.width /
                                                20,
                                      ),
                                      child: Image.asset(
                                        "assets/logo.png",
                                        width:
                                            MediaQuery.of(context).size.width /
                                                15,
                                        height:
                                            MediaQuery.of(context).size.width /
                                                15,
                                      ),
                                    ),
                                    Text(doc["groundName"],
                                        style: const TextStyle(
                                            fontFamily: "DMSans",
                                            fontSize: 18)),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text("Booking Generate : "),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              "${DateFormat.yMMMMEEEEd().format(booked)} - ${DateFormat.jms().format(booked)}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true),
                                        ),
                                      ],
                                    ),
                                    const Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "Booked Slots",
                                          style:
                                              TextStyle(fontFamily: "DMSans"),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text("All Slots are Booked For a Day")
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              15,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: allSlotsRef.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: OutlinedButton(
                                                onPressed: null,
                                                child: Text(allSlotsRef[index]
                                                    .toString())),
                                          );
                                        },
                                      ),
                                    ),
                                    Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width /
                                              20,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              children: [
                                                const Text("Booking Day : "),
                                                Text(
                                                  DateFormat.MMMMEEEEd()
                                                      .format(day.toDate()),
                                                  style: const TextStyle(
                                                      fontFamily: "DMSans",
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    doc["ratingGiven"]
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              RatingBar.builder(
                                                itemSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    40,
                                                initialRating: double.parse(
                                                    rating.toString()),
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                ignoreGestures: true,
                                                itemPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4.0),
                                                itemBuilder: (context, _) =>
                                                    const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate:
                                                    (double value) {},
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  pc.open();
                                                },
                                                child: const Text("Edit",
                                                    style: TextStyle(
                                                      fontFamily: "DMSans",
                                                    )),
                                              )
                                            ],
                                          )
                                        : CupertinoButton(
                                            onPressed: () {
                                              pc.open();
                                            },
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.orange,
                                                ),
                                                Text(
                                                  "Rate Now",
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                ),
                                              ],
                                            )),
                                    const Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "Entire Day is Booked",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width / 20,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Text("Advance Received : ",
                                                  style: TextStyle(
                                                      color: Colors.green)),
                                              Text(
                                                "Rs. ${doc["advancePayment"]}",
                                                style: const TextStyle(
                                                    fontFamily: "DMSans",
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Entire Day : "),
                                              Text(
                                                "Rs. ${doc["slotPrice"]}",
                                                style: const TextStyle(
                                                    fontFamily: "DMSans",
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text("Due : "),
                                        Text(
                                          "Rs. ${doc["feesDue"]}",
                                          style: TextStyle(
                                              color: Colors.red.shade200,
                                              fontFamily: "DMSans",
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Card(
                                      child: Column(children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text("Contact Number :"),
                                              Text(doc["teamA"]["phoneNumber"],
                                                  style: const TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: "DMSans")),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text("Contact Name :"),
                                              Text(doc["teamA"]["personName"],
                                                  style: const TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: "DMSans")),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text("Notes : "),
                                              Expanded(
                                                child: Text(
                                                    doc["teamA"]["notesTeamA"],
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.visible,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontFamily: "DMSans")),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Booking Confirmed",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 22,
                                                fontFamily: "DMSaNS"),
                                          ),
                                          Icon(
                                            Icons.verified,
                                            color: Colors.green,
                                          )
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CupertinoButton(
                                            color: Colors.green,
                                            onPressed: () {
                                              PageRouter.pushRemoveUntil(
                                                  context, const NavHome());
                                            },
                                            child: const Text("Home"),
                                          ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CupertinoButton(
                                                color: Colors.indigo,
                                                onPressed: () {
                                                  takeScreenshot();
                                                },
                                                child: const Text("Share"))),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CupertinoButton(
                                          color: Colors.redAccent,
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => Platform
                                                      .isAndroid
                                                  ? AlertDialog(
                                                      content: const Text(
                                                          "Would you like to cancel booking?",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                              fontFamily:
                                                                  "DMSans")),
                                                      title: const Text(
                                                          "Cancel Booking",
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontFamily:
                                                                  "DMSans")),
                                                      actions: [
                                                        TextButton(
                                                            onPressed:
                                                                () async {
                                                              Navigator.pop(
                                                                  ctx);
                                                              await cancelEntireDayBookingCancel(
                                                                  groupID
                                                                      .toString());
                                                            },
                                                            child: const Text(
                                                                "Cancel Booking",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontFamily:
                                                                        "DMSans"))),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  ctx);
                                                            },
                                                            child: const Text(
                                                                "No",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontFamily:
                                                                        "DMSans"))),
                                                        TextButton(
                                                            onPressed: () {
                                                              const number =
                                                                  '+918591719905'; //set the number here
                                                              FlutterPhoneDirectCaller
                                                                  .callNumber(
                                                                      number);
                                                            },
                                                            child: const Text(
                                                                "Call Customer Support",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                    fontFamily:
                                                                        "DMSans"))),
                                                      ],
                                                    )
                                                  : CupertinoAlertDialog(
                                                      content: const Text(
                                                          "Would you like to cancel booking?",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                              fontFamily:
                                                                  "DMSans")),
                                                      title: const Text(
                                                          "Cancel Booking",
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontFamily:
                                                                  "DMSans")),
                                                      actions: [
                                                        TextButton(
                                                            onPressed:
                                                                () async {
                                                              Navigator.pop(
                                                                  ctx);
                                                              await cancelEntireDayBookingCancel(
                                                                  groupID
                                                                      .toString());
                                                            },
                                                            child: const Text(
                                                                "Cancel Booking",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontFamily:
                                                                        "DMSans"))),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  ctx);
                                                            },
                                                            child: const Text(
                                                                "No",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontFamily:
                                                                        "DMSans"))),
                                                        TextButton(
                                                            onPressed: () {
                                                              const number =
                                                                  '+918591719905'; //set the number here
                                                              FlutterPhoneDirectCaller
                                                                  .callNumber(
                                                                      number);
                                                            },
                                                            child: const Text(
                                                                "Call Customer Support",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                    fontFamily:
                                                                        "DMSans"))),
                                                      ],
                                                    ),
                                            );
                                          },
                                          child: const Text(
                                            "Cancel Booking",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 1,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 12,
              )
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> takeScreenshot() async {
    await screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((Uint8List? image) async {
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/image.png').create();
        await imagePath.writeAsBytes(image);
        await Share.shareFiles([imagePath.path],
            text:
                'Download Sportistan App for Your Sports Facility Booking https://www.isportistanapp.web.app/');
      }
    });
  }

  refundInit({
    required String groundID,
    required num refund,
  }) async {
    num sportistanCredit;
    try {
      await _server
          .collection("SportistanPartners")
          .where("userID", isEqualTo: userID)
          .get()
          .then((value) async => {
        if (value.docChanges.isNotEmpty)
          {
            await _server
                .collection("SportistanPartners")
                .where("groundID", isEqualTo: groundID)
                .get()
                .then((value) async => {
              sportistanCredit = value.docChanges.first.doc
                  .get('sportistanCredit'),
              await _server
                  .collection("SportistanPartners")
                  .doc(value.docChanges.first.doc.id)
                  .update({
                'sportistanCredit': sportistanCredit + refund
              }).then((v) => {
                sendNotification(
                    token: value.docChanges.first.doc
                        .get('token')),
                sendSms(number: number)
              })
            })
          }
        else
          {
            await _server
                .collection("SportistanUsers")
                .where("userID", isEqualTo: userID)
                .get()
                .then((value) async => {
              sportistanCredit = value.docChanges.first.doc
                  .get('sportistanCredit'),
              await _server
                  .collection("SportistanUsers")
                  .doc(value.docChanges.first.doc.id)
                  .update({
                'sportistanCredit': sportistanCredit + refund
              }).then((v) async => {
                sendNotification(
                    token: value.docChanges.first.doc
                        .get('token')),
                sendSms(number: number)
              })
            })
          }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to Refund")));
      }
    }
  }

  Future<void> sendSms({required String? number}) async {
    String url =
        'http://api.bulksmsgateway.in/sendmessage.php?user=sportslovez&password=7788330&mobile=$number&message=	Booking cancelled on sportistan for $date on $groundName at $timeMsg. Sportistan miss you . Stay healthy. &sender=SPTNOT&type=3&template_id=1407169988722596931';
    await http.post(Uri.parse(url));
  }

  sendNotification({required String token}) async {
    FirebaseCloudMessaging.sendPushMessage(
        "$groundName Booking is Cancelled of $date which was booked for entire day",
        "Booking Cancelled",
        token);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  late num refundCalculation;

  Future<void> cancelEntireDayBookingCancel(String groupID) async {
    try {
      await _server
          .collection("GroundBookings")
          .where('groupID', isEqualTo: groupID)
          .get()
          .then((value) async => {
                refundCalculation =
                    value.docChanges.first.doc.get("bookingCommissionCharged"),
                for (int i = 0; i < value.size; i++)
                  {
                    await _server
                        .collection("GroundBookings")
                        .doc(value.docChanges[i].doc.id)
                        .update({'isBookingCancelled': true})
                  },
                refundInit(
                    refund: refundCalculation, groundID: groundID.toString())
              });
    } catch (e) {
      return;
    }
  }

  panel(ScrollController sc) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width / 15,
              height: MediaQuery.of(context).size.width / 60,
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(50)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("How was your experience?",
                      style: TextStyle(
                          fontFamily: "DMSans",
                          fontSize: MediaQuery.of(context).size.height / 40)),
                ),
                Text("Please Give rating.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "DMSans",
                        fontSize: MediaQuery.of(context).size.height / 50)),
                RatingBar.builder(
                  initialRating: 3.5,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rate) {
                    if (rate <= 3.0) {
                      updateRating = rate;
                      ratingListenable.value = true;
                    } else {
                      updateRating = rate;
                      ratingListenable.value = false;
                    }
                  },
                ),
              ],
            ),
          ),
          ValueListenableBuilder(
            valueListenable: ratingListenable,
            builder: (context, value, child) {
              return value
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("What went wrong?",
                              style: TextStyle(
                                  fontFamily: "DMSans",
                                  fontSize:
                                      MediaQuery.of(context).size.height / 40)),
                        ),
                        ChipsChoice<String>.multiple(
                          value: ratingTags,
                          onChanged: (val) => setState(() => ratingTags = val),
                          choiceItems: C2Choice.listFrom<String, String>(
                            source: ratingOptions,
                            value: (i, v) => v,
                            label: (i, v) => v,
                            tooltip: (i, v) => v,
                          ),
                          choiceCheckmark: true,
                          wrapped: true,
                        ),
                      ],
                    )
                  : Container();
            },
          ),
          CupertinoButton(
              color: Colors.green,
              onPressed: () async {
                pc.close();
                Alert.flushBarAlert(
                    message: 'Rating Updated',
                    context: context,
                    title: 'Rating');
                await _server
                    .collection("GroundBookings")
                    .doc(refDetails)
                    .update({'rating': updateRating, 'ratingTags': ratingTags,
                'ratingGiven' : true
                });

                try {
                  await _server
                      .collection("SportistanUsers")
                      .where("userID", isEqualTo: userID)
                      .get()
                      .then((value) async => {
                    if (value.docChanges.isNotEmpty)
                      {
                        await _server
                            .collection("SportistanUsers")
                            .doc(value.docChanges.first.doc.id)
                            .update({
                          'profileRating': updateRating,
                          'profileRatingTags': ratingTags
                        })
                      }
                  });
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User Not Found')));
                  }
                }
              },
              child: const Text("Submit")),
        ],
      ),
    );
  }
}
