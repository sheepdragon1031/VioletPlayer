import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Moegirl {
    Moegirl({
        this.animeFile,
        this.animeName,
        this.keyNum,
        this.titleList,
    });
    String animeName,animeFile;
    int keyNum = 0;
    List titleList;

    Future<String> keyWord(animeFile) async {
        this.animeFile = animeFile;
        var name = await getKeyWord(animeFile);
        return '$name';
    }
    Future<String> getKeyWord(animeFile) async {
        this.animeFile = animeFile;
        String url = 'https://zh.moegirl.org/api.php?action=query&list=search&srsearch=${this.animeFile}&utf8&format=json';
            // Await the http get response, then decode the json-formatted response.
            var response = await http.get(url);
            if (response.statusCode == 200) {
                var jsonResponse  = convert.jsonDecode(response.body) ;
                // var itemCount = jsonResponse['totalItems'];
                keyNum = 0;
                for (int i = 0; i < 10 ; i++) {
                    String str = jsonResponse['query']['search'][i]['snippet'];
                    if(str.contains('new RegExp(动画|手游|漫画)')){
                        keyNum = i;
                        break;
                    }
                }
                return jsonResponse['query']['search'][keyNum]['title'];
            
            } else {
                print('Request failed with status: ${response.statusCode}.');
                return null;
            }
        
    }
   
    Future<String> getPage(animeName) async {
        // r'^[=]{$j}\s[\u4e00-\u9fa5_a-zA-Z0-9_]*\s[=]{$j}$'
        String url = 'https://zh.moegirl.org/$animeName?action=raw';
        var response = await http.get(url);
        if (response.statusCode == 200) {
            RegExp expTitle = new RegExp(r'^[=]{2}\s[\u4e00-\u9fa5_a-zA-Z0-9_]*\s[=]{2}$',
                 multiLine: true,
            );
            Iterable<Match> matches = expTitle.allMatches(response.body);
            this.titleList = new List();
            for (Match m in matches) {
                this.titleList.add(m.group(0));
            }
            // for(int i =0; i < h2.length ; i++){
            //     if(i < h2.length -1)
            //         print(response.body.split(h2[i])[1].split(h2[i+1]).first);
            // }
            // print(this.titleList.toString());
            return this.titleList.toString();
           
        } else {
            print('Request failed with status: ${response.statusCode}.');
            return null;
        }
    }
}
class PageJson extends Moegirl{
    final String title;
    final String content;
    PageJson({
        this.title,
        this.content
    });
}