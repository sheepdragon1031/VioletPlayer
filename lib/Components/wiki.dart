import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:convert' show utf8;
import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert.dart';

class Moegirl {
    Moegirl({
        this.animeFile,
        this.animeName,
        this.animeYear,
        this.keyNum,
        this.titleList,
        this.animeSeason,
        this.animeNameS,
    });
    String animeName, animeFile, animeNameS;
    int keyNum = 0, animeYear, animeSeason;
    List titleList;
    List<String> changeSeason= ['劇場版','冬','春','夏','秋'];
    Future<String> keyWord(animeFile) async {
        this.animeFile = animeFile;
        var name = await getKeyWord(animeFile);
        return '$name';
    }
    Future<String> getKeyWord(animeFile) async {
        this.animeFile = animeFile;
        // String url = 'https://zh.moegirl.org/api.php?action=query&list=search&srsearch=${this.animeFile}&utf8&format=json';
        String url = 'https://zh.wikipedia.org/w/api.php?action=query&list=search&srsearch=${this.animeFile}&lang=zh-tw&utf8&format=json';
            // Await the http get response, then decode the json-formatted response.
            var response = await http.get(url);
            if (response.statusCode == 200) {
                var jsonResponse  = convert.jsonDecode(response.body) ;
                // var itemCount = jsonResponse['totalItems'];
                keyNum = 0;
                // for (int i = 0; i < 10 ; i++) {
                //     String str = jsonResponse['query']['search'][i]['snippet'];
                //     if(str.contains('new RegExp(动画|手游|漫画)')){
                //         keyNum = i;
                //         break;
                //     }
                // }
                return jsonResponse['query']['search'][keyNum]['title'];
            
            } else {
                print('Request failed with status: ${response.statusCode}.');
                return null;
            }
        
    }
    

    Future<String> getAcgnxList(animeName) async {
        this.animeName = animeName;
        this.animeYear = 2019;
        this.animeSeason = 4;
        // String url = 'https://zh.moegirl.org/api.php?action=query&list=search&srsearch=${this.animeFile}&utf8&format=json';
        String url = 'https://share.acgnx.se/bangumilist/2019Q4.txt?';
            // Await the http get response, then decode the json-formatted response.
            var response = await http.get(url,
            headers: {'content':'text/html; charset=UTF-8'});
            if (response.statusCode == 200) {

                // var jsonResponse  = convert.jsonDecode(response.body) ;
                List<int> bytes = response.bodyBytes;
                String utf8Body = utf8.decode(bytes, allowMalformed: true);
                RegExp week = new RegExp(r'^\d[,]+',
                    multiLine: true,
                );
                List<String> weekBody = [];
                bool flags = false;
                for(int i = 1; i < 8; i++){
                    weekBody.add(utf8Body.split(week)[i]);
                    // print(weekBody[i-1]);
                    if(weekBody[i-1].indexOf(new RegExp(this.animeName)) > -1)
                        flags = true;
                }
                if(flags){
                   String season = changeSeason[this.animeSeason];
                   return await wikiGetPage('日本${this.animeYear}年$season季動畫'); 
                }
                else{
                    return null;
                }
               
                // return jsonResponse['query']['search'][keyNum]['title'];
            
            } else {
                print('Request failed with status: ${response.statusCode}.');
                return null;
            }
        
    }
    Future<String> wikiGetPage(animeYearSeason) async {
        // r'^[=]{2}\s[\u4e00-\u9fa5_a-zA-Z0-9_]*\s[=]{2}$'
        //   ^[=]{2}[\u4e00-\u9fa5_a-zA-Z0-9_-\s]*[=]{2}$
        // ^[=]{3}[\u4e00-\u9fa5_a-zA-Z0-9_]*[=]{3}$

        String url = 'https://zh.moegirl.org/zh-tw/$animeYearSeason?action=raw';
        // print(url);
        List jsonAllPage = [];
        this.animeNameS = await ChineseConverter.convert(this.animeName, TW2S());
        var response = await http.get(url);
        if (response.statusCode == 200) {
            RegExp expTitle = new RegExp(r'^==[^=]+==$',
                 multiLine: true,
            );
           
            Iterable<Match> matches = expTitle.allMatches(response.body);
            this.titleList = new List();
            for (Match m in matches) {
                this.titleList.add(m.group(0));
            }
            int flags =0;
            for(int i =0; i < this.titleList.length ; i++){
                if(i < this.titleList.length -1){
                   
                    int getNum= this.titleList[i].indexOf(new RegExp(this.animeNameS));
                    jsonAllPage.add(response.body.split(this.titleList[i])[1].split(this.titleList[i + 1]).first);
                    if(getNum > 0 ){
                        if(flags == 0){
                            flags = i;
                        }
                    }
                    
                }
            }
           
            //^[=]{3}[\u4e00-\u9fa5_a-zA-Z0-9_]*[=]{3}
            RegExp expContent = new RegExp(r'^={3}[^=]+={3}$',
                 multiLine: true,
            );
           
            Iterable<Match> matched = expContent.allMatches(jsonAllPage[6]);
           
            List animeContent = new List();
            List animeList = [];
            // print(jsonAllPage[flags]);
            for (Match m in matched) {
                animeList.add(m.group(0)); //wiki Raw h3 標籤
            }
            
            for(int i =0; i < animeList.length ; i++){
                if(i < animeList.length - 1){  
                    String origin = jsonAllPage[flags].split(animeList[i])[1].split(animeList[i + 1]).first; 
                    animeContent.add(origin.replaceAll(new RegExp(r'(<[^>]*>)|(^{{columns-list\|2\||}}$)', multiLine: true), '')); //去除Template、Html標籤
                    
                }
                else{
                    String origin = jsonAllPage[flags].split(animeList[i])[1]; 
                    animeContent.add(origin.replaceAll(new RegExp(r'(<[^>]*>)|(^{{columns-list\|2\||}}$)', multiLine: true), '')); //去除Template、Html標籤
                }
                
                animeList[i] =animeList[i].replaceAll(new RegExp(r'([=]{3})', multiLine: true), '');
                
            }
           
            
            String animeText = ''; 
            for(int j =0; j < animeContent.length ; j++){
                
                animeList[j] = await ChineseConverter.convert(animeList[j], S2TW());
                animeContent[j] = await ChineseConverter.convert(animeContent[j], S2TW());
                animeText += '\n' + animeList[j] + (j==0?'\n':'') + animeContent[j];
            }

          
             return  animeText;
           
        } else {
            print('Request failed with status: ${response.statusCode}.');
            return null;
        }
    }
}

