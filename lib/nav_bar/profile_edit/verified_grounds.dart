import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportistan_partners/utils/errors.dart';
import 'package:sportistan_partners/utils/register_data_class.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VerifiedGrounds extends StatefulWidget {
  const VerifiedGrounds({super.key});

  @override
  State<VerifiedGrounds> createState() => _VerifiedGroundsState();
}

class _VerifiedGroundsState extends State<VerifiedGrounds> {
  final _server = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<String> rejectReason = [];

  final _storage = FirebaseStorage.instance;
  ValueNotifier<bool> setEverythingServer = ValueNotifier(false);

  @override
  void initState() {
    RegisterDataClass.groundImages.clear();
    RegisterDataClass.kycImages.clear();
    RegisterDataClass.kycUrls.clear();
    RegisterDataClass.groundUrls.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            SafeArea(
                child: StreamBuilder(
              stream: _server
                  .collection("SportistanPartners")
                  .where("userID", isEqualTo: _auth.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? snapshot.data!.docChanges.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.size,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Card(
                                child: Column(
                                  children: [
                                    Text(
                                      snapshot.data!.docChanges[index].doc
                                          .get("groundName"),
                                      overflow: TextOverflow.visible,
                                      maxLines: 2,
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22),
                                    ),  Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Ground Rating ',),
                                        Text(
                                          snapshot.data!.docChanges[index].doc
                                              .get("profileRating").toString(),
                                          overflow: TextOverflow.visible,
                                          maxLines: 2,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),const Icon(Icons.star,color: Colors.orange,)
                                      ],
                                    ),
                                    Text(
                                      snapshot.data!.docChanges[index].doc
                                          .get("locationName"),
                                      overflow: TextOverflow.visible,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            getStatus(
                                                status: snapshot
                                                    .data!.docChanges[index].doc
                                                    .get("kycStatus")),
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: getStatusColor(
                                                    status: snapshot.data!
                                                        .docChanges[index].doc
                                                        .get("kycStatus"))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.verified_outlined),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Your KYC is ${snapshot.data!.docChanges[index].doc.get("kycStatus")}",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontFamily: "DMSans",
                                                color: Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                    snapshot.data!.docChanges[index].doc
                                        .get("kycStatus") ==
                                        "Under Review" ?  Container() : snapshot.data!.docChanges[index].doc
                                                .get("kycStatus") ==
                                            "Rejected"
                                        ? Column(
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                    "Rejected Reason : ${snapshot.data!.docChanges[index].doc.get("rejectReason")}",
                                                    style: const TextStyle(
                                                        fontFamily: "DMSans")),
                                              ),
                                            Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: RegisterDataClass
                                                    .groundImages.isNotEmpty &
                                                RegisterDataClass
                                                    .kycImages.isNotEmpty
                                                    ? ValueListenableBuilder(
                                                    valueListenable:
                                                    setEverythingServer,
                                                    builder: (context, value,
                                                        child) =>
                                                    value
                                                        ? const Center(
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 1,
                                                      ),
                                                    )
                                                        : CupertinoButton(
                                                      color: Colors.green,
                                                      onPressed: () {
                                                        getKycLinks(
                                                            refID: snapshot
                                                                .data!
                                                                .docChanges[
                                                            index]
                                                                .doc
                                                                .id);
                                                      },
                                                      child: const Text(
                                                          "Upload Again for Review",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    ))
                                                    : Container()),
                                            snapshot.data!.docChanges[index].doc
                                                .get('kycStatus') !=
                                                "Rejected"
                                                ? Container()
                                                : Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                              children: [
                                                MaterialButton(
                                                    color: Colors.green,
                                                    onPressed: () {
                                                      uploadImages();
                                                    },
                                                    child: const Text(
                                                      "Ground Images",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    )),
                                                MaterialButton(
                                                    color: Colors.orangeAccent,
                                                    onPressed: () {
                                                      uploadDocuments();
                                                    },
                                                    child: const Text(
                                                      "Documents",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    )),
                                              ],
                                            ),
                                            RegisterDataClass.groundImages.isNotEmpty
                                                ? Column(
                                              children: [
                                                const Row(
                                                  children: [
                                                    Card(
                                                      color: Colors.green,
                                                      child: Padding(
                                                        padding:
                                                        EdgeInsets.all(8.0),
                                                        child: Text(
                                                            "Selected Ground Images",
                                                            style: TextStyle(
                                                                color:
                                                                Colors.white,
                                                                fontFamily:
                                                                "DMSans")),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                ListView.builder(
                                                  itemCount: RegisterDataClass
                                                      .groundImages.length,
                                                  shrinkWrap: true,
                                                  physics:
                                                  const BouncingScrollPhysics(),
                                                  itemBuilder: (context, index) {
                                                    return RegisterDataClass
                                                        .groundImages
                                                        .isNotEmpty
                                                        ? ListTile(
                                                      title: Text(
                                                          RegisterDataClass
                                                              .groundImages[
                                                          index]
                                                              .name
                                                              .toString()),
                                                      leading: SizedBox(
                                                          height: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .height /
                                                              25,
                                                          child: Image.file(File(
                                                              RegisterDataClass
                                                                  .groundImages[
                                                              index]
                                                                  .path))),
                                                      onTap: () async {
                                                        RegisterDataClass
                                                            .groundImages
                                                            .removeAt(
                                                            index);
                                                        setState(() {});
                                                      },
                                                      trailing: const Icon(
                                                          Icons
                                                              .delete_forever,
                                                          color:
                                                          Colors.red),
                                                    )
                                                        : Container();
                                                  },
                                                )
                                              ],
                                            )
                                                : Container(),
                                            RegisterDataClass.kycImages.isNotEmpty
                                                ? Column(
                                              children: [
                                                const Row(
                                                  children: [
                                                    Card(
                                                      color: Colors.orangeAccent,
                                                      child: Padding(
                                                        padding:
                                                        EdgeInsets.all(8.0),
                                                        child: Text(
                                                            "Selected Documents",
                                                            style: TextStyle(
                                                                color:
                                                                Colors.white,
                                                                fontFamily:
                                                                "DMSans")),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                ListView.builder(
                                                  itemCount: RegisterDataClass
                                                      .kycImages.length,
                                                  shrinkWrap: true,
                                                  physics:
                                                  const BouncingScrollPhysics(),
                                                  itemBuilder: (context, index) {
                                                    return RegisterDataClass
                                                        .kycImages.isNotEmpty
                                                        ? ListTile(
                                                      title: Text(
                                                          RegisterDataClass
                                                              .kycImages[
                                                          index]
                                                              .name
                                                              .toString()),
                                                      leading: SizedBox(
                                                          height: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .height /
                                                              25,
                                                          child: Image.file(File(
                                                              RegisterDataClass
                                                                  .kycImages[
                                                              index]
                                                                  .path))),
                                                      onTap: () async {
                                                        RegisterDataClass
                                                            .kycImages
                                                            .removeAt(
                                                            index);
                                                        setState(() {});
                                                      },
                                                      trailing: const Icon(
                                                          Icons
                                                              .delete_forever,
                                                          color:
                                                          Colors.red),
                                                    )
                                                        : Container();
                                                  },
                                                )
                                              ],
                                            )
                                                : Container(),
                                          ],
                                        )
                                        : Container(),

                                  ],
                                ),
                              );
                            },
                          )
                        : const Center(child: CircularProgressIndicator( strokeWidth: 1,))
                    : const Center(child: CircularProgressIndicator(strokeWidth: 1,));
              },
            )),
          ]),
        ));
  }

  Color getStatusColor({required String status}) {
    switch (status) {
      case 'Approved':
        {
          return Colors.green;
        }
      case 'Rejected':
        {
          return Colors.red;
        }
    }
    return Colors.orange;
  }

  String getStatus({required String status}) {
    switch (status) {
      case 'Approved':
        {
          return 'Approved●';
        }
      case 'Rejected':
        {
          return 'Rejected●';
        }
    }
    return 'Under Review●';
  }

  uploadImages() async {
    final ImagePicker picker = ImagePicker();
    RegisterDataClass.groundImages =
        await picker.pickMultiImage(imageQuality: 50);
    if (RegisterDataClass.groundImages.isNotEmpty) {
      setState(() {});
    }
  }

  uploadDocuments() async {
    final ImagePicker picker = ImagePicker();
    RegisterDataClass.kycImages = await picker.pickMultiImage(imageQuality: 50);
    if (RegisterDataClass.kycImages.isNotEmpty) {
      setState(() {});
    }
  }

  Future<void> getKycLinks({required String refID}) async {
    setEverythingServer.value = true;
    try {
      for (int i = 0; i < RegisterDataClass.kycImages.length; i++) {
        TaskSnapshot task = await _storage
            .ref(_auth.currentUser!.uid)
            .child("kyc")
            .child(RegisterDataClass.kycImages[i].name.toString())
            .putFile(File(RegisterDataClass.kycImages[i].path));
        await task.ref
            .getDownloadURL()
            .then((value) => {RegisterDataClass.kycUrls.add(value)});
      }
      await getGroundLinks(refID: refID);
    } catch (e) {
      setEverythingServer.value = false;
      return;
    }
  }

  Future<void> getGroundLinks({required String refID}) async {
    try {
      for (int i = 0; i < RegisterDataClass.groundImages.length; i++) {
        TaskSnapshot task = await _storage
            .ref(_auth.currentUser!.uid)
            .child("groundImages")
            .child(RegisterDataClass.groundImages[i].name.toString())
            .putFile(File(RegisterDataClass.groundImages[i].path));
        await task.ref.getDownloadURL().then((value) => {
              if (value.isNotEmpty) {RegisterDataClass.groundUrls.add(value)}
            });
      }
      setEverything(refID: refID);
    } catch (e) {
      setEverythingServer.value = false;
      return;
    }
  }

  Future<void> setEverything({required String refID}) async {
    try {
      await _server.collection("SportistanPartners").doc(refID).update({
        'isVerified': false,
        'isKYCPending': true,
        'kycStatus': 'Under Review',
        'rejectReason': [],
        'kycImageLinks': RegisterDataClass.kycUrls,
        'groundImages': RegisterDataClass.groundUrls,
      });
    } catch (e) {
      if (mounted) {
        setEverythingServer.value = false;
        Errors.flushBarInform("Something went wrong", context, "Try Again");
      }
    }
  }
}
