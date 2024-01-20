import 'dart:io';
import 'package:chips_choice/chips_choice.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sportistan_partners/authentication/slot_setting.dart';
import 'package:sportistan_partners/bookings/book_a_slot.dart';
import 'package:sportistan_partners/utils/page_router.dart';
import 'package:sportistan_partners/utils/register_data_class.dart';

class GroundDetailsRegister extends StatefulWidget {
  const GroundDetailsRegister({super.key});

  @override
  State<GroundDetailsRegister> createState() => _GroundDetailsRegisterState();
}

class _GroundDetailsRegisterState extends State<GroundDetailsRegister> {
  TextEditingController nameController = TextEditingController();
  TextEditingController groundController = TextEditingController();
  GlobalKey<FormState> groundKey = GlobalKey<FormState>();
  GlobalKey<FormState> nameKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    groundController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  List<File>? selectedFiles = [];

  String? sportTags = "Cricket";
  List<String> sportOptions = [
    'Cricket',
    'Football',
    'Tennis',
    'Hockey',
    'Badminton',
    'Volleyball',
    'Swimming',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          title: const Text('Back'),
          backgroundColor: Colors.orange.shade50,
          foregroundColor: Colors.black,
          actions: [
            RegisterDataClass.kycImages.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      RegisterDataClass.groundName =
                          groundController.value.text;
                      RegisterDataClass.personName = nameController.value.text;
                      setSlots();
                    },
                    icon: const Icon(Icons.arrow_forward_ios_sharp))
                : Container()
          ]),
      backgroundColor: Colors.orange.shade50,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: DelayedDisplay(
          child: Column(
            children: [
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Ground Register"),
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Let's create account & Complete The KYC",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height / 40,
                      fontFamily: "DMSans",
                      color: Colors.black),
                ),
              ),
              Form(
                key: nameKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (input) {
                      if (input!.isEmpty) {
                        return "Name is Missing";
                      } else {
                        return null;
                      }
                    },
                    style: const TextStyle(color: Colors.black87),
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        errorStyle: const TextStyle(color: Colors.red),
                        hintText: "Owner Name as Per Documents",
                        hintStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / 50,
                            color: Colors.black87,
                            fontFamily: "Nunito"),
                        fillColor: Colors.white,
                        filled: true,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        )),
                  ),
                ),
              ),
              Form(
                key: groundKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (input) {
                      if (input!.isEmpty) {
                        return "Ground Name is Missing";
                      } else {
                        return null;
                      }
                    },
                    style: const TextStyle(color: Colors.black87),
                    controller: groundController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        errorStyle: const TextStyle(color: Colors.red),
                        hintText: "Ground Name",
                        hintStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / 50,
                            color: Colors.black87,
                            fontFamily: "Nunito"),
                        fillColor: Colors.white,
                        filled: true,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        )),
                  ),
                ),
              ),
              Card(
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        addAutomaticKeepAlives: true,
                        children: <Widget>[
                          Content(
                            title: 'Choose Ground Type',
                            child: ChipsChoice<String>.single(
                              value: sportTags,
                              onChanged: (val) =>
                                  setState(() => sportTags = val),
                              choiceItems: C2Choice.listFrom<String, String>(
                                source: sportOptions,
                                value: (i, v) => v,
                                label: (i, v) => v,
                                tooltip: (i, v) => v,
                              ),
                              choiceCheckmark: true,
                              choiceStyle: C2ChipStyle.filled(
                                selectedStyle: const C2ChipStyle(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(25),
                                  ),
                                ),
                              ),
                              wrapped: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Proof of Ownership",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const Column(
                      children: [
                        Text("-Attach your Identity Proof",
                            style: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        Text("-Attach your Ownership Proof",
                            style: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RegisterDataClass.kycImages.isNotEmpty ? Container() :
                        MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                            color: Colors.orangeAccent,
                            child: const Text("Choose File",
                                style: TextStyle(color: Colors.white)),
                            onPressed: () async {
                              if (nameKey.currentState!.validate() &
                                  groundKey.currentState!.validate()) {
                                uploadImages();
                              }
                            }),
                        RegisterDataClass.kycImages.isNotEmpty
                            ? MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                elevation: 0,
                                color: Colors.green,
                                child: const Text("Set Slots",
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  RegisterDataClass.groundName =
                                      groundController.value.text;
                                  RegisterDataClass.personName =
                                      nameController.value.text;
                                  setSlots();
                                })
                            : const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Images Not Selected',
                                    style: TextStyle(
                                        fontFamily: "DMSans",
                                        color: Colors.red)),
                              ),
                      ],
                    ),
                    ListView.builder(
                      itemCount: RegisterDataClass.kycImages.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return RegisterDataClass.kycImages.isNotEmpty
                            ? ListTile(
                                title: Text(RegisterDataClass
                                    .kycImages[index].name
                                    .toString()),
                                leading: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 25,
                                    child: Image.file(File(RegisterDataClass
                                        .kycImages[index].path))),
                                onTap: () async {
                                  setState(() {
                                    RegisterDataClass.kycImages.removeAt(index);
                                  });
                                },
                                trailing: const Icon(Icons.delete_forever,
                                    color: Colors.red),
                              )
                            : Container();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  uploadImages() async {
    final ImagePicker picker = ImagePicker();
    RegisterDataClass.kycImages = await picker.pickMultiImage(
      imageQuality: 50,
    );
    if (RegisterDataClass.kycImages.isNotEmpty) {
      setState(() {});
    }
  }

  void setSlots() {
    RegisterDataClass.groundID = UniqueID.generateRandomString();
    RegisterDataClass.sportsTag = sportTags.toString();
    PageRouter.push(context, const SlotSettings());
  }
}
