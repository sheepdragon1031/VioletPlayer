import 'dart:async';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert.dart';
import 'package:html/parser.dart' show parse;
// import 'package:universal_html/html.dart';
import 'package:universal_html/parsing.dart';
import 'package:universal_html/driver.dart';
import 'dart:convert' show utf8;
import 'package:big5/big5.dart';


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
    Future<String> getFileName(String fileName) async{
        RegExp reg = RegExp(r'([\w-.&]+)([\w\s]+)',multiLine: true);
        // print(reg.hasMatch(fileName));
        if(reg.hasMatch(fileName) == true){
            Iterable<Match> matches = reg.allMatches(fileName);
            // RegExp dig = RegExp(r'([\w-.]+)([\w\s]+)',multiLine: true);
            if(matches.length > 3){
                List name = reg.allMatches(fileName).map((m)=>m.group(0)).toList();
                if(reg.hasMatch(name[1]))
                    return  name[1];
                else if(reg.hasMatch(name[0]))
                    return  name[0];
                
            }
            else{
                 return '';
            }
        }
        
        return '';
    }
    Future<String> getNum(String fileName, Map listWords) async{
        RegExp reg = RegExp(r'([\w-.&]+)([\w\s]+)',multiLine: true);
        String txt = '';
        if(reg.hasMatch(fileName) == true){
            Iterable<Match> matches = reg.allMatches(fileName);
            if(matches.length > 3){
                List episode = reg.allMatches(fileName).map((m)=>m.group(0)).toList();
                RegExp ds = RegExp(r'\d+');
                RegExp wd = RegExp(r'\w+');
                if(ds.hasMatch(episode[2])){
                    txt = episode[2];
                    // print( episode[2].replaceAll(RegExp(r'\s+'),''));
                    listWords.forEach((key, value) {
                        var ep = episode[2].replaceAll(RegExp(r'\s+'),'');
                        if(RegExp("$ep").hasMatch(key)){
                            txt = value;
                            return value;
                        }
                    });
                }
                if(wd.hasMatch(episode[2])){
                    txt = episode[2];
                    List keyW = wd.allMatches(txt).map((m)=>m.group(0)).toList();
                    listWords.forEach((key, value) {
                         for (var item in keyW) {
                            if(RegExp("$item").hasMatch(key)){
                                txt = value;
                                return value;
                            }
                        }
                    });
                   
                }
            }
            return txt;
        }
        return '';
        // stringMatch
    }
    Future<String> keyWord(animeFile) async {
        this.animeFile = animeFile;
        var name = await getKeyWord(animeFile);
        return '$name';
    }
    Future<String> bigToUTF(text) async{
        return big5.decode(text.runes.toList());
    }
    Future <Map<String, Object>> googlePosts(animeFile) async {
        this.animeFile = animeFile;
        animeFile = animeFile.replaceAll(new RegExp(r'\s', multiLine: true),'+');
        String url = 'https://www.google.com.tw/search?hl=zh-tw&lr=lang_zh-TW&q=${animeFile}';
        
        // final driver = new HtmlDriver();
        // Open a web page.
        // var uri = Uri.parse(url);
        // var v = uri.resolveUri(new Uri(query: "\x00\xff[]=&#/\\:?"));
        // await driver.setDocumentFromUri(v);
        // // Select the top story using a CSS query
        // final topStoryTitle = driver.document.querySelectorAll("#rhs > .kno-ecr-pt");
        // print(topStoryTitle);
        
         var response = await http.get(url);
        //  print(url);
        //  print(response.statusCode);
            if (response.statusCode == 200) {
                // List<int> bytes = response.bodyBytes;
                // String utf8Body = big5.decode(bytes);
                // var htm = parseHtmlDocument(utf8Body);
                // utf8.decoder(response.body);
                
                
                
                
                // String fuck = html.querySelectorAll('#main > #rhs > div[class="kno-ecr-pt"]').first.text;
                // print(html);
                
                // var html = parseHtmlDocument(htm.getElementById('main').outerHtml);
                // print(html.querySelectorAll('div').length);
                var htm = parse(response.body);
                // var html = parse(htm.querySelectorAll('#main  div.ZINbbc')[1].outerHtml);
                var body = parseHtmlDocument(htm.querySelectorAll('#main  div.ZINbbc')[1].outerHtml);
                // var html = parse(htm.querySelectorAll('#rcnt'));
                // String big5name = body.querySelectorAll('div[class="kCrYT"]')[0].querySelector('[class="zBAuLc"]').innerText;
                
            
                // List<int> bytes = big5.encode('ºÑÂÅ¯è½u');
                // String utf8Body = utf8.decode(bytes);
                // return bytes;
                // return big5.;
                // print(big5name);
                // print(utf8Body);
                int flags = body.querySelectorAll('.kCrYT h3.zBAuLc').length;
                  var img  =  parseHtmlDocument(htm.querySelectorAll('#main  div.ZINbbc')[5].outerHtml);
                var posts = {
                    'title':  flags == 1 ?
                        this.animeName =  await bigToUTF(body.querySelectorAll('.kCrYT .AP7Wnd')[0].innerText): animeFile,
                    'origin': flags == 1 && body.querySelectorAll('.kCrYT .AP7Wnd')[1].innerText != body.querySelectorAll('.kCrYT .AP7Wnd')[2].innerText? 
                        await bigToUTF(body.querySelectorAll('.kCrYT .AP7Wnd')[1].innerText): '未知',
                    'originContent': flags == 1 ?  
                        await bigToUTF(body.querySelectorAll('.kCrYT .AP7Wnd')[2].innerText): '未知',
                    // 'titleImg': body.querySelectorAll('div.nGphre').length == 1 ?
                    //     null:body.querySelectorAll('div.Xdlr0d')[0].querySelectorAll('a.BVG0Nb')[0].getAttribute('href').split(new RegExp(r'&(imgurl|imgrefurl)=', multiLine: true))[1]
                        //a.BVG0Nb
                        //img.WddBJd
                };

                // new RegExp(r'\s', multiLine: true)
                // print(body.querySelectorAll('div.nGphre').length);
                // print(body.querySelectorAll('div.Xdlr0d')[0].querySelectorAll('a.BVG0Nb')[0].getAttribute('href').split(new RegExp(r'(imgurl|imgrefurl)=', multiLine: true))[1]);
                // posts['title'] = body.querySelector('h3.zBAuLc').innerText;
                // utf8.decode(big5.decode(body.runes.toList()).runes.toList())
                print(posts);
                return posts;
            
            } else {
                print('Request failed with status: ${response.statusCode}.');
                return null;
            }
       
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
    Future<Map> getWikiPage(animeName) async {
    
        String url = 'https://zh.wikipedia.org/zh-tw/$animeName';
        // ?action=raw
        var response = await http.get(url);
       
            if (response.statusCode == 200) {
                var htm = parse(response.body);
                var infobox = parseHtmlDocument(htm.querySelector('.infobox').outerHtml);
                String playTime = '';
                Map listWords = {};
                for (var item in infobox.querySelectorAll('tr')) {
                    RegExp reg = RegExp(r'播放期間',multiLine: true);
                    if(reg.hasMatch(item.innerText)){
                        playTime = item.innerText.replaceAll(RegExp(r'\s', multiLine: true), '');
                        playTime = RegExp(r'\d{4}年\d{1,2}月').stringMatch(playTime).toString();
                        
                        String month = RegExp(r'\d{1,2}月').stringMatch(playTime).toString();
                        month = RegExp(r'\d{1,2}').stringMatch(month).toString();
                        var intMonth = (int.parse(month) / 3 + 1) ;
                        
                        String year = RegExp(r'\d{4}年').stringMatch(playTime).toString();
                        playTime = '日本'+ year + changeSeason[ intMonth.floor()] + '季動畫';
                        break;
                    }
                        
                }
                print(playTime);
                
                if(htm.querySelectorAll('#各話列表').length > 0){
                    RegExp head = RegExp(r'話數',multiLine: true);
                    int i = 0;
                    
                    for (var item in htm.querySelectorAll('.wikitable')) {
                        var tr = item.querySelectorAll('tr');
                        if(head.hasMatch(tr[0].text)){
                            int j = 0;
                            for (var th in tr[0].querySelectorAll('th')) {
                                // print(th.innerHtml);
                                if(RegExp(r'中文標題').hasMatch(th.innerHtml)){
                                    break;
                                }
                                j++;
                            }
                            
                            
                            for (int n = 1 ; n < tr.length; n++) {
                                var td  = tr[n].querySelectorAll('td');
                                //  var td = parseHtmlDocument(tr.innerHtml).querySelectorAll('td');
                                
                                listWords[td[0].innerHtml] = td[j].innerHtml;
                            }
                          break;
                        }
                        i++;
                    }
                    //  wikitable.querySelector('tr').innerText

                }
                
                var out = {
                    'meogrl' : playTime,
                    'listWords': listWords,
                };
               
                
                return out;
            
            } else {
                print('Request failed with status: ${response.statusCode}.');
                 var out = {
                    'meogrl' : '',
                    'listWords': {},
                };
                return out;
            }
    }

    Future<Map<String, dynamic>> getAcgnxList(animeName) async {
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
                    return null;
                    //    return await wikiGetPage('' ,'日本${this.animeYear}年$season季動畫'); 
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
    Future <String> wikiIamgeApi(String fileOrigin) async{
        RegExp reg = RegExp(r'File:([\w-\s])+.(jpg|png|gif)',multiLine: true); //抓取圖片名稱
        if(reg.hasMatch(fileOrigin) == true){
            String fileName = reg.stringMatch(fileOrigin).toString();
           
            String api = 'https://zh.moegirl.org/api.php?action=query&titles=$fileName&prop=imageinfo&iiprop=url&format=json';
            var response = await http.get(api);
            if (response.statusCode == 200) {
                Map<String, dynamic> json  = convert.jsonDecode(response.body) ;
                return json['query']['pages']['-1']['imageinfo'][0]['url'];
            }
            else {
                print('Request failed with status: ${response.statusCode}.');
                return 'https://i.imgur.com/5GpHv2q.gif';
            }
        }
        else{
            return 'https://i.imgur.com/5GpHv2q.gif';
        }
        
       
    } 
    Future<Map<String, dynamic>> wikiGetPage(String animeName, String animeYearSeason) async {
        // r'^[=]{2}\s[\u4e00-\u9fa5_a-zA-Z0-9_]*\s[=]{2}$'
        //   ^[=]{2}[\u4e00-\u9fa5_a-zA-Z0-9_-\s]*[=]{2}$
        // ^[=]{3}[\u4e00-\u9fa5_a-zA-Z0-9_]*[=]{3}$

        String url = 'https://zh.moegirl.org/zh-tw/$animeYearSeason?action=raw';
        
        // print(url);
        List jsonAllPage = [];
        this.animeName = animeName;
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
           
            Iterable<Match> matched = expContent.allMatches(jsonAllPage[flags]);
           
            List animeContent = new List();
            List animeList = [];
            // print(jsonAllPage[flags]);
            for (Match m in matched) {
                animeList.add(m.group(0)); //wiki Raw h3 標籤
            }
            
            for(int i = 0; i < animeList.length ; i++){
                RegExp reg = RegExp(r'(\*)|(<[^>]*>)|(^{{columns-list\|2\||}}$)|(^{{BilibiliVideo+[\w\|=]+}})', multiLine: true); //去除Template、Html、* 標籤
                if(i < animeList.length - 1){  
                    String origin = jsonAllPage[flags].split(animeList[i])[1].split(animeList[i + 1]).first; 
                    animeContent.add(origin.replaceAll(reg, '')); 
                    
                }
                else{
                    String origin = jsonAllPage[flags].split(animeList[i])[1]; 
                    animeContent.add(origin.replaceAll(reg, '')); 
                }
                animeContent[i] = animeContent[i].replaceAll(new RegExp(r'(^\s+)|(\s+$)', multiLine: true),'');
                animeList[i] =animeList[i].replaceAll(new RegExp(r'([=]{3})', multiLine: true), ''); //去除h3標籤
                
            }
           
          
            String animeText = ''; 
            for(int j =0; j < animeContent.length ; j++){
                animeList[j] = await ChineseConverter.convert(animeList[j], S2TW());
                animeContent[j] = await ChineseConverter.convert(animeContent[j], S2TW());
                animeText += '\n' + animeList[j] + (j==0?'\n':'') + animeContent[j];
            }
            var wiki ={
                'wikiImg' : await wikiIamgeApi(jsonAllPage[flags].split(animeList[0]).first),
                'wikiList' : animeList,
                'wikiContent': animeContent
            };
            return  wiki;
           
        } else {
            var wiki ={
                'wikiImg' : '',
                'wikiList' : [],
                'wikiContent': [],
            };
            print('Request failed with status: ${response.statusCode}.');
            return wiki;
        }
    }
}

