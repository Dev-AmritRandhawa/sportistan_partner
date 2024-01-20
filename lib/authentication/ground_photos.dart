import 'dart:io';
import 'package:chips_choice/chips_choice.dart';
import 'package:delayed_display/delayed_display.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:sportistan_partners/authentication/ground_details_register.dart';
import 'package:sportistan_partners/bookings/book_a_slot.dart';
import 'package:sportistan_partners/utils/errors.dart';
import 'package:sportistan_partners/utils/page_router.dart';
import 'package:sportistan_partners/utils/register_data_class.dart';

class GroundPhotos extends StatefulWidget {
  const GroundPhotos({super.key});

  @override
  State<GroundPhotos> createState() => _GroundPhotosState();
}

class _GroundPhotosState extends State<GroundPhotos>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  List<String> serviceTags = ['Washroom'];
  List<String> serviceOptions = [
    'Washroom',
    'Flood Lights',
    'Parking',
    'Sound System',
    'Warm Up Area',
    'Coaching Available',
    'Ball Boy',
    'Sitting Area',
    'Drinking Water',
    'Locker Room',
  ];

  var currentPage = 0;

  var otherService = TextEditingController();
  var descriptionController = TextEditingController();
  GlobalKey<FormState> otherServiceKey = GlobalKey<FormState>();
  GlobalKey<FormState> descriptionControllerKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController groundController = TextEditingController();
  GlobalKey<FormState> groundKey = GlobalKey<FormState>();
  GlobalKey<FormState> nameKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title: const Text('Back'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          actions: [
            IconButton(
                onPressed: () {
                  if (descriptionControllerKey.currentState!.validate()) {
                    if (RegisterDataClass.groundImages.isNotEmpty) {
                      RegisterDataClass.groundServices = serviceTags;
                      RegisterDataClass.description =
                          descriptionController.value.text.trim();
                      PageRouter.push(context, const GroundDetailsRegister());
                    } else {
                      Errors.flushBarInform(
                          'Ground Images Required', context, "Add Images");
                      uploadImages();
                    }
                  } else {
                    Errors.flushBarInform(
                        'Write Minimum 50 Words', context, "Add Description");
                  }
                },
                icon: const Icon(Icons.arrow_forward_ios_sharp))
          ]),
      body: SafeArea(
          child: DelayedDisplay(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Card(
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_on_sharp,
                      color: Colors.green,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        RegisterDataClass.address,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.height / 60,
                            fontFamily: "DMSans",
                            color: Colors.black),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        child: Form(
                          key: descriptionControllerKey,
                          child: TextFormField(
                            controller: descriptionController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Add Description";
                              } else if (value.length < 49) {
                                Errors.flushBarInform('Write Minimum 50 Words',
                                    context, "Add Description");
                                return 'Write Minimum 50 Words';
                              } else {
                                return null;
                              }
                            },
                            decoration: const InputDecoration(
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              errorStyle: TextStyle(color: Colors.red),
                              filled: true,
                              hintText: "Description",
                              hintStyle: TextStyle(color: Colors.black45),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      itemCount: RegisterDataClass.groundImages.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return RegisterDataClass.groundImages.isNotEmpty
                            ? ListTile(
                                title: Text(RegisterDataClass
                                    .groundImages[index].name
                                    .toString()),
                                leading: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 25,
                                    child: Image.file(File(RegisterDataClass
                                        .groundImages[index].path))),
                                onTap: () async {
                                  setState(() {
                                    RegisterDataClass.groundImages
                                        .removeAt(index);
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  addAutomaticKeepAlives: true,
                  children: <Widget>[
                    Content(
                      title: 'Choose Ground Services if Available',
                      child: ChipsChoice<String>.multiple(
                        value: serviceTags,
                        onChanged: (val) => setState(() => serviceTags = val),
                        choiceItems: C2Choice.listFrom<String, String>(
                          source: serviceOptions,
                          value: (i, v) => v,
                          label: (i, v) => v,
                          tooltip: (i, v) => v,
                        ),
                        choiceCheckmark: true,
                        choiceStyle: C2ChipStyle.filled(
                          color: Colors.green,
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
              CupertinoButton(
                  onPressed: () {
                    if (otherServiceKey.currentState!.validate()) {
                      if (!serviceOptions.contains(otherService.value.text)) {
                        serviceTags.add(otherService.value.text);
                        serviceOptions.add(otherService.value.text);
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Already Added"),
                          duration: Duration(seconds: 1),
                        ));
                      }
                    }
                  },
                  color: Colors.indigoAccent,
                  child: const Text(
                    "Add More Services",
                    style: TextStyle(color: Colors.white),
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: otherServiceKey,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: TextFormField(
                      maxLength: 15,
                      validator: (v) {
                        if (v!.isEmpty) {
                          return "Empty Field (Optional)";
                        } else {
                          return null;
                        }
                      },
                      controller: otherService,
                      decoration: const InputDecoration(
                          fillColor: Colors.white,
                          hintText:
                              "Add Other Services if Available (Optional)",
                          border: InputBorder.none,
                          errorStyle: TextStyle(color: Colors.red),
                          filled: true,
                          labelStyle: TextStyle(color: Colors.black)),
                    ),
                  ),
                ),
              ),
              RegisterDataClass.groundImages.isEmpty
                  ? Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: CupertinoButton(
                    color: Colors.orangeAccent,
                    child: const Text("Select Ground Images"),
                    onPressed: () async {
                      uploadImages();
                    }),
              )
                  : Container(),
              RegisterDataClass.groundImages.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CupertinoButton(
                          color: Colors.green,
                          onPressed: () async {
                            if (descriptionControllerKey.currentState!
                                .validate()) {
                              RegisterDataClass.groundServices = serviceTags;
                              RegisterDataClass.description =
                                  descriptionController.value.text.trim();
                              PageRouter.push(
                                  context, const GroundDetailsRegister());
                            }else{
                              Errors.flushBarInform('Write Minimum 50 Words',
                                  context, "Add Description");
                            }
                          },
                          child: const Text(
                            "Next Step",
                            style: TextStyle(fontFamily: "DMSans"),
                          )),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Images Not Selected',
                          style: TextStyle(
                              fontFamily: "DMSans", color: Colors.red)),
                    ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 5,
                width: MediaQuery.of(context).size.height / 5,
                child: Lottie.asset(
                  "assets/groundPhotos.json",
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..repeat();
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 10,
              )
            ],
          ),
        ),
      )),
    );
  }

  uploadImages() async {
    final ImagePicker picker = ImagePicker();
    RegisterDataClass.groundImages =
        await picker.pickMultiImage(imageQuality: 50);
    if (RegisterDataClass.groundImages.isNotEmpty) {
      setState(() {});
    }
  }
}
