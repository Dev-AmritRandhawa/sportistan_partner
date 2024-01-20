import 'package:flutter/foundation.dart';

class PlacePrediction{

  String secondaryText = "";
  String mainText= "";
  String placeId= "";

  PlacePrediction({required this.secondaryText, required this.mainText, required this.placeId});

  PlacePrediction.fromJson(Map<String, dynamic> json){
    try{
      placeId = json["place_id"];
      mainText = json["structured_formatting"]["main_text"];
      secondaryText = json["structured_formatting"]["secondary_text"];
    }
  catch(e){
  if (kDebugMode) {
    print(e);
  }
  }
  }
}
