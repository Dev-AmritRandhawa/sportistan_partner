import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import 'package:lottie/lottie.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:pinput/pinput.dart';
import 'package:sportistan_partners/authentication/search_field.dart';
import 'package:sportistan_partners/nav_bar/nav_home.dart';
import 'package:sportistan_partners/utils/errors.dart';
import 'package:sportistan_partners/utils/page_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneAuthentication extends StatefulWidget {
  const PhoneAuthentication({super.key});

  @override
  State<PhoneAuthentication> createState() => _PhoneAuthenticationState();
}

class _PhoneAuthenticationState extends State<PhoneAuthentication>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  String countryCode = "+91";
  String? verification;

  final _auth = FirebaseAuth.instance;
  final _server = FirebaseFirestore.instance;

  int resendOtpCounter = 0;

  GoogleSignInAccount? currentUser;

  final _focusNode = FocusNode();
  final _focusNodeOTP = FocusNode();

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchUniversalLinkIos(Uri url) async {
    final bool nativeAppLaunchSucceeded = await launchUrl(
      url,
      mode: LaunchMode.externalNonBrowserApplication,
    );
    if (!nativeAppLaunchSucceeded) {
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
      );
    }
  }

  GoogleSignIn googleSignIn = GoogleSignIn(
    serverClientId:
        "497512590176-k2357th2q9rkmq4484uhmu4lqvmivi50.apps.googleusercontent.com",
  );
  final Uri toLaunch = Uri(scheme: 'https', host: 'www.sportistan.co.in');

  @override
  void dispose() {
    numberController.dispose();
    otpController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  TextEditingController numberController = TextEditingController();
  final otpController = TextEditingController();
  GlobalKey<FormState> numberKey = GlobalKey<FormState>();
  GlobalKey<FormState> otpKey = GlobalKey<FormState>();
  ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  ValueNotifier<bool> buttonDisable = ValueNotifier<bool>(false);
  ValueNotifier<bool> imageShow = ValueNotifier<bool>(true);
  ValueNotifier<bool> signInCheck = ValueNotifier<bool>(false);
  OtpTimerButtonController controller = OtpTimerButtonController();

  requestOtp() {
    controller.loading();
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        loading.value = true;
        await _verifyByNumber(
            countryCode, numberController.value.text.toString());
      } on FirebaseAuthException catch (e) {
        _showError(e.message.toString());
      }
      controller.startTimer();
    });
  }
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _focusNode,
        ),
        KeyboardActionsItem(focusNode: _focusNode,  toolbarButtons: [
              (node) {
            return TextButton(onPressed: (){
               node.unfocus();
imageShow.value = true;
            }, child: const Text('Close',style: TextStyle(fontSize: 18),));
          }
        ]),KeyboardActionsItem(
          focusNode: _focusNodeOTP,
        ),
        KeyboardActionsItem(focusNode: _focusNodeOTP,  toolbarButtons: [
              (node) {
            return TextButton(onPressed: (){
              imageShow.value = true;

               node.unfocus();

            }, child: const Text('Close',style: TextStyle(fontSize: 18),));
          }
        ]),

      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Colors.black;
    const fillColor = Colors.black;
    const borderColor = Colors.black;

    final defaultPinTheme = PinTheme(
      width: MediaQuery.of(context).size.width / 10,
      height: MediaQuery.of(context).size.width / 10,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: KeyboardActions(
        config: _buildConfig(context),
          child: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ValueListenableBuilder(
                    valueListenable: imageShow,
                    builder: (context, value, child) =>
                    value ? Column(
                      children: [
                        Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DelayedDisplay(
                                      child: Image.asset(
                                        "assets/logo.png",
                                        color: Colors.black,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                10,
                                      ),
                                    ),
                                  ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Let's",
                                style: TextStyle(
                                    fontFamily: "Nunito",
                                    fontSize:
                                    MediaQuery.of(context).size.height / 20,
                                    color: Colors.black),
                              ),
                              Container()
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Start",
                                style: TextStyle(
                                    fontFamily: "DMSans",
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                    MediaQuery.of(context).size.height / 10,
                                    color: Colors.black),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 10,
                                child: Lottie.asset(
                                  'assets/bouncingBall.json',
                                  controller: _controller,
                                  onLoaded: (composition) {
                                    _controller
                                      ..duration = composition.duration
                                      ..repeat();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
            
                      ],
                    ): Container(),
                  ),
                  Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: loading,
                        builder:
                            (BuildContext context, value, Widget? child) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: Form(
                              key: numberKey,
                              child: TextFormField(
                                onTap: () {
                                  imageShow.value = false;
                                },
                                readOnly: loading.value,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Number required.";
                                  } else if (value.length <= 9) {
                                    return "Enter 10 digits.";
                                  } else {
                                    return null;
                                  }
                                },
                                maxLength: 10,
                                controller: numberController,
                                onChanged: (data) {
                                  numberKey.currentState!.validate();
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                autofillHints: const [
                                  AutofillHints.telephoneNumberLocal
                                ],focusNode: _focusNode,
                                decoration: InputDecoration(
                                    suffixIcon: InkWell(
                                        onTap: () {
                                          loading.value = false;
                                          otpController.clear();
                                          numberController.clear();
                                        },
                                        child: const Icon(Icons.edit)),
                                    fillColor: Colors.white,
                                    border: const OutlineInputBorder(),
                                    errorStyle:
                                        const TextStyle(color: Colors.white),
                                    filled: true,
                                    prefixIcon: CountryCodePicker(
                                      showCountryOnly: true,
                                      onChanged: (value) {
                                        countryCode =
                                            value.dialCode.toString();
                                      },
                                      favorite: const ["IN"],
                                      initialSelection: "IN",
                                    ),
                                    hintText: "Phone Number",
                                    hintStyle:
                                        const TextStyle(color: Colors.black),
                                    labelStyle:
                                        const TextStyle(color: Colors.black)),
                              ),
                            ),
                          );
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: loading,
                        builder: (context, value, child) {
                          return value
                              ? Padding(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width / 25),
                                  child: Pinput(
                                    focusNode: _focusNodeOTP,
                                    controller: otpController,
                                    androidSmsAutofillMethod:
                                        AndroidSmsAutofillMethod
                                            .smsUserConsentApi,
                                    listenForMultipleSmsOnAndroid: true,
                                    defaultPinTheme: defaultPinTheme,
                                    length: 6,
                                    separatorBuilder: (index) =>
                                        const SizedBox(width: 8),
                                    hapticFeedbackType:
                                        HapticFeedbackType.lightImpact,
                                    onCompleted: (pin) {
                                      _manualVerify(pin);
                                    },
                                    cursor: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 9),
                                          width: 22,
                                          height: 1,
                                          color: focusedBorderColor,
                                        ),
                                      ],
                                    ),
                                    focusedPinTheme: defaultPinTheme.copyWith(
                                      decoration: defaultPinTheme.decoration!
                                          .copyWith(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                            color: focusedBorderColor),
                                      ),
                                    ),
                                    submittedPinTheme:
                                        defaultPinTheme.copyWith(
                                      decoration: defaultPinTheme.decoration!
                                          .copyWith(
                                        color: fillColor,
                                        borderRadius:
                                            BorderRadius.circular(19),
                                        border: Border.all(
                                            color: focusedBorderColor),
                                      ),
                                    ),
                                    errorPinTheme:
                                        defaultPinTheme.copyBorderWith(
                                      border:
                                          Border.all(color: Colors.redAccent),
                                    ),
                                  ),
                                )
                              : Container();
                        },
                      ),
                      ValueListenableBuilder(
                        builder:
                            (BuildContext context, value, Widget? child) {
                          return value
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CupertinoButton(
                                    onPressed: () async {
                                      if (numberKey.currentState!
                                          .validate()) {
                                        imageShow.value = true;
                                         _focusNode.unfocus();
            
            
                                        try {
                                          loading.value = true;
                                          await _verifyByNumber(
                                              countryCode,
                                              numberController.value.text
                                                  .toString());
                                        } on FirebaseAuthException catch (e) {
                                          _showError(e.message.toString());
                                        }
                                      }
                                    },
                                    color: Colors.green,
                                    child: const Text(
                                      "Send OTP",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                        },
                        valueListenable: loading,
                      ),
                      ValueListenableBuilder(
                        valueListenable: loading,
                        builder: (BuildContext context, bool value,
                            Widget? child) {
                          return value
                              ? SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 2,
                                  child: OtpTimerButton(
            
                                    buttonType: ButtonType.outlined_button,
                                    controller: controller,
                                    onPressed: () {
                                      requestOtp();
                                    },
                                    text: const Text('Resend OTP',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: "DMSans")),
                                    duration: 15,
                                  ),
                                )
                              : Container();
                        },
                      ),
                    ],
                  ),
                  ValueListenableBuilder(
                    valueListenable: loading,
                    builder: (BuildContext context, value, Widget? child) {
                      return value
                          ? ValueListenableBuilder(
                              valueListenable: signInCheck,
                              builder: (context, value, child) {
                                return value
                                    ? Column(
                                        children: [
                                          const CircularProgressIndicator(
                                              strokeWidth: 1,
                                              color: Colors.white),
                                          CupertinoButton(
                                              onPressed: () {
                                                signInCheck.value = false;
                                              },
                                              child: const Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ))
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                                "Didn't Received OTP? Continue with Google",
                                                style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 18)),
                                          ),
                                          MaterialButton(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              color: Colors.white,
                                              onPressed: () {
                                                signInCheck.value = true;
                                                handleSignIn();
                                              },
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.only(
                                                              right: 8.0),
                                                      child: Text(
                                                        "Continue with Google",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black,
                                                            fontFamily:
                                                                "DMSans"),
                                                      ),
                                                    ),
                                                    Image.asset(
                                                        "assets/gicon.png",
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            45)
                                                  ],
                                                ),
                                              )),
                                        ],
                                      );
                              },
                            )
                          : SizedBox(
                        height: MediaQuery.of(context).size.height/6,
                            child: Lottie.asset(
                                                    'assets/phone_verification.json',
                                                    controller: _controller,
                                                    onLoaded: (composition) {
                            _controller
                              ..duration = composition.duration
                              ..repeat();
                                                    },
                                                  ),
                          );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: buttonDisable,
                    builder: (context, value, child) {
                      return value
                          ? const CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            )
                          : Container();
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width / 8,
                        left: MediaQuery.of(context).size.width / 30,
                        right: MediaQuery.of(context).size.width / 30),
                    child: GestureDetector(
                      onTap: () async {
                        Platform.isIOS
                            ? _launchUniversalLinkIos(toLaunch)
                            : _launchInBrowser(toLaunch);
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'By pressing continue, you agree to our ',
                          style: TextStyle(
                            fontFamily: "DMSans",
                            color: Colors.black54,
                            fontSize: MediaQuery.of(context).size.width / 28,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms,',
                              style: TextStyle(
                                color: Colors.black54,
                                fontFamily: "DMSans",
                                fontSize:
                                    MediaQuery.of(context).size.width / 30,
                              ),
                            ),
                            TextSpan(
                              text: ' Privacy Policy',
                              style: TextStyle(
                                fontFamily: "DMSans",
                                color: Colors.blue,
                                fontSize:
                                    MediaQuery.of(context).size.width / 30,
                              ),
                            ),
                            TextSpan(
                              text: ' and ',
                              style: TextStyle(
                                fontFamily: "DMSans",
                                color: Colors.black54,
                                fontSize:
                                    MediaQuery.of(context).size.width / 30,
                              ),
                            ),
                            TextSpan(
                              text: 'Cookies Policy',
                              style: TextStyle(
                                fontFamily: "DMSans",
                                color: Colors.black54,
                                fontSize:
                                    MediaQuery.of(context).size.width / 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
        ));
  }

  void _showError(String error) {
    Errors.flushBarAuth(error, context);
  }

  Future<void> _verifyByNumber(String countryCode, String number) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: countryCode + number,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          buttonDisable.value = true;
          await _auth
              .signInWithCredential(credential)
              .then((value) => {_checkUserExistenceWithPhone()});
        } on FirebaseAuthException catch (e) {
          buttonDisable.value = false;
          _showError(e.message.toString());
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          buttonDisable.value = false;

          _showError("'The provided phone number is not valid.'");
        } else {
          buttonDisable.value = false;

          _showError(e.message.toString());
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        verification = verificationId;
      },
      timeout: const Duration(seconds: 0),
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> _manualVerify(String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verification.toString(), smsCode: smsCode);
    try {
      buttonDisable.value = true;
      await _auth
          .signInWithCredential(credential)
          .then((value) => {_checkUserExistenceWithPhone()});
    } on FirebaseAuthException catch (e) {
      buttonDisable.value = false;

      _showError(e.message.toString());
    }
  }

  Future<void> handleSignOut() async {
    if (currentUser != null) {
      _auth.currentUser!.delete();
      googleSignIn.disconnect();
    }
  }

  Future<void> handleSignIn() async {
    try {
      currentUser = await googleSignIn.signIn();
      if (currentUser != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await currentUser!.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        if (userCredential.user != null) {
          if (mounted) {
            _checkUserExistence();
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      } else if (e.code == 'invalid-credential') {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _checkUserExistence() async {
    _server
        .collection("SportistanPartners")
        .where('userID', isEqualTo: _auth.currentUser!.uid)
        .get()
        .then((value) async => {
              if (value.docChanges.isNotEmpty)
                {_moveToHome()}
              else
                {
                  await handleSignOut(),
                  signInCheck.value = false,
                  if (mounted)
                    {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Text(
                                "No Account Found",
                                style: TextStyle(
                                    fontFamily: "DMSans",
                                    fontSize: 18,
                                    color: Colors.black),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Use Phone Number to Create an Account Continue with Google service can use later in profile settings for faster login response",
                                  style: TextStyle(
                                      fontFamily: "DMSans", fontSize: 18),
                                ),
                              ),
                              Image.asset("assets/noResults.png"),
                              CupertinoButton(
                                  color: Colors.green,
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text("Continue with Number"))
                            ],
                          );
                        },
                      )
                    }
                }
            });
  }

  Future<void> _checkUserExistenceWithPhone() async {
    try {
      await _server
          .collection("SportistanPartners")
          .where("userID", isEqualTo: _auth.currentUser!.uid)
          .where('phoneNumber', isEqualTo: _auth.currentUser!.phoneNumber)
          .get()
          .then((value) => {
                if (value.docChanges.isEmpty)
                  {_moveToRegister()}
                else
                  {_moveToHome()}
              });
    } catch (e) {
      if (mounted) {
        Errors.flushBarInform(e.toString(), context, "Error");
        _moveToRegister();
      }
    }
  }

  void _moveToHome() {
    PageRouter.pushRemoveUntil(context, const NavHome());
  }

  Future<void> _moveToRegister() async {
    PageRouter.pushRemoveUntil(context, const SearchField());
  }
}
