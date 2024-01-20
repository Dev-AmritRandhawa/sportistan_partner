import 'package:image_picker/image_picker.dart';

class RegisterDataClass {
  static late double latitude;
  static late double longitude;
  static late String address;
  static late String description;
  static late String groundID;
  static late String sportsTag;
  static int onwardsAmount = 0;
  static late String groundName;
  static late String personName;
  static List<String> kycUrls = [];
  static List<String> groundUrls = [];
  static late List<String> groundServices;
  static bool serverInit = false;
  static List<XFile> groundImages = [];
  static List<XFile> kycImages = [];


}
