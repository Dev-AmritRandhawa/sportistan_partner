import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';

class CropImageTool extends StatefulWidget {
  const CropImageTool({super.key});

  @override
  State<CropImageTool> createState() => _CropImageToolState();
}

class _CropImageToolState extends State<CropImageTool> {
  File? imageFile;
  ValueNotifier<bool> setProfileLoader = ValueNotifier<bool>(false);

  Future _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
      _cropImage();
    }
  }

  Future _cropImage() async {
    if (imageFile != null) {
      CroppedFile? cropped = await ImageCropper()
          .cropImage(sourcePath: imageFile!.path, aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ], uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop',
            cropGridColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(title: 'Crop')
      ]);

      if (cropped != null) {
        setState(() {
          imageFile = File(cropped.path);
        });
        setProfileLoader.value = true;
        setProfile();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text("Crop Your Image")),
        body: Column(
          children: [
            Expanded(
                flex: 3,
                child: imageFile != null
                    ? Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Image.file(imageFile!))
                    : const Center(
                        child: Text("Add a picture"),
                      )),
            ValueListenableBuilder(
              valueListenable: setProfileLoader,
              builder: (context, value, child) => value
                  ? const CircularProgressIndicator(
                      strokeWidth: 1,
                    )
                  : Container(),
            ),
            Expanded(
                child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CupertinoButton(
                      color: Colors.orangeAccent,
                      onPressed: () {
                        _pickImage();
                      },
                      child: const Text("Choose Image"))
                ],
              ),
            )),
          ],
        ));
  }

  Future<void> setProfile() async {
    try {
      TaskSnapshot task = await FirebaseStorage.instance
          .ref(FirebaseAuth.instance.currentUser!.uid)
          .child("profileImage")
          .child('profile')
          .putFile(imageFile!);
      await task.ref.getDownloadURL().then((valueOfLinks) async => {
            await FirebaseFirestore.instance
                .collection("profileImages")
                .where("userID",
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .get()
                .then((value) => {
                      if (value.docChanges.isNotEmpty)
                        {
                          FirebaseFirestore.instance
                              .collection('profileImages')
                              .doc(value.docChanges.first.doc.id)
                              .set({
                            'profileImageLinks': valueOfLinks,
                            'userID': FirebaseAuth.instance.currentUser!.uid
                          }).then((value) => {
                                    setProfileLoader.value = true,
                                    Navigator.pop(context)
                                  })
                        }
                      else
                        {
                          FirebaseFirestore.instance
                              .collection('profileImages')
                              .add({
                            'profileImageLinks': valueOfLinks,
                            'userID': FirebaseAuth.instance.currentUser!.uid
                          }).then((value) => {
                                    setProfileLoader.value = true,
                                    Navigator.pop(context)
                                  })
                        }
                    })
          });
    } catch (e) {
      setProfileLoader.value = false;

      return;
    }
  }
}
