
import 'package:demomediaplayer/clsList.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class HttpRest {
  String apiBaseUrl = "https://itunes.apple.com/";
  String searchTermUrl = "search?term=[term]";

  Future<List<playList>> searchTerm(String textVal) async {
    var ret = <playList>[];

    try{
      // Await the http get response, then decode the json-formatted response.
      final urlSource = apiBaseUrl + searchTermUrl.replaceAll("[term]", textVal);
      final url = Uri.parse(urlSource);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        var itemCount = jsonResponse['resultCount'];
        //ret = convert.jsonDecode(jsonResponse['results']) as List<playList>;

        for(int i = 0; i < itemCount; i++){
          playList tempPlay = playList();
          tempPlay.artistName = jsonResponse['results'][i]["artistName"].toString();
          tempPlay.collectionName = jsonResponse['results'][i]["collectionName"].toString();
          tempPlay.artworkUrl60 = jsonResponse['results'][i]["artworkUrl60"].toString();
          tempPlay.trackName = jsonResponse['results'][i]["trackName"].toString();
          tempPlay.previewUrl = jsonResponse['results'][i]["previewUrl"].toString();
          ret.add(tempPlay);
        }

      } else {
        print('Request failed with status: ${response.statusCode}.');
      }

    }catch(exc){
      print(exc);
    }


    return ret;
  }
}