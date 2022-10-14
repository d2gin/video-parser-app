import 'package:android_external_storage/android_external_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';

abstract class Base {
  late String urlPattern;
  String platformName = "";
  String platform = "";
  String api = "https://tool.icy8.net/api.parser/index?share=";
  var result = {
    "platform": "unknow",
    "platform_text": "unknow",
    "title": "",
    "cover": "",
    "video_url": "",
    "result_type": "video",
  };

  Future<Map> analyze(String share) async {
    var dio = Dio();
    var url = api + Uri.encodeComponent(share);
    var result = (await dio.get(url)).data;
    print(url);
    if (result['code'] < 0) {
      throw result['message'];
    }
    return result['data'];
  }

  Future getSavePath() async {
    var deviceInfo = await DeviceInfoPlugin().androidInfo;
    if (deviceInfo.model == "YAL-AL00") {
      // 荣耀20下载的视频不能在相册显示，要借助原生插件
      return (await AndroidExternalStorage.getExternalStoragePublicDirectory(
                  DirType.downloadDirectory))
              .toString() +
          "/" +
          this.platform +
          "/";
    } else {
      return (await AndroidExternalStorage.getExternalStoragePublicDirectory(
                  DirType.DCIMDirectory))
              .toString() +
          "/Camera/";
    }
  }

  String getUrl(String share) {
    var r = RegExp(urlPattern, caseSensitive: false);
    var m = r.firstMatch(share)?.group(1);
    if (m != null) return m;
    throw "share url not found!";
  }

  String pregQuote(String str, {String delimiter: ""}) {
    return str.replaceAllMapped(
        RegExp("([.\\\\+*?\\[^\\]\$(){}=!<>|:\\\\" + delimiter + "\\-])",
            caseSensitive: false), (Match m) {
      return "\\${m[1]}";
    });
  }

  Map parseQuery(String query) {
    var result = {};
    var m = RegExp(r"([^=&\s]+)[=\s]([^=&\s]+)").allMatches(query);
    // print(m);
    m.forEach((element) {
      result[element.group(1)] = element.group(2);
    });
    return result;
  }
}
