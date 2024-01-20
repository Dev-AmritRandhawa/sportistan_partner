import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportistan_partners/utils/register_data_class.dart';

class EditGround extends StatefulWidget {
  const EditGround({super.key});

  @override
  State<EditGround> createState() => _EditGroundState();
}

class _EditGroundState extends State<EditGround> {
  final _server = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;
  ValueNotifier<bool> switchGrounds = ValueNotifier<bool>(true);
  ValueNotifier<bool> nameChangeListener = ValueNotifier<bool>(false);
  var currentPage = 0;
  TextEditingController groundController = TextEditingController();
  GlobalKey<FormState> groundKey = GlobalKey<FormState>();
  List<dynamic> images = [];
  var newImagesElements = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text("Settings"),
            foregroundColor: Colors.black87),
        body: SafeArea(
          child: StreamBuilder(
            stream: _server
                .collection("SportistanPartners")
                .where("userID", isEqualTo: _auth.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (_, index) {
                        final docs = snapshot.data!.docs;
                        images = docs[index].get("groundImages");
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: docs[index].get('isVerified')
                              ? Card(
                                  color: Colors.grey.shade50,
                                  child: SingleChildScrollView(
                                    child: Column(children: [
                                      ValueListenableBuilder(
                                        valueListenable: nameChangeListener,
                                        builder: (context, value, child) {
                                          return value
                                              ? Form(
                                                  key: groundKey,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextFormField(
                                                      validator: (input) {
                                                        if (input!.isEmpty) {
                                                          return "Ground Name is Missing";
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.black87),
                                                      controller:
                                                          groundController,
                                                      keyboardType:
                                                          TextInputType.name,

                                                      decoration:
                                                          InputDecoration(
                                                              errorStyle:
                                                                  const TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .red),
                                                              hintText:
                                                                  "Ground Name",
                                                              hintStyle: TextStyle(
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      50,
                                                                  color: Colors
                                                                      .black87,
                                                                  fontFamily:
                                                                      "Nunito"),
                                                              fillColor: Colors
                                                                  .white,
                                                              filled: true,
                                                              suffixIcon:
                                                                  InkWell(
                                                                      onTap:
                                                                          () {
                                                                        _server
                                                                            .collection(
                                                                                "SportistanPartners")
                                                                            .doc(docs[index]
                                                                                .id)
                                                                            .update({
                                                                          'groundName': groundController
                                                                              .value
                                                                              .text
                                                                              .trim()
                                                                              .toString()
                                                                        }).then((value) =>
                                                                                {
                                                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated")))
                                                                                });
                                                                      },
                                                                      child: const Icon(
                                                                          Icons
                                                                              .check,
                                                                          color: Colors
                                                                              .green)),
                                                              border:
                                                                  const OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              )),
                                                    ),
                                                  ),
                                                )
                                              : Card(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                          docs[index]
                                                              ["groundName"],
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                "DMSans",
                                                          )),
                                                      TextButton(
                                                          onPressed: () {
                                                            nameChangeListener
                                                                .value = true;
                                                          },
                                                          child: const Text(
                                                              "Change Name"))
                                                    ],
                                                  ),
                                                );
                                        },
                                      ),
                                      CarouselSlider.builder(
                                        itemCount: images.length,
                                        itemBuilder:
                                            (BuildContext context,
                                                    int itemIndex,
                                                    int pageViewIndex) =>
                                                images.isNotEmpty
                                                    ? Stack(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        children: [
                                                          Image.network(
                                                            images[itemIndex],
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return const Text(
                                                                  "Network Error");
                                                            },
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null) {
                                                                return child;
                                                              }
                                                              return const Center(
                                                                child: CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        1),
                                                              );
                                                            },
                                                          ),
                                                          MaterialButton(
                                                            color: Colors.red,
                                                            onPressed: () {
                                                              showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                builder: (ctx) {
                                                                  return SizedBox(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height /
                                                                        3,
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child: Text(
                                                                              'Do you want to delete this photo?',
                                                                              style: TextStyle(fontSize: MediaQuery.of(context).size.width / 15, fontWeight: FontWeight.bold)),
                                                                        ),
                                                                        CupertinoButton(
                                                                            color:
                                                                                Colors.red,
                                                                            child: const Text("Yes Delete"),
                                                                            onPressed: () async {
                                                                              newImagesElements.clear();
                                                                              try {
                                                                                await _storage.refFromURL(images[itemIndex]).delete();
                                                                                images.removeAt(itemIndex);
                                                                                for (var element in images) {
                                                                                  newImagesElements.add(element);
                                                                                }
                                                                                _server.collection("SportistanPartners").doc(snapshot.data!.docs[index].id).update({
                                                                                  'groundImages': newImagesElements
                                                                                }).then((value) => {});
                                                                                if (mounted) {
                                                                                  Navigator.pop(ctx);
                                                                                }
                                                                              } catch (e) {
                                                                                if (mounted) {
                                                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error")));
                                                                                }
                                                                              }
                                                                            }),
                                                                        CupertinoButton(
                                                                            child:
                                                                                const Text("Cancel"),
                                                                            onPressed: () {
                                                                              Navigator.pop(ctx);
                                                                            }),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: const Text(
                                                                "Delete this Photo",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                        ],
                                                      )
                                                    : const Column(
                                                        children: [
                                                          Text(
                                                              "No Ground Photos",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "DMSans",
                                                                  fontSize:
                                                                      16)),
                                                          Icon(
                                                            Icons.grass_rounded,
                                                            color: Colors.green,
                                                          ),
                                                        ],
                                                      ),
                                        options: CarouselOptions(
                                          initialPage: currentPage,
                                          enlargeFactor: 0.3,
                                          scrollDirection: Axis.horizontal,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: MaterialButton(
                                                color: Colors.indigo,
                                                child: const Text(
                                                    "Add Ground Photos",
                                                    style: TextStyle(
                                                        fontFamily: "DMSans",
                                                        color: Colors.white)),
                                                onPressed: () {
                                                  pickImages(
                                                      refID: snapshot.data!
                                                          .docs[index].id);
                                                }),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => Platform
                                                          .isAndroid
                                                      ? AlertDialog(
                                                          title: const Text(
                                                              "Delete Ground?"),
                                                          content: const Text(
                                                              "Would you like to delete ground from listing?",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "DMSans")),
                                                          icon: const Icon(
                                                            Icons
                                                                .delete_forever,
                                                            color: Colors.red,
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  await _server
                                                                      .collection(
                                                                          "SportistanPartners")
                                                                      .doc(snapshot
                                                                          .data!
                                                                          .docs[
                                                                              index]
                                                                          .id)
                                                                      .delete()
                                                                      .then(
                                                                          (value) =>
                                                                              {
                                                                                Navigator.pop(ctx),
                                                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted")))
                                                                              });
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Delete",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                )),
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      ctx);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Cancel",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black54),
                                                                ))
                                                          ],
                                                        )
                                                      : CupertinoAlertDialog(
                                                          title: const Text(
                                                              "Delete Ground?"),
                                                          content: const Text(
                                                              "Would you like to delete ground from listing?",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "DMSans")),
                                                          actions: [
                                                            TextButton(
                                                                onPressed:
                                                                    () async {
                                                                      await _server
                                                                          .collection(
                                                                          "SportistanPartners")
                                                                          .doc(snapshot
                                                                          .data!
                                                                          .docs[
                                                                      index]
                                                                          .id)
                                                                          .delete()
                                                                          .then(
                                                                              (value) =>
                                                                          {
                                                                            Navigator.pop(ctx),
                                                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted")))
                                                                          });
                                                                    },
                                                                child:
                                                                    const Text(
                                                                  "Delete",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                )),
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      ctx);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Cancel",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black54),
                                                                ))
                                                          ],
                                                        ),
                                                );
                                              },
                                              child: const Text("Delete Ground",
                                                  style: TextStyle(
                                                      fontFamily: "DMSans",
                                                      color: Colors.red)),
                                            ),
                                          )
                                        ],
                                      )
                                    ]),
                                  ),
                                )
                              : Center(
                                  child: Card(
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          docs[index].get('groundName'),
                                          style: const TextStyle(
                                            fontSize: 22,
                                            color: Colors.black54,
                                              fontFamily: "DMSans"

                                          ),
                                          softWrap: true,
                                        ),
                                        const Text(
                                          'Ground Not Verified Yet',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.red,
                                              fontFamily: "DMSans"

                                          ),
                                          softWrap: true,
                                        ),
                                        const Icon(Icons.warning,color: Colors.orange,),
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text
                                            (
                                            'You have any query related KYC that why still pending can call Customer Support or wait few hours to complete',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 18,
                                              fontFamily: "DMSans"
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                        IconButton(onPressed: (){
                                          FlutterPhoneDirectCaller.callNumber('+918591719906');
                                        }, icon: const Icon(Icons.call,color: Colors.green,))
                                      ],
                                    )),
                                  ),
                                ),
                        );
                      },
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: CircularProgressIndicator()),
                      ],
                    );
            },
          ),
        ));
  }

  Future<void> pickImages({required String refID}) async {
    final ImagePicker picker = ImagePicker();
    RegisterDataClass.groundImages =
        await picker.pickMultiImage(imageQuality: 50);
    if (RegisterDataClass.groundImages.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
            "Updating",
          ),
          backgroundColor: Colors.green.shade900,
        ));
      }
      getGroundLinks(refID: refID);
    }
  }

  Future<void> getGroundLinks({required String refID}) async {
    for (int i = 0; i < RegisterDataClass.groundImages.length; i++) {
      TaskSnapshot task = await _storage
          .ref(_auth.currentUser!.uid)
          .child("groundImages")
          .child(RegisterDataClass.groundImages[i].name.toString())
          .putFile(File(RegisterDataClass.groundImages[i].path));
      await task.ref.getDownloadURL().then((value) => {
            if (value.isNotEmpty) {images.add(value)}
          });
    }

    sendImageToServer(refID: refID);
  }

  Future<void> sendImageToServer({required String refID}) async {
    _server
        .collection("SportistanPartners")
        .doc(refID)
        .update({'groundImages': images});
  }
}
